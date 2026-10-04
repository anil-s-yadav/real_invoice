import React from 'react';

const DataDeletion = () => {
  return (
    <div className="container">
      <h1>Data Deletion Policy</h1>
      <p>Last updated: October 2026</p>
      
      <section>
        <h2>How to Delete Your Account and Data</h2>
        <p>At Invoz, we respect your privacy and give you full control over your data. If you wish to delete your account and all associated data, you have two options:</p>
      </section>

      <section>
        <h2>Option 1: In-App Deletion (Recommended)</h2>
        <p>You can instantly delete your account directly from within the Invoz app:</p>
        <ol>
          <li>Open the Invoz app on your device.</li>
          <li>Navigate to the <strong>Settings</strong> tab.</li>
          <li>Tap on <strong>Manage Business Profile</strong> or <strong>Account Settings</strong>.</li>
          <li>Scroll to the bottom and select <strong>Delete Account</strong>.</li>
          <li>Confirm the deletion. All your data will be permanently wiped from our secure servers.</li>
        </ol>
      </section>

      <section>
        <h2>Option 2: Email Request</h2>
        <p>If you no longer have access to the app, you can request data deletion by contacting our support team:</p>
        <ul>
          <li>Send an email to <strong>support@invozapp.com</strong> from the email address associated with your account.</li>
          <li>Use the subject line: "Account Deletion Request".</li>
          <li>Our team will process your request and permanently delete your data within 7 business days.</li>
        </ul>
      </section>

      <section>
        <h2>What Data is Deleted?</h2>
        <p>When you delete your account, we completely remove:</p>
        <ul>
          <li>Your personal profile and email address.</li>
          <li>Your business details and uploaded logos.</li>
          <li>All your created invoices, quotations, and client data stored on our cloud servers.</li>
        </ul>
        <p><em>Note: Data stored locally on your physical device will be cleared if you uninstall the app. Financial records previously sent to clients via email/PDF obviously cannot be recalled.</em></p>
      </section>
    </div>
  );
};

export default DataDeletion;
