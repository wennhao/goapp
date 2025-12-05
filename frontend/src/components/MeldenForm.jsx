import React from 'react';

function MeldenForm({ selectedSituatie, formData, onFormChange, onSubmit, onBack, onCancel }) {
  return (
    <div className="page-content">
      <h2>{selectedSituatie.label}</h2>
      <form className="melden-form" onSubmit={onSubmit}>
        <div className="form-group">
          <label htmlFor="naam">Naam</label>
          <input
            type="text"
            id="naam"
            value={formData.naam}
            onChange={(e) => onFormChange({ ...formData, naam: e.target.value })}
            required
          />
        </div>
        <div className="form-group">
          <label htmlFor="projectnaam">Projectnaam</label>
          <input
            type="text"
            id="projectnaam"
            value={formData.projectnaam}
            disabled
            className="disabled-input"
          />
        </div>
        <div className="form-group">
          <label htmlFor="omschrijving">Omschrijving</label>
          <textarea
            id="omschrijving"
            value={formData.omschrijving}
            onChange={(e) => onFormChange({ ...formData, omschrijving: e.target.value })}
            rows="5"
            required
          />
        </div>
        <div className="form-buttons">
          <button type="submit" className="btn-primary">Versturen</button>
          <button type="button" className="btn-secondary" onClick={onCancel}>Annuleren</button>
        </div>
      </form>
    </div>
  );
}

export default MeldenForm;
