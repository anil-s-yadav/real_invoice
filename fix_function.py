import re

with open('functions/index.js', 'r', encoding='utf-8') as f:
    content = f.read()

bad_query = r'''    const documentsSnapshot = await db.collectionGroup\('documents'\)
        \.where\('docType', 'in', \['invoice', 'quotation', 'proforma'\]\)
        \.where\('status', 'in', \['sent', 'partial'\]\)
        \.get\(\);'''

good_query = r'''    // Firestore only allows ONE 'in' clause per query. 
    // We filter docType in query, and filter status in memory.
    const documentsSnapshot = await db.collectionGroup('documents')
        .where('docType', 'in', ['invoice', 'quotation', 'proforma'])
        .get();'''

content = re.sub(bad_query, good_query, content)

bad_loop = r'''    for \(const doc of documentsSnapshot\.docs\) \{
        const inv = doc\.data\(\);
        if \(!inv\.dueDate\) continue;'''

good_loop = r'''    for (const doc of documentsSnapshot.docs) {
        const inv = doc.data();
        if (!['sent', 'partial'].includes(inv.status)) continue;
        if (!inv.dueDate) continue;'''

content = re.sub(bad_loop, good_loop, content)

with open('functions/index.js', 'w', encoding='utf-8') as f:
    f.write(content)
