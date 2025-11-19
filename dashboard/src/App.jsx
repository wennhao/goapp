import React, { useState, useEffect, useRef } from 'react';
import './App.css';

function App() {
  const [messages, setMessages] = useState([]);
  const [connectionStatus, setConnectionStatus] = useState('Disconnected');
  const [showRawJson, setShowRawJson] = useState(false);
  const wsRef = useRef(null);

  useEffect(() => {
    const connectWebSocket = () => {
      const ws = new WebSocket('ws://localhost:3001');
      wsRef.current = ws;

      ws.onopen = () => {
        console.log('Connected to backend');
        setConnectionStatus('Connected');
      };

      ws.onmessage = (event) => {
        try {
          const data = JSON.parse(event.data);
          console.log('Received:', data);

          if (data.type === 'mqtt-message') {
            const payload = JSON.parse(data.payload);
            setMessages(prev => [{
              ...payload,
              id: Date.now(),
              receivedAt: new Date().toLocaleString('nl-NL')
            }, ...prev]);
          }
        } catch (error) {
          console.error('Error parsing message:', error);
        }
      };

      ws.onerror = (error) => {
        console.error('WebSocket error:', error);
        setConnectionStatus('Error');
      };

      ws.onclose = () => {
        console.log('Disconnected from backend');
        setConnectionStatus('Disconnected');
        setTimeout(connectWebSocket, 3000);
      };
    };

    connectWebSocket();

    return () => {
      if (wsRef.current) {
        wsRef.current.close();
      }
    };
  }, []);

  const getActionColor = (action) => {
    switch (action) {
      case 'melden':
        return '#ff6b6b';
      case 'compass':
        return '#4facfe';
      default:
        return '#757575';
    }
  };

  const clearMessages = () => {
    setMessages([]);
  };

  return (
    <div className="dashboard">
      <header className="dashboard-header">
        <h1>Dashboard</h1>
        <div className="status-bar">
          <span className={`status ${connectionStatus.toLowerCase()}`}>
            {connectionStatus}
          </span>
          <span className="message-count">
            {messages.length} berichten
          </span>
        </div>
      </header>

      <div className="dashboard-controls">
        <button onClick={clearMessages} className="clear-btn">
          Wis berichten
        </button>
        <button onClick={() => setShowRawJson(!showRawJson)} className="toggle-btn">
          {showRawJson ? 'Toon Overzicht' : 'Toon Raw JSON'}
        </button>
      </div>

      <main className="dashboard-main">
        {messages.length === 0 ? (
          <div className="empty-state">
            <p>Nog geen berichten ontvangen</p>
            <p className="empty-hint">Druk op een knop in de app om te beginnen</p>
          </div>
        ) : (
          <div className="messages-grid">
            {messages.map((msg) => (
              <div
                key={msg.id}
                className="message-card"
                style={{ borderLeftColor: getActionColor(msg.action) }}
              >
                <div className="message-header">
                  <span className="message-action" style={{ color: getActionColor(msg.action) }}>
                    {msg.action.toUpperCase()}
                  </span>
                  <span className="message-time">{msg.receivedAt}</span>
                </div>
                <div className="message-body">
                  {showRawJson ? (
                    <div className="message-data">
                      <pre>{JSON.stringify(msg, null, 2)}</pre>
                    </div>
                  ) : (
                    <>
                      <div className="message-timestamp">
                        {new Date(msg.timestamp).toLocaleString('nl-NL')}
                      </div>
                      {msg.data && (
                        <div className="message-details">
                          {msg.data.situatie && (
                            <div className="detail-row">
                              <span className="detail-label">Situatie:</span>
                              <span className="detail-value">{msg.data.situatie}</span>
                            </div>
                          )}
                          {msg.data.naam && (
                            <div className="detail-row">
                              <span className="detail-label">Naam:</span>
                              <span className="detail-value">{msg.data.naam}</span>
                            </div>
                          )}
                          {msg.data.projectnaam && (
                            <div className="detail-row">
                              <span className="detail-label">Project:</span>
                              <span className="detail-value">{msg.data.projectnaam}</span>
                            </div>
                          )}
                          {msg.data.omschrijving && (
                            <div className="detail-row">
                              <span className="detail-label">Omschrijving:</span>
                              <span className="detail-value">{msg.data.omschrijving}</span>
                            </div>
                          )}
                          {msg.data.device && (
                            <div className="detail-row">
                              <span className="detail-label">Apparaat:</span>
                              <span className="detail-value">{msg.data.device}</span>
                            </div>
                          )}
                        </div>
                      )}
                    </>
                  )}
                </div>
              </div>
            ))}
          </div>
        )}
      </main>
    </div>
  );
}

export default App;
