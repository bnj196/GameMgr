import { motion } from 'framer-motion';

export default function GameCard({ game, index = 0 }) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 30 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ 
        delay: index * 0.1, 
        duration: 0.4,
        ease: [0.23, 1, 0.32, 1]
      }}
      whileHover={{ 
        y: -8, 
        scale: 1.02,
        transition: { duration: 0.2 }
      }}
      className="group relative glass-card rounded-xl overflow-hidden cursor-pointer"
    >
      {/* Image Container */}
      <div className="relative aspect-video overflow-hidden">
        <img
          src={game.image_url || 'https://via.placeholder.com/400x225/1e293b/64748b?text=No+Image'}
          alt={game.name}
          className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-110"
          loading="lazy"
        />
        
        {/* Overlay Gradient */}
        <div className="absolute inset-0 bg-gradient-to-t from-dark-900 via-transparent to-transparent opacity-60 group-hover:opacity-80 transition-opacity" />
        
        {/* Badge */}
        {game.badge && (
          <motion.div
            initial={{ scale: 0 }}
            animate={{ scale: 1 }}
            transition={{ delay: index * 0.1 + 0.3, type: "spring", stiffness: 500 }}
            className="absolute top-3 right-3 px-3 py-1 bg-accent-500 text-white text-xs font-bold rounded-full shadow-lg"
          >
            {game.badge}
          </motion.div>
        )}
        
        {/* Play Button Overlay */}
        <motion.div
          initial={{ opacity: 0 }}
          whileHover={{ opacity: 1 }}
          className="absolute inset-0 flex items-center justify-center"
        >
          <motion.div
            whileHover={{ scale: 1.1 }}
            whileTap={{ scale: 0.9 }}
            className="w-16 h-16 rounded-full bg-primary-500/90 flex items-center justify-center shadow-2xl glow-primary"
          >
            <svg className="w-8 h-8 text-white ml-1" fill="currentColor" viewBox="0 0 24 24">
              <path d="M8 5v14l11-7z" />
            </svg>
          </motion.div>
        </motion.div>
      </div>

      {/* Content */}
      <div className="p-4">
        <h3 className="font-display font-semibold text-lg text-white mb-2 line-clamp-1 group-hover:text-primary-400 transition-colors">
          {game.name}
        </h3>
        
        {/* Genres */}
        <div className="flex flex-wrap gap-2 mb-3">
          {game.genres?.slice(0, 3).map((genre, i) => (
            <span
              key={i}
              className="px-2 py-1 bg-white/10 text-gray-300 text-xs rounded-md"
            >
              {genre}
            </span>
          ))}
        </div>
        
        {/* Platforms */}
        <div className="flex items-center gap-2 mb-3">
          {game.platforms?.map((platform, i) => (
            <span
              key={i}
              className="text-gray-400 text-xs"
              title={platform}
            >
              {platform === 'Windows' && '🪟'}
              {platform === 'macOS' && '🍎'}
              {platform === 'Linux' && '🐧'}
              {platform === 'Android' && '📱'}
              {platform === 'iOS' && '📲'}
            </span>
          ))}
        </div>
        
        {/* Price and Action */}
        <div className="flex items-center justify-between">
          <div className="text-primary-400 font-bold text-lg">
            {game.price === 0 ? (
              <span className="text-green-400">Free</span>
            ) : (
              `$${game.price}`
            )}
          </div>
          
          <motion.button
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            className="px-4 py-2 bg-gradient-to-r from-primary-500 to-accent-500 text-white text-sm font-semibold rounded-lg shadow-lg glow-primary"
          >
            Get
          </motion.button>
        </div>
      </div>
    </motion.div>
  );
}
