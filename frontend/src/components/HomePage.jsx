import React from 'react';
import { buttons } from '../data/buttons';
import TileButton from './TileButton';

function HomePage({ onButtonClick }) {
  return (
    <div className="button-grid">
      {buttons.map((button) => (
        <TileButton
          key={button.id}
          id={button.id}
          label={button.label}
          icon={button.icon}
          onClick={() => button.hasAction && onButtonClick(button.id)}
          backgroundColor={button.backgroundColor}
          textColor={button.textColor}
        />
      ))}
    </div>
  );
}

export default HomePage;
