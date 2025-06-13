import React, { useEffect, useState } from "react";
import "./App.css";

const backendUrl = process.env.REACT_APP_BACKEND_URL || "http://localhost:8000";

function App() {
  const [health, setHealth] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetch(`${backendUrl}/health`)
      .then((res) => res.json())
      .then((data) => {
        setHealth(data);
        setLoading(false);
      })
      .catch((err) => {
        setError("Could not fetch health check");
        setLoading(false);
      });
  }, []);

  return (
    <div className="container">
      <h1>🚀 AWS ECS Demo App Health Check</h1>
      {loading && <p className="loading">Loading health status...</p>}
      {error && <p className="error">{error}</p>}
      {health && (
        <div className="health-card">
          <h2>Status: <span className="status-ok">{health.status}</span></h2>
          <p>{health.message}</p>
        </div>
      )}
    </div>
  );
}

export default App;
