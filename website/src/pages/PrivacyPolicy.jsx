import React from 'react';

const PrivacyPolicy = () => {
  return (
    <div className="container">
      <h1>Privacy Policy</h1>
      <p>Last updated: October 2026</p>
      
      <section>
        <h2>1. Information We Collect</h2>
        <p>Invoz collects information to provide better services to our users. This includes:</p>
        <ul>
          <li><strong>Personal Information:</strong> Name, email address, and profile details you provide during registration.</li>
          <li><strong>Business Data:</strong> Invoices, quotations, client details, and product catalogs you create within the app.</li>
          <li><strong>Payment Information:</strong> Handled securely by third-party payment processors (e.g., Razorpay/Google Play). We do not store full credit card details.</li>
        </ul>
      </section>

      <section>
        <h2>2. How We Use Information</h2>
        <p>We use the collected information to:</p>
        <ul>
          <li>Provide, maintain, and improve our services.</li>
          <li>Process transactions and send related information, including confirmations and receipts.</li>
          <li>Send technical notices, updates, security alerts, and support messages.</li>
        </ul>
      </section>

      <section>
        <h2>3. Data Storage & Security</h2>
        <p>Your data is stored securely using industry-standard cloud infrastructure (Firebase/Google Cloud). We implement security measures to protect your information from unauthorized access, alteration, disclosure, or destruction. Local data is also cached securely on your device.</p>
      </section>

      <section>
        <h2>4. Sharing of Information</h2>
        <p>We do not share your personal information with third parties except in the following cases:</p>
        <ul>
          <li>With your consent.</li>
          <li>For legal reasons, if required by law or to protect our rights.</li>
          <li>With trusted service providers who work on our behalf and have agreed to adhere to this privacy policy.</li>
        </ul>
      </section>

      <section>
        <h2>5. Your Rights</h2>
        <p>You have the right to access, update, or delete your personal information. You can manage your data directly within the app settings or contact our support team for assistance.</p>
      </section>
    </div>
  );
};

export default PrivacyPolicy;
