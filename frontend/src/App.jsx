import React, { useState, useEffect } from 'react';
import './App.css';
import HomePage from './components/HomePage';
import MeldenSituatie from './components/MeldenSituatie';
import MeldenForm from './components/MeldenForm';
import SuccessPage from './components/SuccessPage';
import KompasPage from './components/KompasPage';
import virtualKeyboard from './utils/virtualKeyboard';

const BACKEND_URL = import.meta.env.VITE_BACKEND_URL || 'http://localhost:3001';

function App() {
  const [connectionStatus, setConnectionStatus] = useState('Disconnected');
  const [menuOpen, setMenuOpen] = useState(false);
  const [currentPage, setCurrentPage] = useState(() => {
    return localStorage.getItem('currentPage') || 'home';
  });
  const [selectedSituatie, setSelectedSituatie] = useState(() => {
    const saved = localStorage.getItem('selectedSituatie');
    return saved ? JSON.parse(saved) : null;
  });
  const [formData, setFormData] = useState(() => {
    const saved = localStorage.getItem('formData');
    return saved ? JSON.parse(saved) : {
      naam: '',
      projectnaam: 'Escape Room',
      omschrijving: '',
      photo: null
    };
  });

  // Initialize virtual keyboard on mount
  useEffect(() => {
    console.log('Virtual keyboard initialized');
    // The keyboard manager is automatically initialized as a singleton
  }, []);

  // Save state to localStorage whenever it changes
  useEffect(() => {
    localStorage.setItem('currentPage', currentPage);
  }, [currentPage]);

  useEffect(() => {
    if (selectedSituatie) {
      localStorage.setItem('selectedSituatie', JSON.stringify(selectedSituatie));
    } else {
      localStorage.removeItem('selectedSituatie');
    }
  }, [selectedSituatie]);

  useEffect(() => {
    const dataToSave = { ...formData, photo: null }; // Don't save photo file
    localStorage.setItem('formData', JSON.stringify(dataToSave));
  }, [formData]);

  const handleButtonClick = async (buttonId) => {
    console.log(`${buttonId} button clicked`);
    
    // Navigate to page
    if (buttonId === 'melden' || buttonId === 'kompas') {
      setCurrentPage(buttonId);
      return;
    }
    
    try {
      const response = await fetch(`${BACKEND_URL}/api/action/${buttonId}`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          device: 'mobile-app'
        })
      });
      
      const data = await response.json();
      if (data.success) {
        console.log(`${buttonId} verzonden!`);
      }
    } catch (error) {
      console.error('Error:', error);
    }
  };

  const handleSituatieClick = (situatie) => {
    setSelectedSituatie(situatie);
    setCurrentPage('melden-form');
  };

  const handleFormSubmit = async (e) => {
    e.preventDefault();
    console.log('Form submitted:', { ...formData, situatie: selectedSituatie.label });
    
    try {
      const formDataToSend = new FormData();
      formDataToSend.append('situatie', selectedSituatie.label);
      formDataToSend.append('naam', formData.naam);
      formDataToSend.append('projectnaam', formData.projectnaam);
      formDataToSend.append('omschrijving', formData.omschrijving);
      formDataToSend.append('device', 'mobile-app');
      
      if (formData.photo) {
        formDataToSend.append('photo', formData.photo);
      }

      const response = await fetch(`${BACKEND_URL}/api/action/melden`, {
        method: 'POST',
        body: formDataToSend
      });
      
      const data = await response.json();
      if (data.success) {
        setCurrentPage('success');
      }
    } catch (error) {
      console.error('Error:', error);
    }
  };

  const handleCancel = () => {
    setFormData({ naam: '', projectnaam: 'Escape Room', omschrijving: '', photo: null });
    setSelectedSituatie(null);
    setCurrentPage('home');
    localStorage.removeItem('formData');
    localStorage.removeItem('selectedSituatie');
    localStorage.setItem('currentPage', 'home');
  };

  const handleBack = () => {
    if (currentPage === 'melden-form') {
      setCurrentPage('melden');
      setSelectedSituatie(null);
      localStorage.removeItem('selectedSituatie');
    } else if (currentPage === 'success') {
      setCurrentPage('home');
      setFormData({ naam: '', projectnaam: 'Escape Room', omschrijving: '', photo: null });
      setSelectedSituatie(null);
      localStorage.removeItem('formData');
      localStorage.removeItem('selectedSituatie');
      localStorage.setItem('currentPage', 'home');
    } else {
      setCurrentPage('home');
      localStorage.setItem('currentPage', 'home');
    }
  };

  const handleBackToHome = () => {
    setCurrentPage('home');
    setFormData({ naam: '', projectnaam: 'Escape Room', omschrijving: '' });
    setSelectedSituatie(null);
  };

  useEffect(() => {
    fetch(`${BACKEND_URL}/api/health`)
      .then(res => res.json())
      .then(data => {
        if (data.mqtt === 'connected') {
          setConnectionStatus('Connected');
        }
      })
      .catch(() => setConnectionStatus('Error'));
  }, []);

  return (
    <div className="app">
      <header className="app-header">
        <button className="menu-button" onClick={() => setMenuOpen(!menuOpen)}>
          <span className="menu-icon"></span>
          <span className="menu-icon"></span>
          <span className="menu-icon"></span>
        </button>
        {currentPage !== 'home' && (
          <button className="back-button" onClick={handleBack}>
            ← Terug
          </button>
        )}
      </header>
      <main className="app-main">
        {currentPage === 'home' && <HomePage onButtonClick={handleButtonClick} />}
        {currentPage === 'melden' && <MeldenSituatie onSituatieClick={handleSituatieClick} />}
        {currentPage === 'melden-form' && (
          <MeldenForm 
            selectedSituatie={selectedSituatie}
            formData={formData}
            onFormChange={setFormData}
            onSubmit={handleFormSubmit}
            onBack={handleBack}
            onCancel={handleCancel}
          />
        )}
        {currentPage === 'success' && <SuccessPage onBackToHome={handleBackToHome} />}
        {currentPage === 'kompas' && <KompasPage />}
      </main>
    </div>
  );
}

export default App;
