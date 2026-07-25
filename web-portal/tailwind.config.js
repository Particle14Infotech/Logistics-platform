/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,jsx}'],
  theme: {
    extend: {
      colors: {
        ink: '#0B1220',
        panel: '#121B2E',
        panel2: '#16223A',
        line: '#26314A',
        paper: '#EDF1F8',
        mist: '#8C97B2',
        signal: '#FF7A29',
        go: '#34D399',
        hold: '#FBBF24',
        stop: '#F87171',
      },
      fontFamily: {
        display: ['"Space Grotesk"', 'sans-serif'],
        body: ['Inter', 'sans-serif'],
        mono: ['"IBM Plex Mono"', 'monospace'],
      },
    },
  },
  plugins: [],
};
