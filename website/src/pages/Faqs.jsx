import React, { useState } from 'react';

const faqData = [
  {
    category: "Getting Started",
    questions: [
      {
        q: "What is Invoz?",
        a: "Invoz is a comprehensive, mobile-first business utility application designed to help freelancers, contractors, and small-to-medium businesses generate professional invoices, quotations, receipts, and proforma invoices in seconds. It also acts as a mini-CRM by helping you track client balances, items, and business analytics."
      },
      {
        q: "Do I need an active internet connection to use the app?",
        a: "No! Invoz is built with an 'offline-first' architecture. You can generate invoices, add clients, and manage your items completely offline. When your device reconnects to the internet (and if you are a Premium user), your data will automatically sync securely to the cloud in the background."
      },
      {
        q: "Can I use my account on multiple devices?",
        a: "Yes. Premium users can log into their Invoz account on multiple Android devices. Because your data is synced to the cloud, any invoice created on one phone will automatically appear on your second device."
      }
    ]
  },
  {
    category: "Document Creation & Customization",
    questions: [
      {
        q: "How do I add my Bank Details and UPI QR Code to invoices?",
        a: "1. Open the app and navigate to Settings > Payment Details.\n2. Add your Bank Account information and/or your UPI ID.\n3. When creating a new document, scroll down to the 'Additional Info' section and toggle on 'Show Payment Details & QR Code'. Your professional PDF will now automatically include a scannable UPI QR code for your clients!"
      },
      {
        q: "Can I add my company logo and signature?",
        a: "Absolutely. Go to Settings > Manage Business Profile. From there, you can upload a high-quality image of your company logo and draw or upload your digital signature. These will be automatically stamped onto every PDF you generate."
      },
      {
        q: "How do taxes and discounts work?",
        a: "You can configure your default tax settings (e.g., GST, VAT, Sales Tax) in Settings > Tax & Discount Settings. You can choose whether taxes are applied globally to the entire invoice, or individually per-item. Discounts can be applied as flat amounts or percentages."
      },
      {
        q: "Can I change the currency?",
        a: "Yes. The app automatically detects your region's currency, but you can manually override this in Settings > Regional Settings to bill international clients in USD, EUR, GBP, or any other major currency."
      }
    ]
  },
  {
    category: "Billing & Subscriptions",
    questions: [
      {
        q: "What is the exact difference between the Free and Premium plans?",
        a: "The Free plan is a trial-oriented tier that allows you to test the app's features but places a strict limit on the number of documents you can generate per day. The Premium Plan unlocks unlimited document creation, removes all advertisements, unlocks deep financial analytics (Debt Aging, Win Rates, Tax charts), and turns on automatic secure cloud syncing for your database."
      },
      {
        q: "How do I upgrade to Premium?",
        a: "Tap on the Settings tab in the bottom navigation bar, then tap Subscription. You can securely purchase a Monthly or Yearly plan using Google Play Billing or Razorpay depending on your region."
      },
      {
        q: "What happens if I cancel my Premium subscription?",
        a: "If you cancel, you will retain your Premium features until the end of your current paid billing cycle. Once the cycle ends, your account seamlessly downgrades to the Free tier. You will not lose any existing invoices or clients, but you will instantly lose cloud backup capabilities and be subject to daily document creation limits."
      }
    ]
  },
  {
    category: "Security & Privacy",
    questions: [
      {
        q: "Is my financial data secure?",
        a: "Yes. We take data security very seriously. All local data is stored within an encrypted SQLite database isolated to your device. Cloud-synced data is transmitted over TLS/SSL encryption and stored securely on Google Firebase infrastructure, heavily protected against unauthorized access."
      },
      {
        q: "How do I delete my account and wipe my data?",
        a: "You have full control over your data. You can delete your account instantly by going to Settings > Account Settings and tapping 'Delete Account'. For detailed instructions, please read our Data Deletion Policy."
      },
      {
        q: "How do I contact customer support?",
        a: "We are always here to help! You can reach our support team directly from the app by going to Settings > Help & Support, or you can email us directly at anilyadav44x@gmail.com."
      }
    ]
  }
];

const Faqs = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const [expandedIndex, setExpandedIndex] = useState(null);

  const toggleExpand = (index) => {
    setExpandedIndex(expandedIndex === index ? null : index);
  };

  const filteredData = faqData.map(category => {
    return {
      ...category,
      questions: category.questions.filter(q => 
        q.q.toLowerCase().includes(searchTerm.toLowerCase()) || 
        q.a.toLowerCase().includes(searchTerm.toLowerCase())
      )
    };
  }).filter(category => category.questions.length > 0);

  let globalIndex = 0;

  return (
    <div className="container legal-doc">
      <h1>Frequently Asked Questions (FAQs)</h1>
      <p className="effective-date">Comprehensive Support & Guides for Invoz</p>
      
      <div className="search-container">
        <input 
          type="text" 
          placeholder="Search for a question or topic..." 
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="faq-search-input"
        />
      </div>
      
      <div className="legal-content faq-accordion">
        {filteredData.length > 0 ? (
          filteredData.map((category, catIdx) => (
            <div key={catIdx} className="faq-category-group">
              <h2 className="faq-category-title">{category.category}</h2>
              {category.questions.map((item, qIdx) => {
                const currentIndex = globalIndex++;
                const isExpanded = expandedIndex === currentIndex;
                
                return (
                  <div key={qIdx} className={`faq-tile ${isExpanded ? 'expanded' : ''}`}>
                    <div 
                      className="faq-tile-header" 
                      onClick={() => toggleExpand(currentIndex)}
                    >
                      <h3>{item.q}</h3>
                      <span className="faq-icon">{isExpanded ? '−' : '+'}</span>
                    </div>
                    {isExpanded && (
                      <div className="faq-tile-content">
                        <p>{item.a.split('\\n').map((line, i) => (
                          <React.Fragment key={i}>
                            {line}
                            <br />
                          </React.Fragment>
                        ))}</p>
                      </div>
                    )}
                  </div>
                );
              })}
            </div>
          ))
        ) : (
          <div className="faq-not-found">
            <h3>Couldn't find what you were looking for?</h3>
            <p>Don't worry! We are here to help.</p>
            <p>Please write an email to our support team outlining your query, and we will get back to you as soon as possible.</p>
            <a href="mailto:anilyadav44x@gmail.com?subject=Invoz%20Support%20Request" className="contact-support-btn">
              Email Support
            </a>
          </div>
        )}
      </div>
    </div>
  );
};

export default Faqs;
