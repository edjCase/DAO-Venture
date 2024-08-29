import flowbitePlugin from 'flowbite/plugin';

const config = {
  content: ['./src/**/*.{html,svelte,ts}', './node_modules/flowbite-svelte/**/*.{html,js,svelte,ts}'],

  plugins: [flowbitePlugin],

  darkMode: 'media',

  theme: {
    extend: {
      colors: {
        primary: {
          50: '#f0fdf4',
          100: '#dcfce7',
          200: '#bbf7d0',
          300: '#86efac',
          400: '#4ade80',
          500: '#22c55e',
          600: '#16a34a',
          700: '#15803d',
          800: '#166534',
          900: '#14532d',
        },
        secondary: {
          50: '#E6E7E8',
          100: '#C0C3C6',
          200: '#9A9FA4',
          300: '#747B82',
          400: '#4E5760',
          500: '#1C2025', 
          600: '#191D21',
          700: '#16191D',
          800: '#131619',
          900: '#101315',
        },
        accent: {
          50: '#FCF6E3',
          100: '#F8E9B8',
          200: '#F3DC8D',
          300: '#EECF62',
          400: '#E9C237',
          500: '#C1A33B',  
          600: '#AE9335',
          700: '#9B832F',
          800: '#887329',
          900: '#756323',
        },
      },
    },
  },
};

export default config;