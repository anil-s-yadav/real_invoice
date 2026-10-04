import React from 'react';

const PrivacyPolicy = () => {
  return (
    <div className="container legal-doc">
      <h1>Privacy Policy</h1>
      <p className="effective-date"><strong>Effective Date:</strong> October 4, 2026</p>
      
      <div className="legal-content">
        <p>
          This Privacy Policy describes how Invoz ("we", "our", or "us") collects, uses, processes, and protects your personal and business data when you use our mobile application and related web services (collectively, the "Service"). 
          By accessing or using the Service, you consent to the data practices described in this Privacy Policy.
        </p>

        <h2>1. Information We Collect</h2>
        <p>We collect information you provide directly to us, as well as information collected automatically when you use our Service:</p>
        <ul>
          <li><strong>Personal Identification Data:</strong> Your name, email address, phone number, and account credentials provided during registration.</li>
          <li><strong>Business & Financial Data:</strong> Company names, logos, client contact information, product catalogs, generated invoices, quotations, and proforma invoices.</li>
          <li><strong>Technical & Usage Data:</strong> Device hardware models, operating system versions, unique device identifiers, IP addresses, and application crash reports.</li>
          <li><strong>Transaction Data:</strong> Subscription status and purchase history. <em>Note: We do not directly collect or store full credit card numbers. All payments are processed securely by PCI-compliant third-party gateways (e.g., Razorpay, Google Play Billing).</em></li>
        </ul>

        <h2>2. How We Use Your Information</h2>
        <p>We process your data for the following legitimate business purposes:</p>
        <ul>
          <li>To provide, operate, and maintain the Service, including secure cloud synchronization of your business documents.</li>
          <li>To process subscription payments and deliver corresponding premium features.</li>
          <li>To communicate with you regarding account updates, security alerts, and customer support inquiries.</li>
          <li>To analyze usage patterns to improve application performance and user experience.</li>
          <li>To comply with legal obligations and enforce our Terms of Service.</li>
        </ul>

        <h2>3. Data Storage and Cloud Processing</h2>
        <p>
          Invoz operates on a local-first architecture. If you are on the Free Tier, your business data primarily resides locally on your physical device. 
          If you are on the Premium Tier, your data is securely synchronized and stored using Google Firebase Cloud infrastructure to enable multi-device access and backup recovery.
          We implement commercially reasonable technical, administrative, and physical safeguards to protect your data against unauthorized access, destruction, or alteration.
        </p>

        <h2>4. Data Sharing and Third-Party Subprocessors</h2>
        <p>We do not sell, rent, or trade your personal or business data to third parties. We only share information with trusted subprocessors strictly for the purpose of operating the Service:</p>
        <ul>
          <li><strong>Cloud Infrastructure:</strong> Google Firebase (for database hosting and authentication).</li>
          <li><strong>Payment Processors:</strong> Razorpay and Google Play (for processing subscription fees).</li>
          <li><strong>Legal Requirements:</strong> We may disclose your information if required to do so by law, court order, or governmental request.</li>
        </ul>

        <h2>5. Data Retention</h2>
        <p>
          We retain your personal and business data for as long as your account remains active or as needed to provide the Service. 
          If you request account deletion, we will purge your personal and business data from our active databases within a commercially reasonable timeframe (typically 7-14 business days), except where retention is required for legal, tax, or regulatory compliance.
        </p>

        <h2>6. Your Data Rights</h2>
        <p>Depending on your jurisdiction, you possess the right to:</p>
        <ul>
          <li>Access and export a copy of the data you have provided to us.</li>
          <li>Correct inaccurate or incomplete data directly within the app settings.</li>
          <li>Request the permanent deletion of your account and associated cloud data (see our <a href="/data-deletion">Data Deletion Policy</a> for exact instructions).</li>
          <li>Opt-out of promotional communications.</li>
        </ul>

        <h2>7. Changes to this Privacy Policy</h2>
        <p>
          We reserve the right to update this Privacy Policy at our discretion. We will notify you of any material changes by updating the "Effective Date" at the top of this document or by displaying a prominent notice within the application.
        </p>

        <h2>8. Contact Us</h2>
        <p>
          If you have questions, concerns, or requests regarding this Privacy Policy or our data practices, please contact our Data Protection Officer at <strong>anilyadav44x@gmail.com</strong>.
        </p>
      </div>
    </div>
  );
};

export default PrivacyPolicy;

