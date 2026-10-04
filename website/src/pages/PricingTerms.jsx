import React from 'react';
import { Link } from 'react-router-dom';

const PricingTerms = () => {
  return (
    <div className="container">
      <h1>Premium Subscription Terms & Conditions</h1>
      <p>Last updated: October 2026</p>
      
      <section>
        <h2>1. Subscription Billing</h2>
        <p>Invoz Premium subscriptions are billed in advance on a recurring monthly or yearly basis, depending on the plan you select at checkout. By subscribing, you authorize Invoz to automatically charge the payment method on file on the renewal date.</p>
      </section>

      <section>
        <h2>2. Pricing Changes</h2>
        <p>Invoz reserves the right to adjust pricing for our service or any components thereof in any manner and at any time as we may determine in our sole and absolute discretion. Any price changes to your service will take effect following email notice to you or a notification within the app.</p>
      </section>

      <section>
        <h2>3. Cancellation Policy</h2>
        <p>You may cancel your Invoz Premium subscription at any time. Your cancellation will take effect at the end of the current paid term. If you cancel, you will continue to have access to Premium features through the end of your billing cycle.</p>
        <p><strong>To cancel:</strong> Go to Settings &gt; Subscription in the app and tap "Manage Subscription" or "Cancel Subscription".</p>
      </section>

      <section>
        <h2>4. Refund Policy</h2>
        <p>Except when required by law, paid subscription fees are non-refundable.</p>
        <ul>
          <li><strong>Google Play Purchases:</strong> Refund requests are governed by Google Play's refund policy. You must submit your request directly to Google Play.</li>
          <li><strong>Razorpay/Direct Purchases:</strong> Invoz does not offer pro-rated refunds for cancelled subscriptions mid-cycle. If you believe you were charged in error, please contact support within 7 days of the charge.</li>
        </ul>
      </section>

      <section>
        <h2>5. Downgrading to Free Tier</h2>
        <p>Upon cancellation or failure to renew, your account will revert to the Free Tier. You will retain all previously created invoices, but you will immediately be subject to the Free Tier's daily limits on creating new documents. You will also lose access to Advanced Analytics and Cloud Sync features.</p>
      </section>

      <div style={{ marginTop: '2rem', paddingTop: '1rem', borderTop: '1px solid #eee' }}>
        <p>Return to <Link to="/pricing">Packages & Pricing</Link> or the <Link to="/">Home Page</Link>.</p>
      </div>
    </div>
  );
};

export default PricingTerms;
