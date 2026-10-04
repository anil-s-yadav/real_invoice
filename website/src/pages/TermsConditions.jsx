import React from 'react';

const TermsConditions = () => {
  return (
    <div className="container">
      <h1>Terms & Conditions</h1>
      <p>Last updated: October 2026</p>
      
      <section>
        <h2>1. Acceptance of Terms</h2>
        <p>By downloading, installing, or using the Invoz application, you agree to be bound by these Terms & Conditions. If you do not agree to these terms, please do not use the application.</p>
      </section>

      <section>
        <h2>2. Description of Service</h2>
        <p>Invoz is a billing, invoicing, and quotation management application designed for businesses. We offer both a Free Tier (with limited features and document creation) and a Premium Tier (unlimited documents and advanced analytics).</p>
      </section>

      <section>
        <h2>3. Subscriptions and Payments</h2>
        <ul>
          <li><strong>Premium Plans:</strong> Access to premium features requires an active subscription.</li>
          <li><strong>Billing:</strong> Subscriptions are billed in advance on a recurring basis (monthly or yearly).</li>
          <li><strong>Cancellations:</strong> You may cancel your subscription at any time. Your premium access will continue until the end of your current billing cycle.</li>
          <li><strong>Refunds:</strong> Refund requests are subject to the policies of the respective app stores (Google Play/Apple App Store) or our payment processor.</li>
        </ul>
      </section>

      <section>
        <h2>4. User Responsibilities</h2>
        <p>You are responsible for:</p>
        <ul>
          <li>Maintaining the confidentiality of your account credentials.</li>
          <li>The accuracy of the data (invoices, taxes, client info) entered into the app. Invoz is not responsible for accounting or tax errors made by the user.</li>
          <li>Ensuring your use of the app complies with all applicable local, state, and national laws.</li>
        </ul>
      </section>

      <section>
        <h2>5. Intellectual Property</h2>
        <p>All content, features, and functionality of the app, including but not limited to text, graphics, logos, and software, are the exclusive property of Invoz and its licensors.</p>
      </section>

      <section>
        <h2>6. Limitation of Liability</h2>
        <p>Invoz shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use or inability to use the service, including data loss or business interruption.</p>
      </section>
    </div>
  );
};

export default TermsConditions;
