import React from 'react'
import { BrowserRouter as Router, Routes, Route, Link } from 'react-router-dom'
import PrivacyPolicy from './pages/PrivacyPolicy'
import TermsConditions from './pages/TermsConditions'
import Faqs from './pages/Faqs'
import './App.css'

function App() {
  return (
    <Router>
      <div className="app-container">
        <nav className="navbar">
          <div className="nav-brand">Invoz Legal</div>
          <div className="nav-links">
            <Link to="/privacy">Privacy Policy</Link>
            <Link to="/terms">Terms & Conditions</Link>
            <Link to="/faq">FAQs</Link>
          </div>
        </nav>

        <main className="main-content">
          <Routes>
            <Route path="/" element={<Faqs />} />
            <Route path="/privacy" element={<PrivacyPolicy />} />
            <Route path="/terms" element={<TermsConditions />} />
            <Route path="/faq" element={<Faqs />} />
          </Routes>
        </main>

        <footer className="footer">
          <p>&copy; 2026 Invoz. All rights reserved.</p>
        </footer>
      </div>
    </Router>
  )
}

export default App
