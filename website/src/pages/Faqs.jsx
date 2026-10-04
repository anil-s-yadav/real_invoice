import React from 'react';
import { Link } from 'react-router-dom';

const Faqs = () => {
  return (
    <div className="container legal-doc">
      <h1>Frequently Asked Questions (FAQs)</h1>
      <p className="effective-date">Comprehensive Support & Guides for Invoz</p>
      
      <div className="legal-content">
        
        <h2 className="faq-category">Getting Started</h2>
        
        <div className="faq-item">
          <h3>What is Invoz?</h3>
          <p>
            Invoz is a comprehensive, mobile-first business utility application designed to help freelancers, contractors, and small-to-medium businesses generate professional invoices, quotations, receipts, and proforma invoices in seconds. It also acts as a mini-CRM by helping you track client balances, items, and business analytics.
          </p>
        </div>

        <div className="faq-item">
          <h3>Do I need an active internet connection to use the app?</h3>
          <p>
            No! Invoz is built with an "offline-first" architecture. You can generate invoices, add clients, and manage your items completely offline. When your device reconnects to the internet (and if you are a Premium user), your data will automatically sync securely to the cloud in the background.
          </p>
        </div>

        <div className="faq-item">
          <h3>Can I use my account on multiple devices?</h3>
          <p>
            Yes. Premium users can log into their Invoz account on multiple Android devices. Because your data is synced to the cloud, any invoice created on one phone will automatically appear on your second device.
          </p>
        </div>

        <h2 className="faq-category">Document Creation & Customization</h2>

        <div className="faq-item">
          <h3>How do I add my Bank Details and UPI QR Code to invoices?</h3>
          <p>
            1. Open the app and navigate to <strong>Settings</strong> &gt; <strong>Payment Details</strong>.<br />
            2. Add your Bank Account information and/or your UPI ID.<br />
            3. When creating a new document, scroll down to the "Additional Info" section and toggle on <strong>"Show Payment Details & QR Code"</strong>. Your professional PDF will now automatically include a scannable UPI QR code for your clients!
          </p>
        </div>

        <div className="faq-item">
          <h3>Can I add my company logo and signature?</h3>
          <p>
            Absolutely. Go to <strong>Settings</strong> &gt; <strong>Manage Business Profile</strong>. From there, you can upload a high-quality image of your company logo and draw or upload your digital signature. These will be automatically stamped onto every PDF you generate.
          </p>
        </div>

        <div className="faq-item">
          <h3>How do taxes and discounts work?</h3>
          <p>
            You can configure your default tax settings (e.g., GST, VAT, Sales Tax) in <strong>Settings</strong> &gt; <strong>Tax & Discount Settings</strong>. You can choose whether taxes are applied globally to the entire invoice, or individually per-item. Discounts can be applied as flat amounts or percentages.
          </p>
        </div>

        <div className="faq-item">
          <h3>Can I change the currency?</h3>
          <p>
            Yes. The app automatically detects your region's currency, but you can manually override this in <strong>Settings</strong> &gt; <strong>Regional Settings</strong> to bill international clients in USD, EUR, GBP, or any other major currency.
          </p>
        </div>

        <h2 className="faq-category">Billing & Subscriptions</h2>

        <div className="faq-item">
          <h3>What is the exact difference between the Free and Premium plans?</h3>
          <p>
            The Free plan is a trial-oriented tier that allows you to test the app's features but places a strict limit on the number of documents you can generate per day. The <strong>Premium Plan</strong> unlocks unlimited document creation, removes all advertisements, unlocks deep financial analytics (Debt Aging, Win Rates, Tax charts), and turns on automatic secure cloud syncing for your database.
          </p>
        </div>

        <div className="faq-item">
          <h3>How do I upgrade to Premium?</h3>
          <p>
            Tap on the <strong>Settings</strong> tab in the bottom navigation bar, then tap <strong>Subscription</strong>. You can securely purchase a Monthly or Yearly plan using Google Play Billing or Razorpay depending on your region.
          </p>
        </div>

        <div className="faq-item">
          <h3>What happens if I cancel my Premium subscription?</h3>
          <p>
            If you cancel, you will retain your Premium features until the end of your current paid billing cycle. Once the cycle ends, your account seamlessly downgrades to the Free tier. You will <strong>not</strong> lose any existing invoices or clients, but you will instantly lose cloud backup capabilities and be subject to daily document creation limits.
          </p>
        </div>

        <h2 className="faq-category">Security & Privacy</h2>

        <div className="faq-item">
          <h3>Is my financial data secure?</h3>
          <p>
            Yes. We take data security very seriously. All local data is stored within an encrypted SQLite database isolated to your device. Cloud-synced data is transmitted over TLS/SSL encryption and stored securely on Google Firebase infrastructure, heavily protected against unauthorized access.
          </p>
        </div>

        <div className="faq-item">
          <h3>How do I delete my account and wipe my data?</h3>
          <p>
            You have full control over your data. You can delete your account instantly by going to <strong>Settings</strong> &gt; <strong>Account Settings</strong> and tapping "Delete Account". For detailed instructions, please read our <Link to="/data-deletion">Data Deletion Policy</Link>.
          </p>
        </div>

        <div className="faq-item">
          <h3>How do I contact customer support?</h3>
          <p>
            We are always here to help! You can reach our support team directly from the app by going to <strong>Settings</strong> &gt; <strong>Help & Support</strong>, or you can email us directly at <strong>anilyadav44x@gmail.com</strong>.
          </p>
        </div>

      </div>
    </div>
  );
};

export default Faqs;

