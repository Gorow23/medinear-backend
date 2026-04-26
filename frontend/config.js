/*
================================================================
config.js — Frontend Configuration
================================================================
Change API_URL to your Render.com backend URL after deploying.
================================================================
*/

// CHANGE THIS after you deploy backend to Render.com
// During local testing: http://localhost:5000
// After deployment: https://medplus-backend.onrender.com
const API_URL = 'https://medplus-backend.onrender.com/api';

// Helper: get saved token from browser storage
function getToken() {
  return localStorage.getItem('medplus_token');
}

// Helper: get saved user from browser storage
function getUser() {
  const u = localStorage.getItem('medplus_user');
  return u ? JSON.parse(u) : null;
}

// Helper: save login data
function saveAuth(token, user) {
  localStorage.setItem('medplus_token', token);
  localStorage.setItem('medplus_user', JSON.stringify(user));
}

// Helper: clear login data (logout)
function clearAuth() {
  localStorage.removeItem('medplus_token');
  localStorage.removeItem('medplus_user');
}

// Helper: make authenticated API call
async function apiCall(endpoint, method = 'GET', body = null) {
  const headers = { 'Content-Type': 'application/json' };
  const token = getToken();
  if (token) headers['Authorization'] = `Bearer ${token}`;

  const options = { method, headers };
  if (body) options.body = JSON.stringify(body);

  const res = await fetch(`${API_URL}${endpoint}`, options);
  const data = await res.json();

  if (!res.ok) throw new Error(data.error || 'API error');
  return data;
}
