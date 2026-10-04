import React from 'react';
import { Link } from 'react-router-dom';

const Pricing = () => {
  return (
    <div className="container">
      <h1>Invoz Packages & Subscription Details</h1>
      <p>Last updated: October 2026</p>
      
      <p>
        At Invoz, we are committed to providing a transparent and fair pricing structure for businesses of all sizes. 
        This page details the exact limitations, features, and terms associated with our Free and Premium packages. 
        Please read these details carefully before upgrading your account.
      </p>

      <hr style={{ margin: '2rem 0', borderColor: '#e5e7eb' }} />

      <section>
        <h2>1. The Free Tier Package</h2>
        <p>
          The Free Tier is automatically applied to all new users who download and register on the Invoz application. 
          It is designed for small businesses, freelancers, or users who want to test the application before committing to a paid plan.
        </p>
        
        <h3>Included Features</h3>
        <ul>
          <li><strong>Local Data Storage:</strong> All your data is stored securely on your local device.</li>
          <li><strong>Client & Item Management:</strong> You can add clients and items to your database without strict database limitations.</li>
          <li><strong>Basic Document Generation:</strong> Access to standard PDF templates for generating invoices, quotations, and proforma invoices.</li>
        </ul>

        <h3>Limitations & Restrictions</h3>
        <ul>
          <li><strong>Daily Document Limits:</strong> Free users are strictly limited to generating a small maximum number of documents per day. Once this limit is reached, you will be blocked from creating new documents until the next calendar day.</li>
          <li><strong>No Cloud Sync or Backup:</strong> If you lose your phone or uninstall the app, your data cannot be recovered. Free accounts do not benefit from our automated Firebase cloud synchronization.</li>
          <li><strong>No Advanced Analytics:</strong> Access to detailed business reports (such as Debt Aging, Tax Collection Trends, and Year-over-Year Growth) is restricted.</li>
          <li><strong>Advertisements:</strong> The free experience is ad-supported.</li>
        </ul>
      </section>

      <section>
        <h2>2. The Premium Package</h2>
        <p>
          The Premium Package is our flagship offering designed for established and growing businesses that require 
          unrestricted access, automated backups, and deep financial insights.
        </p>

        <h3>Detailed Features & Unlocks</h3>
        <ul>
          <li><strong>Unlimited Document Creation:</strong> The daily document cap is completely removed. You can generate unlimited invoices, quotations, and receipts.</li>
          <li><strong>Automated Cloud Backup & Multi-Device Sync:</strong> Your data is securely backed up to our cloud infrastructure. You can safely log in on a new device and have your data restored immediately.</li>
          <li><strong>Advanced Business Analytics:</strong> Unlock all premium charts and metrics, including the 365-day Quotation Funnel, Client Win Rates, Debt Aging Donuts, and detailed Tax reports.</li>
          <li><strong>Premium Templates:</strong> Access to exclusive, highly customizable PDF templates for your business documents.</li>
          <li><strong>Ad-Free Experience:</strong> All banner and interstitial advertisements are completely removed from the interface.</li>
          <li><strong>Priority Support:</strong> Premium users receive prioritized responses from our customer support team.</li>
        </ul>

        <h3>Pricing Structure</h3>
        <p>
          The Premium package is offered in two billing cycles. Note that pricing is localized and subject to applicable taxes depending on your region.
        </p>
        <ul>
          <li><strong>Monthly Subscription:</strong> Billed at ₹99 per month. Renews automatically every 30 days.</li>
          <li><strong>Yearly Subscription:</strong> Billed at ₹999 per year. Renews automatically every 365 days. (Offers significant savings over the monthly plan).</li>
        </ul>
      </section>

      <section>
        <h2>3. Subscription Rules & Policies</h2>
        <p>
          By purchasing a Premium package, you agree to the following rules governing the transaction:
        </p>
        <ul>
          <li><strong>Auto-Renewal:</strong> Subscriptions automatically renew unless cancelled at least 24 hours before the end of the current billing period.</li>
          <li><strong>Payment Processing:</strong> Payments are processed securely via Google Play Billing or Razorpay. Invoz does not store your credit card information directly.</li>
          <li><strong>Downgrades:</strong> If your payment fails or you actively cancel your subscription, your account will revert to the Free Tier at the end of your billing cycle. You will not lose existing documents, but your ability to create new ones will instantly be restricted by Free Tier daily limits, and cloud backups will cease.</li>
        </ul>
      </section>

      <div style={{ marginTop: '2rem', padding: '1rem', backgroundColor: '#f3f4f6', borderRadius: '8px' }}>
        <p style={{ margin: 0 }}>
          <strong>Looking for our legal refund and cancellation terms?</strong> <br />
          Please read our full <Link to="/pricing-terms">Subscription Terms & Conditions</Link> for detailed legal information.
        </p>
      </div>
    </div>
  );
};

export default Pricing;

