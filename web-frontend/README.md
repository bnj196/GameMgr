# GameHub Web Frontend

Modern, responsive web frontend for GameHub gaming platform built with React, Framer Motion, and Tailwind CSS.

## Features

- 🎮 **Gaming Platform UI** - Modern dark theme with glassmorphism effects
- ✨ **Motion Graphics** - Smooth animations following choreography principles
- 🔐 **Authentication** - Login/Register with JWT tokens
- 📱 **Responsive Design** - Works on desktop, tablet, and mobile
- 🎨 **Custom Design System** - Primary (blue) and Accent (purple) color schemes

## Tech Stack

- **React 19** - UI library
- **Framer Motion** - Animation library
- **Tailwind CSS** - Utility-first CSS
- **React Router** - Client-side routing
- **Axios** - HTTP client
- **Lucide React** - Icon library

## Getting Started

### Prerequisites

- Node.js 18+ 
- npm or yarn

### Installation

```bash
cd web-frontend
npm install
```

### Development

```bash
# Start development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

The app will be available at `http://localhost:3000`

## Project Structure

```
src/
├── components/       # Reusable UI components
│   ├── Navbar.jsx
│   ├── GameCard.jsx
│   ├── HeroSection.jsx
│   └── LoadingScreen.jsx
├── pages/           # Page components
│   ├── HomePage.jsx
│   └── AuthPage.jsx
├── context/         # React Context providers
│   └── AuthContext.jsx
├── hooks/           # Custom hooks
├── utils/           # Utility functions
└── assets/          # Static assets
```

## Design Principles

### Motion Choreography

Following the provided motion design guidelines:

1. **Lead with the Hero** - Hero elements get largest displacement
2. **Spatial Origin Consistency** - All elements enter from same direction
3. **Counter-Motion** - Background moves opposite to foreground
4. **Stagger Patterns** - Sequential, center-out, and wave patterns
5. **Depth Through Speed** - Foreground faster than background

### Accessibility

- Respects `prefers-reduced-motion`
- Keyboard navigation support
- Semantic HTML structure
- Color contrast compliance

## API Integration

Connects to GameHub backend at `http://localhost:8000/api`

Configure via environment variable:
```bash
VITE_API_URL=http://your-api-url.com/api
```

## Pages

- **Home** (`/`) - Hero section with featured games
- **Login** (`/login`) - User authentication
- **Register** (`/register`) - New user registration
- **Catalog** (`/catalog`) - Browse all games
- **Library** (`/library`) - User's game collection
- **Downloads** (`/downloads`) - Download manager
- **Profile** (`/profile`) - User settings

## License

ISC
