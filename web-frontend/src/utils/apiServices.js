import apiClient from './api';

export const authAPI = {
  login: (email, password) => 
    apiClient.post('/auth/login', { email, password }),
  
  register: (email, username, password) => 
    apiClient.post('/auth/register', { email, username, password }),
};

export const userAPI = {
  getCurrentUser: () => 
    apiClient.get('/users/me'),
};

export const gamesAPI = {
  getGames: (query = '') => 
    apiClient.get(`/games${query ? `?q=${encodeURIComponent(query)}` : ''}`),
  
  getGameById: (gameId) => 
    apiClient.get(`/games/${gameId}`),
  
  getDownloadUrl: (gameId) => 
    apiClient.get(`/games/${gameId}/download-url`),
};

export const libraryAPI = {
  getLibrary: () => 
    apiClient.get('/library'),
  
  addToLibrary: (gameId) => 
    apiClient.post(`/library/${gameId}`),
  
  removeFromLibrary: (gameId) => 
    apiClient.delete(`/library/${gameId}`),
};
