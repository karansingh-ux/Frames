/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        brand: {
          midnight: '#000031',
          electric: '#0302FF',
          glow: '#3D3BFF',
          accent: '#5B5AFF',
        },
        surface: {
          canvas: '#080811',
          card: 'rgba(18, 18, 30, 0.75)',
          'card-hover': 'rgba(28, 28, 48, 0.85)',
          overlay: 'rgba(8, 8, 20, 0.85)',
        }
      },
      fontFamily: {
        sans: ['Sen', 'system-ui', '-apple-system', 'BlinkMacSystemFont', 'sans-serif'],
      },
      borderRadius: {
        'sm': '6px',
        'md': '10px',
        'lg': '14px',
        'xl': '20px',
        '2xl': '28px',
      },
      boxShadow: {
        'glow-sm': '0 0 16px rgba(3, 2, 255, 0.35)',
        'glow-md': '0 0 28px rgba(3, 2, 255, 0.45)',
        'glow-lg': '0 8px 36px rgba(3, 2, 255, 0.60)',
        'card': '0 8px 32px rgba(0, 0, 0, 0.45)',
      },
      animation: {
        'pulse-subtle': 'pulseSubtle 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
        'float': 'float 6s ease-in-out infinite',
      },
      keyframes: {
        pulseSubtle: {
          '0%, 100%': { opacity: '0.8' },
          '50%': { opacity: '1' },
        },
        float: {
          '0%, 100%': { transform: 'translateY(0px)' },
          '50%': { transform: 'translateY(-6px)' },
        }
      }
    },
  },
  plugins: [],
}
