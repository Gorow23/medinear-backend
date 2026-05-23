// ================= CONFIG =================

// For LOCAL testing
const API_BASE = "http://127.0.0.1:8000";

// ================= AUTH =================

function getToken() {
  return localStorage.getItem('medplus_token');
}

function saveAuth(token, user) {
  localStorage.setItem('medplus_token', token);
  localStorage.setItem('medplus_user', JSON.stringify(user));
}

function clearAuth() {
  localStorage.removeItem('medplus_token');
  localStorage.removeItem('medplus_user');
}

// ================= API CALL =================

async function apiCall(endpoint, method = 'GET', body = null) {
  const headers = { 'Content-Type': 'application/json' };

  const token = getToken();
  if (token) headers['Authorization'] = `Bearer ${token}`;

  const options = { method, headers };
  if (body) options.body = JSON.stringify(body);

  const res = await fetch(`${API_BASE}${endpoint}`, options);
  const data = await res.json();

  if (!res.ok) throw new Error(data.detail || 'API error');
  return data;
}