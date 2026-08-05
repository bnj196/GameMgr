import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import GameCard from '../components/GameCard';
import LoadingScreen from '../components/LoadingScreen';
import { gamesAPI } from '../utils/apiServices';

export default function HomePage() {
  const [loading, setLoading] = useState(true);
  const [games, setGames] = useState([]);
  const [featuredGames, setFeaturedGames] = useState([]);
  
  useEffect(() => {
    fetchGames();
  }, []);

  const fetchGames = async () => {
    try {
      const response = await gamesAPI.getGames();
      // Backend returns: { success, code, message, data: { items: [...] } }
      const allGames = response.data.data?.items || [];
      
      // Shuffle and pick featured games
      const shuffled = [...allGames].sort(() => 0.5 - Math.random());
      setFeaturedGames(shuffled.slice(0, 6));
      setGames(allGames);
    } catch (error) {
      console.error('Failed to fetch games:', error.message || error);
      // Mock data for demo
      const mockGames = [
        { id: '1', name: 'Cyber Adventure', genres: ['Action', 'RPG'], platforms: ['Windows', 'Linux'], pricing: { type: 'paid', price: 29.99, currency: 'USD' }, badge: 'New', media: { thumbnail: 'https://picsum.photos/seed/game1/600/800', banner: 'https://picsum.photos/seed/game1_b/1200/500' }, ownership: { owned: false } },
        { id: '2', name: 'Space Explorer', genres: ['Adventure', 'Sci-Fi'], platforms: ['Windows', 'macOS'], pricing: { type: 'free', price: 0, currency: 'USD' }, badge: 'Free', media: { thumbnail: 'https://picsum.photos/seed/game2/600/800', banner: 'https://picsum.photos/seed/game2_b/1200/500' }, ownership: { owned: false } },
        { id: '3', name: 'Racing Pro', genres: ['Racing', 'Sports'], platforms: ['Windows'], pricing: { type: 'paid', price: 49.99, currency: 'USD' }, badge: 'Popular', media: { thumbnail: 'https://picsum.photos/seed/game3/600/800', banner: 'https://picsum.photos/seed/game3_b/1200/500' }, ownership: { owned: false } },
        { id: '4', name: 'Puzzle Master', genres: ['Puzzle', 'Casual'], platforms: ['Windows', 'macOS', 'Linux'], pricing: { type: 'paid', price: 9.99, currency: 'USD' }, badge: null, media: { thumbnail: 'https://picsum.photos/seed/game4/600/800', banner: 'https://picsum.photos/seed/game4_b/1200/500' }, ownership: { owned: false } },
        { id: '5', name: 'Fantasy World', genres: ['RPG', 'Fantasy'], platforms: ['Windows'], pricing: { type: 'paid', price: 59.99, currency: 'USD' }, badge: 'Hot', media: { thumbnail: 'https://picsum.photos/seed/game5/600/800', banner: 'https://picsum.photos/seed/game5_b/1200/500' }, ownership: { owned: false } },
        { id: '6', name: 'Strategy Empire', genres: ['Strategy', 'Simulation'], platforms: ['Windows', 'Linux'], pricing: { type: 'paid', price: 39.99, currency: 'USD' }, badge: null, media: { thumbnail: 'https://picsum.photos/seed/game6/600/800', banner: 'https://picsum.photos/seed/game6_b/1200/500' }, ownership: { owned: false } },
      ];
      setFeaturedGames(mockGames);
      setGames(mockGames);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <LoadingScreen />;
  }

  return (
    <div className="min-h-screen pt-16">
      {/* Hero Section */}
      <motion.section
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ duration: 0.8 }}
        className="relative min-h-[80vh] flex items-center justify-center overflow-hidden"
      >
        {/* Animated Background */}
        <div className="absolute inset-0 bg-gradient-to-br from-dark-950 via-dark-900 to-dark-800">
          {[...Array(30)].map((_, i) => (
            <motion.div
              key={i}
              initial={{ 
                opacity: 0,
                x: Math.random() * window.innerWidth,
                y: Math.random() * window.innerHeight,
              }}
              animate={{ 
                opacity: [0.2, 0.5, 0.2],
                y: [null, Math.random() * -100 - 50],
              }}
              transition={{ 
                duration: Math.random() * 3 + 2,
                repeat: Infinity,
                ease: "easeInOut",
                delay: Math.random() * 2,
              }}
              className="absolute w-1 h-1 bg-primary-500/30 rounded-full"
            />
          ))}
          
          <motion.div
            animate={{ scale: [1, 1.2, 1], opacity: [0.3, 0.5, 0.3] }}
            transition={{ duration: 8, repeat: Infinity }}
            className="absolute top-1/4 left-1/4 w-96 h-96 bg-primary-500/20 rounded-full blur-3xl"
          />
          <motion.div
            animate={{ scale: [1.2, 1, 1.2], opacity: [0.3, 0.5, 0.3] }}
            transition={{ duration: 10, repeat: Infinity, delay: 1 }}
            className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-accent-500/20 rounded-full blur-3xl"
          />
        </div>

        {/* Content */}
        <div className="relative z-10 text-center px-4">
          <motion.h1
            initial={{ opacity: 0, y: 50 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.2 }}
            className="text-5xl md:text-7xl font-display font-bold mb-6"
          >
            <span className="text-white">Welcome to</span>
            <br />
            <span className="text-gradient">GameHub</span>
          </motion.h1>
          
          <motion.p
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.4 }}
            className="text-xl text-gray-300 mb-12 max-w-2xl mx-auto"
          >
            Your ultimate gaming platform. Discover, collect, and play thousands of games.
          </motion.p>
          
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.6 }}
            className="flex gap-4 justify-center"
          >
            <motion.a
              href="#featured"
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              className="px-8 py-4 bg-gradient-to-r from-primary-500 to-accent-500 text-white font-semibold rounded-xl shadow-2xl glow-primary"
            >
              Explore Games
            </motion.a>
          </motion.div>
        </div>
      </motion.section>

      {/* Featured Games Section */}
      <section id="featured" className="py-20 px-4">
        <div className="max-w-7xl mx-auto">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6 }}
            className="text-center mb-16"
          >
            <h2 className="text-4xl md:text-5xl font-display font-bold text-white mb-4">
              Featured Games
            </h2>
            <p className="text-gray-400 text-lg">
              Handpicked selections just for you
            </p>
          </motion.div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {featuredGames.map((game, index) => (
              <GameCard key={game.id} game={game} index={index} />
            ))}
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-20 px-4 bg-dark-900/50">
        <div className="max-w-7xl mx-auto">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6 }}
            className="text-center mb-16"
          >
            <h2 className="text-4xl md:text-5xl font-display font-bold text-white mb-4">
              Why Choose GameHub?
            </h2>
          </motion.div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            {[
              {
                title: 'Vast Library',
                description: 'Access thousands of games across all genres',
                icon: '🎮',
              },
              {
                title: 'Cross-Platform',
                description: 'Play on Windows, macOS, Linux, and mobile',
                icon: '💻',
              },
              {
                title: 'Great Prices',
                description: 'Competitive pricing with frequent sales',
                icon: '💰',
              },
            ].map((feature, index) => (
              <motion.div
                key={feature.title}
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ delay: index * 0.1, duration: 0.5 }}
                whileHover={{ y: -10, scale: 1.02 }}
                className="glass-card p-8 rounded-2xl text-center"
              >
                <div className="text-5xl mb-4">{feature.icon}</div>
                <h3 className="text-2xl font-display font-bold text-white mb-2">
                  {feature.title}
                </h3>
                <p className="text-gray-400">{feature.description}</p>
              </motion.div>
            ))}
          </div>
        </div>
      </section>
    </div>
  );
}
