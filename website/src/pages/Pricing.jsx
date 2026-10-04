import React from 'react';
import { Link } from 'react-router-dom';

const Pricing = () => {
  return (
    <div className="container">
      <div style={{ textAlign: 'center', marginBottom: '2rem' }}>
        <h1>Simple, Transparent Pricing</h1>
        <p>Choose the plan that best fits your business needs. No hidden fees.</p>
      </div>

      <div className="pricing-grid">
        {/* Free Plan */}
        <div className="pricing-card">
          <h2>Free Tier</h2>
          <div className="price">₹0<span>/month</span></div>
          <p className="plan-desc">Perfect for small businesses just getting started.</p>
          
          <ul className="feature-list">
            <li>✅ Limited daily documents (Invoices/Quotations)</li>
            <li>✅ Basic PDF Templates</li>
            <li>✅ Local Device Storage</li>
            <li>✅ Client & Item Management</li>
            <li>❌ Advanced Analytics</li>
            <li>❌ Unlimited Cloud Sync</li>
            <li>❌ Priority Support</li>
          </ul>
        </div>

        {/* Premium Plan */}
        <div className="pricing-card premium-card">
          <div className="popular-badge">MOST POPULAR</div>
          <h2>Premium</h2>
          <div className="price">₹99<span>/month</span></div>
          <p className="plan-desc">Unlimited everything for growing businesses.</p>
          
          <ul className="feature-list">
            <li>✅ <strong>Unlimited</strong> Invoices & Quotations</li>
            <li>✅ Premium PDF Templates</li>
            <li>✅ Secure Cloud Backup & Sync</li>
            <li>✅ Advanced Analytics & Reports</li>
            <li>✅ Priority Customer Support</li>
            <li>✅ Ad-Free Experience</li>
          </ul>
          
          <div className="yearly-offer">
            Or save big with our Yearly Plan for just <strong>₹999/year</strong>!
          </div>
        </div>
      </div>

      <div className="pricing-footer">
        <p>All payments are securely processed via Razorpay & Google Play.</p>
        <p>
          <Link to="/pricing-terms">View Detailed Pricing Terms & Conditions</Link>
        </p>
      </div>
    </div>
  );
};

export default Pricing;
