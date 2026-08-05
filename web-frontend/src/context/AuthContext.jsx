import { createContext, useContext, useState, useEffect } from 'react';
import { authAPI, userAPI } from '../utils/apiServices';

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [token, setToken] = useState(localStorage.getItem('token'));
  
  useEffect(() => {
    if (token) {
      localStorage.setItem('token', token);
      fetchUser();
    } else {
      setLoading(false);
    }
  }, [token]);

  const fetchUser = async () => {
    try {
      const response = await userAPI.getCurrentUser();
      // Backend returns: { success, code, message, data: { id, email, displayName, avatarUrl } }
      setUser(response.data.data);
    } catch (error) {
      console.error('Failed to fetch user:', error.message || error);
      logout();
    } finally {
      setLoading(false);
    }
  };

  const login = async (email, password) => {
    try {
      const response = await authAPI.login(email, password);
      // Backend returns: { success, code, message, data: { accessToken, refreshToken } }
      const accessToken = response.data.data.accessToken;
      localStorage.setItem('token', accessToken);
      setToken(accessToken);
      await fetchUser();
      return response.data;
    } catch (error) {
      throw new Error(error.message || 'Login failed');
    }
  };

  const register = async (email, username, password) => {
    try {
      const response = await authAPI.register(email, username, password);
      return response.data;
    } catch (error) {
      throw new Error(error.message || 'Registration failed');
    }
  };

  const logout = () => {
    localStorage.removeItem('token');
    setToken(null);
    setUser(null);
  };

  const value = {
    user,
    loading,
    login,
    register,
    logout,
    isAuthenticated: !!user,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
