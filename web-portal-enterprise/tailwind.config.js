/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,jsx}'],
  theme: {
    extend: {
      colors: {
        // Light, professional theme - token NAMES kept as-is (ink/paper/panel/
        // panel2/line/mist/signal/go/hold/stop) so every page that already
        // references them re-themes in one place; only the hex VALUES changed.
        // Note the naming is now non-literal: 'ink' is the light page
        // background and 'paper' is the dark body text (inverted from the
        // original dark theme, where ink was the dark bg and paper the light
        // text) - the metaphor doesn't hold post-flip, but renaming every
        // class site across both portals wasn't worth the churn/risk.
        ink: '#F8FAFC', // page background (was dark bg)
        panel: '#FFFFFF', // card/surface background (was dark panel)
        panel2: '#F1F5F9', // secondary surface - table headers, hover states
        line: '#E2E8F0', // borders
        paper: '#0F172A', // primary body text (was light text)
        mist: '#64748B', // muted/secondary text
        signal: '#673AB7', // brand accent - matches the company purple (website, mobile apps) - was a stray blue (#2A78D6) unrelated to the rest of the brand. Also dataviz categorical slot 1.
        go: '#0CA30C', // success - dataviz status 'good'
        hold: '#FAB219', // warning - dataviz status 'warning'
        stop: '#D03B3B', // danger - dataviz status 'critical'
        // Chart series colors (dataviz categorical theme, fixed order - never
        // cycled/reassigned per-render). Referenced directly by hex in
        // recharts `fill`/`stroke` props since Tailwind class names aren't
        // available there, but declared here as the single source of truth.
        chart1: '#673AB7', // purple - kept identical to `signal` per its own comment above
        chart2: '#EB6834', // orange
        chart3: '#1BAF7A', // aqua
        chart4: '#EDA100', // yellow
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
