const functions = require('firebase-functions/v1');
const admin = require('firebase-admin');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');

admin.initializeApp();

const db = getFirestore();

// 1. Trigger when a subscription updates (Payment Success / Upgrade)
exports.onSubscriptionUpdate = functions.firestore
    .document('users/{userId}/subscription/current')
    .onWrite(async (change, context) => {
        const userId = context.params.userId;
        const newData = change.after.exists ? change.after.data() : null;
        const oldData = change.before.exists ? change.before.data() : null;

        if (!newData) return null; // Subscription deleted

        // Check if plan upgraded or newly activated
        const isNewActivation = !oldData && newData.isActive;
        const isUpgrade = oldData && !oldData.isActive && newData.isActive;

        if (isNewActivation || isUpgrade) {
            const title = "Premium Activated! 🎉";
            const body = `Your ${newData.planName || 'Premium'} plan is now active. Thank you!`;
            
            await sendNotificationAndSave(userId, title, body, 'subscription');
        }

        return null;
    });

// 2. Daily Cron Job: Check for Expiring Plans & Due Invoices
exports.dailyChecks = functions.pubsub.schedule('0 9 * * *').onRun(async (context) => {
    const now = new Date();
    now.setHours(0, 0, 0, 0); // Start of today

    // A. Check Subscriptions
    const subsSnapshot = await db.collectionGroup('subscription')
        .where('isActive', '==', true)
        .get();

    for (const doc of subsSnapshot.docs) {
        if (doc.id !== 'current') continue;

        const sub = doc.data();
        if (!sub.endDate) continue;

        const end = sub.endDate.toDate();
        end.setHours(0,0,0,0);
        
        const diffDays = Math.ceil((end - now) / (1000 * 60 * 60 * 24));
        const userId = doc.ref.parent.parent.id;

        if (diffDays === 3 || diffDays === 1) {
            await sendNotificationAndSave(
                userId,
                "Subscription Expiring Soon",
                `Your plan expires in ${diffDays} day(s). Renew to keep premium features.`,
                "subscription"
            );
        } else if (diffDays === 0) {
            await sendNotificationAndSave(
                userId,
                "Subscription Expired",
                "Your premium plan has expired. Upgrade now to restore access.",
                "subscription"
            );
        }
    }

    // B. Check Documents Due (Invoices, Quotations, Proformas)
    const documentsSnapshot = await db.collectionGroup('documents')
        .where('docType', 'in', ['invoice', 'quotation', 'proforma'])
        .where('status', 'in', ['sent', 'partial'])
        .get();

    for (const doc of documentsSnapshot.docs) {
        const inv = doc.data();
        if (!inv.dueDate) continue;

        const due = inv.dueDate.toDate();
        due.setHours(0,0,0,0);
        
        const diffDays = Math.ceil((due - now) / (1000 * 60 * 60 * 24));
        const userId = doc.ref.parent.parent.id;
        
        // Capitalize first letter of docType
        const docName = inv.docType.charAt(0).toUpperCase() + inv.docType.slice(1);

        if (diffDays === 3 || diffDays === 1 || diffDays === 0) {
            await sendNotificationAndSave(
                userId,
                `${docName} Due ${diffDays === 0 ? 'Today' : 'Soon'}`,
                `${docName} ${inv.docNumber} is due ${diffDays === 0 ? 'today' : `in ${diffDays} day(s)`}.`,
                "document", // General type for routing
                doc.id
            );
        }
    }

    return null;
});

// Helper function to send Push Notification AND save to Firestore UI
async function sendNotificationAndSave(userId, title, body, type, relatedId = null) {
    // 1. Save to in-app notification center (Firestore)
    await db.collection('users').doc(userId).collection('notifications').add({
        title,
        body,
        type,
        relatedId,
        isRead: false,
        createdAt: FieldValue.serverTimestamp()
    });

    // 2. Send Push Notification via FCM
    const userDoc = await db.collection('users').doc(userId).get();
    const fcmToken = userDoc.data()?.fcmToken;

    if (fcmToken) {
        try {
            await getMessaging().send({
                token: fcmToken,
                notification: {
                    title: title,
                    body: body
                },
                data: {
                    type: type,
                    relatedId: relatedId || ''
                }
            });
        } catch (error) {
            console.error(`Error sending push to ${userId}:`, error);
        }
    }
}

// 3. Analytics Aggregator (Option 3: Database Scaling)
// Runs automatically when a document is created/updated/deleted to keep a running total.
// This prevents the client from needing to download thousands of invoices just to show the dashboard.
exports.aggregateSummaryStats = functions.firestore
    .document('users/{userId}/documents/{documentId}')
    .onWrite(async (change, context) => {
        const userId = context.params.userId;
        const db = getFirestore();
        
        // This is a lightweight aggregation function that tallies up the grand totals
        // without the client needing to read 10,000 documents.
        const docsSnapshot = await db.collection('users').doc(userId).collection('documents')
            .where('docType', '==', 'invoice')
            .get();
        
        let unpaidTotal = 0;
        let unpaidCount = 0;
        let paidTotal = 0;
        let paidCount = 0;

        docsSnapshot.forEach(doc => {
            const data = doc.data();
            const total = data.totalAmount || 0;
            const paid = data.amountPaid || 0;
            const remaining = Math.max(0, total - paid);

            if (data.status === 'paid' || remaining <= 0) {
                paidTotal += paid;
                paidCount++;
            } else {
                unpaidTotal += remaining;
                unpaidCount++;
            }
        });

        // Save the aggregated result to a single document!
        await db.collection('users').doc(userId).collection('reports').doc('summary_stats').set({
            unpaidTotal,
            unpaidCount,
            paidTotal,
            paidCount,
            lastUpdatedAt: FieldValue.serverTimestamp()
        }, { merge: true });

        return null;
    });
