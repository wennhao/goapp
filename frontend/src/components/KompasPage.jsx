import React from 'react';

function KompasPage() {
  return (
    <div className="page-content kompas-page">
      <h2>GO! Kompas</h2>
      
      <div className="kompas-content">
        <img 
          src="/kompas.jpeg" 
          alt="GO! Kompas" 
          className="kompas-image"
        />
        
        <hr className="kompas-divider" />
        
        <div className="kompas-text">
          <p>
            In 2013 is Heijmans gestart met het Geen-ongevallen programma. Sindsdien hebben we er met zijn allen voor gezorgd dat veiligheid een belangrijk onderwerp is bij Heijmans. Maar we zijn er nog niet.
          </p>
          
          <p>
            We zullen proactief moeten zijn om toekomstige ongevallen te gaan voorkomen. Uit al onze gesprekken die wij de afgelopen periode hebben gevoerd ontstond de behoefte om helder te maken wat die proactieve organisatie/werkwijze nu is en wat we daarbij van elkaar mogen verwachten. Daaruit is het GO! Kompas uit voortgekomen.
          </p>
          
          <p>
            Het GO! Kompas maakt concreet wat proactief gedrag is en geeft de richting aan: dit is hoe wij veilig willen werken. Dit is de juiste koers!
          </p>
          
          <p>
            In het GO! kompas vind je onze afspraken en jouw rol in GO! in het kompas terug. En wij dagen jou uit om voor jezelf na te gaan: laat ik dit gedrag eigenlijk al zien? Of kan het beter?
          </p>
        </div>
      </div>
    </div>
  );
}

export default KompasPage;
