import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { AnimatePresence } from 'framer-motion';
import { AuthProvider } from './context/AuthContext';
import Navbar from './components/Navbar';
import HomePage from './pages/HomePage';
import AuthPage from './pages/AuthPage';

// Placeholder pages (to be implemented)
const CatalogPage = () => <div className="pt-20 px-4"><h1 className="text-4xl font-bold text-white">Catalog</h1></div>;
const LibraryPage = () => <div className="pt-20 px-4"><h1 className="text-4xl font-bold text-white">Library</h1></div>;
const DownloadsPage = () => <div className="pt-20 px-4"><h1 className="text-4xl font-bold text-white">Downloads</h1></div>;
const ProfilePage = () => <div className="pt-20 px-4"><h1 className="text-4xl font-bold text-white">Profile</h1></div>;

function App() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <div className="min-h-screen bg-dark-950">
          <Navbar />
          <AnimatePresence mode="wait">
            <Routes>
              <Route path="/" element={<HomePage />} />
              <Route path="/login" element={<AuthPage type="login" />} />
              <Route path="/register" element={<AuthPage type="register" />} />
              <Route path="/catalog" element={<CatalogPage />} />
              <Route path="/library" element={<LibraryPage />} />
              <Route path="/downloads" element={<DownloadsPage />} />
              <Route path="/profile" element={<ProfilePage />} />
            </Routes>
          </AnimatePresence>
        </div>
      </AuthProvider>
    </BrowserRouter>
  );
}

export default App;
