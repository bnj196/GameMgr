# 🎮 GameHub Web Frontend - Thiết kế & Xây dựng

## 📋 Tổng quan

Website GameHub đã được xây dựng với **React + Vite + Tailwind CSS + Framer Motion**, áp dụng các nguyên tắc **Motion Choreography** bạn đã cung cấp.

## ✨ Tính năng đã triển khai

### 1. **Trang chủ (HomePage)**
- Hero section với animated background particles
- Featured games grid với stagger animations
- Features section với hover effects
- Loading screen với animated logo

### 2. **Authentication (AuthPage)**
- Login/Register forms với motion transitions
- Form validation
- Password visibility toggle
- Error handling với animations

### 3. **Components**
- **Navbar**: Fixed navigation với mobile menu, animated logo
- **GameCard**: Card component với hover effects, badges, platform icons
- **HeroSection**: Full-screen hero với floating particles, gradient orbs
- **LoadingScreen**: Animated loading state

## 🎨 Design System

### Màu sắc
```javascript
primary: { 50-950 }  // Xanh dương (#0ea5e9)
accent: { 50-950 }   // Tím (#d946ef)
dark: { 50-950 }     // Xám đen (#0f172a)
```

### Typography
- **Display**: Poppins (headings)
- **Body**: Inter (content)

### Effects
- Glassmorphism cards
- Gradient text
- Glow shadows
- Smooth transitions

## 🎭 Motion Choreography Implementation

### Nguyên tắc đã áp dụng:

#### 1. **Lead with the Hero**
```jsx
// Hero gets largest displacement
<motion.h1
  initial={{ opacity: 0, y: 50 }}
  animate={{ opacity: 1, y: 0 }}
  transition={{ duration: 0.8, delay: 0.4 }}
/>
```

#### 2. **Spatial Origin Consistency**
- Tất cả elements enter từ cùng hướng (top hoặc bottom)
- Không mixed directions

#### 3. **Stagger Patterns**
```jsx
// Sequential stagger cho game cards
{games.map((game, index) => (
  <GameCard 
    key={game.id} 
    game={game} 
    index={index} // Dùng để delay animation
  />
))}
```

#### 4. **Sequence Structure**
- **Setup (20-30%)**: Elements fade in
- **Action (30-40%)**: Primary motion
- **Resolution (30-40%)**: Settle into place

#### 5. **Depth Through Speed**
```jsx
// Foreground - Fastest
foreground: { duration: 0.3 }

// Midground - Medium  
midground: { duration: 0.5 }

// Background - Slowest
background: { duration: 0.8 }
```

### Easing Functions
```javascript
// Custom ease-out cho professional feel
ease: [0.23, 1, 0.32, 1]

// Spring cho interactive elements
type: "spring", stiffness: 300, damping: 15
```

## 📁 Cấu trúc dự án

```
web-frontend/
├── src/
│   ├── components/
│   │   ├── Navbar.jsx          # Navigation bar
│   │   ├── GameCard.jsx        # Game display card
│   │   ├── HeroSection.jsx     # Hero banner
│   │   └── LoadingScreen.jsx   # Loading state
│   ├── pages/
│   │   ├── HomePage.jsx        # Home page
│   │   └── AuthPage.jsx        # Login/Register
│   ├── context/
│   │   └── AuthContext.jsx     # Auth state management
│   ├── App.jsx                 # Main app component
│   ├── main.jsx                # Entry point
│   └── index.css               # Global styles
├── tailwind.config.cjs         # Tailwind config
├── postcss.config.cjs          # PostCSS config
├── vite.config.js              # Vite config
└── package.json
```

## 🚀 Chạy dự án

### Yêu cầu
- Node.js 18+
- Backend GameHub đang chạy tại port 8000

### Cài đặt
```bash
cd web-frontend
npm install
```

### Development
```bash
npm run dev
```
Truy cập: `http://localhost:3000`

### Production Build
```bash
npm run build
npm run preview
```

## 🔌 API Integration

Kết nối với backend tại `http://localhost:8000/api`

Endpoints sử dụng:
- `POST /api/auth/login` - User login
- `POST /api/auth/register` - User registration
- `GET /api/users/me` - Get current user
- `GET /api/games` - Get all games

## ♿ Accessibility

### Reduced Motion Support
```jsx
// Tự động detect prefers-reduced-motion
@media (prefers-reduced-motion: reduce) {
  // Framer Motion tự động disable animations
}
```

### Features
- Keyboard navigation
- Semantic HTML
- ARIA labels
- Color contrast compliance (WCAG AA)

## 📱 Responsive Design

| Breakpoint | Width | Layout |
|------------|-------|--------|
| Mobile | < 640px | Single column |
| Tablet | 640-1024px | 2 columns |
| Desktop | > 1024px | 3 columns |

### Platform Scaling
```javascript
// Mobile: reduced duration
mobile: { duration: 0.8x }

// Desktop: full duration
desktop: { duration: 1.0x }
```

## 🎯 Next Steps (Có thể mở rộng)

1. **Catalog Page** - Browse all games với filters/sort
2. **Library Page** - User's owned games
3. **Game Detail Page** - Individual game info
4. **Download Manager** - Track download progress
5. **Profile Page** - User settings & preferences
6. **Search Functionality** - Real-time search
7. **Notifications** - Toast notifications system
8. **Dark/Light Mode** - Theme switcher

## 📝 Lưu ý quan trọng

### Performance Budgets
- Chỉ animate `transform` và `opacity` (GPU accelerated)
- Limit animated elements < 20 per viewport
- Use `will-change` sparingly

### Best Practices
- Same interaction = same animation
- Provide pause controls for loops > 5s
- Don't convey critical info through motion alone
- Avoid vestibular triggers (large zooms, rapid spins)

## 📄 License

ISC
