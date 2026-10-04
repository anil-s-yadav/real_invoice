import React from 'react';

const Faqs = () => {
  return (
    <div className="container">
      <h1>Frequently Asked Questions</h1>
      
      <div className="faq-item">
        <h3>What is the difference between the Free and Premium plans?</h3>
        <p>The Free plan allows you to create a limited number of documents (invoices/quotations) per day. The Premium plan unlocks unlimited document creation, advanced analytics, premium reports, and priority support.</p>
      </div>

      <div className="faq-item">
        <h3>How do I upgrade to Premium?</h3>
        <p>You can upgrade to Premium directly within the app. Go to the Settings tab, tap on 'Subscription', and choose the plan that best fits your business needs.</p>
      </div>

      <div className="faq-item">
        <h3>Is my data backed up?</h3>
        <p>Yes! All your data is securely synced and backed up to the cloud automatically when you have an internet connection. You can access your invoices from multiple devices by logging in with the same account.</p>
      </div>

      <div className="faq-item">
        <h3>Can I customize my invoices?</h3>
        <p>Absolutely. You can add your company logo, signature, custom terms, and choose from various professional invoice templates in the Settings menu.</p>
      </div>

      <div className="faq-item">
        <h3>What happens if I cancel my Premium subscription?</h3>
        <p>If you cancel, you will retain your Premium features until the end of your current billing cycle. After that, your account will revert to the Free plan. You will not lose any previously created invoices, but you will be subject to the daily creation limits of the Free plan moving forward.</p>
      </div>

      <div className="faq-item">
        <h3>How do I contact support?</h3>
        <p>If you need assistance, you can reach out to us at support@invozapp.com or use the 'Help & Support' section directly within the app.</p>
      </div>
    </div>
  );
};

export default Faqs;
