import React from 'react';
import { Link } from 'react-router-dom';

const TermsConditions = () => {
  return (
    <div className="container legal-doc">
      <h1>Terms of Service & Conditions</h1>
      <p className="effective-date"><strong>Effective Date:</strong> October 4, 2026</p>
      
      <div className="legal-content">
        <p>
          These Terms of Service ("Terms") constitute a legally binding agreement made between you, whether personally or on behalf of an entity ("you", "User"), 
          and Invoz ("we", "us", or "our"), concerning your access to and use of the Invoz mobile application and related web platforms (the "Service").
          By downloading, accessing, or using the Service, you acknowledge that you have read, understood, and agree to be bound by all of these Terms.
        </p>

        <h2>1. Description of Service</h2>
        <p>
          Invoz is a software-as-a-service (SaaS) application that allows businesses to generate, manage, and distribute invoices, quotations, and related financial documents. 
          We are a technology provider and do not provide accounting, financial, legal, or tax advice. You remain solely responsible for the accuracy of all data, taxes, and invoices generated using our Service.
        </p>

        <h2>2. Account Registration & Security</h2>
        <p>
          To utilize certain features, you must register for an account. You agree to provide accurate, current, and complete information and to keep this information updated. 
          You are entirely responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account. 
          We shall not be liable for any loss or damage arising from your failure to comply with this security obligation.
        </p>

        <h2>3. Subscriptions, Payments, and Auto-Renewal</h2>
        <p>
          Access to advanced features requires a Premium Subscription.
        </p>
        <ul>
          <li><strong>Billing Cycle:</strong> Subscriptions are billed in advance on a recurring monthly or annual basis, depending on your selection.</li>
          <li><strong>Auto-Renewal:</strong> Your subscription will automatically renew at the end of each billing cycle unless you cancel auto-renewal through the applicable platform (e.g., Google Play Subscriptions or your in-app account settings) at least 24 hours prior to the cycle's expiration.</li>
          <li><strong>Pricing Changes:</strong> We reserve the right to modify subscription fees. Any price changes will be communicated to you in advance and will only take effect at the start of the next billing cycle.</li>
        </ul>

        <h2>4. Refund and Cancellation Policy</h2>
        <p>
          <strong>All subscription payments are strictly non-refundable</strong>, except where explicitly required by applicable consumer law. 
          There are no refunds or credits for partially used billing periods. 
          If you cancel your subscription, your cancellation will take effect at the end of your current paid term, and you will retain access to Premium features until that date. 
          Upon expiration, your account will instantly revert to the Free Tier limitations (see our <Link to="/pricing">Service Packages Documentation</Link>).
        </p>

        <h2>5. Intellectual Property Rights</h2>
        <p>
          The Service and its original content, features, and functionality (including but not limited to software code, UI design, text, and graphics) are and will remain the exclusive property of Invoz and its licensors. 
          You may not copy, modify, distribute, sell, or lease any part of our Service.
        </p>
        <p>
          You retain all ownership rights to the business data, logos, and information you upload to the Service ("User Content"). 
          By uploading User Content, you grant us a worldwide, non-exclusive, royalty-free license to host, store, and process this data solely for the purpose of operating and providing the Service to you.
        </p>

        <h2>6. Acceptable Use and Prohibited Conduct</h2>
        <p>You agree not to use the Service to:</p>
        <ul>
          <li>Generate fraudulent, illegal, or grossly misleading financial documents.</li>
          <li>Attempt to bypass, exploit, or reverse-engineer the Service's payment walls, APIs, or security mechanisms.</li>
          <li>Upload viruses, malicious code, or engage in denial-of-service attacks.</li>
        </ul>
        <p>We reserve the right to suspend or terminate your account immediately, without prior notice or refund, if you violate these Terms.</p>

        <h2>7. Disclaimer of Warranties</h2>
        <p>
          THE SERVICE IS PROVIDED ON AN "AS IS" AND "AS AVAILABLE" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED. 
          WE DISCLAIM ALL WARRANTIES, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, AND NON-INFRINGEMENT. 
          WE DO NOT WARRANT THAT THE SERVICE WILL BE UNINTERRUPTED, ERROR-FREE, SECURE, OR FREE FROM DATA LOSS.
        </p>

        <h2>8. Limitation of Liability</h2>
        <p>
          IN NO EVENT SHALL INVOZ, ITS DIRECTORS, EMPLOYEES, OR AGENTS BE LIABLE TO YOU OR ANY THIRD PARTY FOR ANY INDIRECT, CONSEQUENTIAL, EXEMPLARY, INCIDENTAL, SPECIAL, OR PUNITIVE DAMAGES, 
          INCLUDING LOST PROFIT, LOST REVENUE, LOSS OF DATA, OR OTHER DAMAGES ARISING FROM YOUR USE OF THE SERVICE, EVEN IF WE HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. 
          NOTWITHSTANDING ANYTHING TO THE CONTRARY CONTAINED HEREIN, OUR TOTAL LIABILITY TO YOU FOR ANY CAUSE WHATSOEVER WILL AT ALL TIMES BE LIMITED TO THE AMOUNT PAID, IF ANY, BY YOU TO US DURING THE SIX (6) MONTH PERIOD PRIOR TO ANY CAUSE OF ACTION ARISING.
        </p>

        <h2>9. Indemnification</h2>
        <p>
          You agree to defend, indemnify, and hold us harmless, including our subsidiaries, affiliates, and all of our respective officers, agents, partners, and employees, from and against any loss, damage, liability, claim, or demand, including reasonable attorneys' fees and expenses, made by any third party due to or arising out of your use of the Service, your breach of these Terms, or your violation of any law or the rights of a third party.
        </p>

        <h2>10. Governing Law</h2>
        <p>
          These Terms shall be governed by and construed in accordance with the laws of India, without regard to its conflict of law principles. Any legal action or proceeding related to the Service shall be brought exclusively in the competent courts located within India.
        </p>

        <h2>11. Contact Information</h2>
        <p>
          If you have any questions regarding these Terms, please contact us at <strong>anilyadav44x@gmail.com</strong>.
        </p>
      </div>
    </div>
  );
};

export default TermsConditions;

