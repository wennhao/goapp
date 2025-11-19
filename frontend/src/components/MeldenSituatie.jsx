import React from 'react';
import { situaties } from '../data/buttons';

function MeldenSituatie({ onSituatieClick }) {
  return (
    <div className="page-content">
      <h2>Situatie</h2>
      <div className="situatie-list">
        {situaties.map((situatie) => (
          <button 
            key={situatie.id}
            className="situatie-button"
            onClick={() => onSituatieClick(situatie)}
          >
            <span>{situatie.label}</span>
            <img src="/arrow.png" alt="" className="arrow-icon" />
          </button>
        ))}
      </div>
    </div>
  );
}

export default MeldenSituatie;
