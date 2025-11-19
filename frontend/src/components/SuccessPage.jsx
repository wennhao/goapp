import React from 'react';

function SuccessPage({ onBackToHome }) {
  return (
    <div className="page-content success-page">
      <h2>Gelukt!</h2>
      <p>Uw melding is succesvol verstuurd.</p>
      <button className="btn-primary" onClick={onBackToHome}>
        Terug naar home
      </button>
    </div>
  );
}

export default SuccessPage;
