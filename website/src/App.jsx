import React from 'react'
import { BrowserRouter as Router, Routes, Route, Link } from 'react-router-dom'
import PrivacyPolicy from './pages/PrivacyPolicy'
import TermsConditions from './pages/TermsConditions'
import Faqs from './pages/Faqs'
import DataDeletion from './pages/DataDeletion'
import Pricing from './pages/Pricing'
import PricingTerms from './pages/PricingTerms'
import './index.css'

function App() {
  return (
    <Router>
      <div className="app-container">
        <nav className="navbar">
          <Link to="/" className="nav-brand">
            <img src="/logo.png" alt="Invoz Logo" className="brand-logo" />
            <span>Invoz Legal</span>
          </Link>
          <div className="nav-links desktop-links">
            <Link to="/pricing">Packages & Pricing</Link>
            <Link to="/privacy">Privacy Policy</Link>
            <Link to="/terms">Terms</Link>
            <Link to="/faq">FAQs</Link>
            <Link to="/data-deletion">Data Deletion</Link>
          </div>
        </nav>

        <main className="main-content">
          <Routes>
            <Route path="/" element={<Faqs />} />
            <Route path="/pricing" element={<Pricing />} />
            <Route path="/pricing-terms" element={<PricingTerms />} />
            <Route path="/privacy" element={<PrivacyPolicy />} />
            <Route path="/terms" element={<TermsConditions />} />
            <Route path="/faq" element={<Faqs />} />
            <Route path="/data-deletion" element={<DataDeletion />} />
          </Routes>
        </main>

        <footer className="footer">
          <div className="footer-links">
             <Link to="/pricing">Pricing</Link> | 
             <Link to="/pricing-terms">Subscription Terms</Link> | 
             <Link to="/privacy">Privacy</Link> | 
             <Link to="/terms">Terms</Link>
          </div>
          <p>&copy; 2026 Invoz. All rights reserved.</p>
        </footer>
      </div>
    </Router>
  )
}

export default App
