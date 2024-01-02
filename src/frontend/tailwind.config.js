import flowbitePlugin from 'flowbite/plugin';

const config = {
  content: ['./src/**/*.{html,svelte,ts}', './node_modules/flowbite-svelte/**/*.{html,js,svelte,ts}'],

  plugins: [flowbitePlugin],

  darkMode: 'media',

  theme: {
    extend: {
      colors: {
        // flowbite-svelte
        primary: {
          50: '#FFF5F2',
          100: '#FFF1EE',
          200: '#FFE4DE',
          300: '#FFD5CC',
          400: '#FFBCAD',
          500: '#FE795D',
          600: '#EF562F',
          700: '#EB4F27',
          800: '#CC4522',
          900: '#A5371B'
        },
        // Define your dark colors here
        dark: {
          50: '#0a0c0e',
          100: '#15181b',
          200: '#202327',
          300: '#2b2e33',
          400: '#36393f',
          500: '#41454b',
          600: '#4c5157',
          700: '#575d63',
          800: '#62696f',
          900: '#6d757b'
        }
      }
    }
  },
};

export default config;