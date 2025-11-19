import React from 'react';

function TileButton({ 
  id, 
  label, 
  icon, 
  onClick, 
  backgroundColor = '#e6ecf8',
  textColor = '#333',
  size = 192,
  fontSize = '1rem',
  labelHeight = 32,
  disabled = false
}) {
  return (
    <div className="tile-wrapper" style={{ width: size, height: size }}>
      <button 
        className="tile-button" 
        onClick={onClick}
        disabled={disabled}
        style={{ 
          width: size, 
          height: size,
          backgroundColor: backgroundColor 
        }}
      >
        <div className="tile-icon" style={{ width: size, height: size }}>
          <img src={icon} alt={label} className="tile-icon-img" />
        </div>
      </button>
      <span 
        className="tile-label" 
        style={{ 
          width: size,
          height: labelHeight,
          backgroundColor: backgroundColor,
          color: textColor,
          fontSize: fontSize
        }}
      >
        {label}
      </span>
    </div>
  );
}

export default TileButton;
