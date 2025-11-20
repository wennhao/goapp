import React, { useRef } from 'react';

function MeldenForm({ selectedSituatie, formData, onFormChange, onSubmit, onBack, onCancel }) {
  const fileInputRef = useRef(null);

  const handlePhotoCapture = (e) => {
    const file = e.target.files[0];
    if (file) {
      onFormChange({ ...formData, photo: file });
    }
  };

  const removePhoto = () => {
    onFormChange({ ...formData, photo: null });
    if (fileInputRef.current) {
      fileInputRef.current.value = '';
    }
  };

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
        <div className="form-group">
          <label>Foto van situatie</label>
          {!formData.photo && (
            <div className="photo-buttons">
              <button type="button" className="btn-secondary" onClick={() => fileInputRef.current?.click()}>
                Maak foto
              </button>
              <input
                ref={fileInputRef}
                type="file"
                accept="image/*"
                capture="environment"
                onChange={handlePhotoCapture}
                style={{ display: 'none' }}
              />
            </div>
          )}
          {formData.photo && (
            <div className="photo-preview">
              <img src={URL.createObjectURL(formData.photo)} alt="Preview" />
              <button type="button" className="btn-remove" onClick={removePhoto}>
                Verwijder foto
              </button>
            </div>
          )}
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
