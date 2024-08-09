import flowbitePlugin from 'flowbite/plugin';

const config = {
  content: ['./src/**/*.{html,svelte,ts}', './node_modules/flowbite-svelte/**/*.{html,js,svelte,ts}'],

  plugins: [flowbitePlugin],

  darkMode: 'media',

  theme: {
    extend: {
      colors: {
        'retro-black': '#0f380f',
        'retro-dark-green': '#306230',
        'retro-light-green': '#8bac0f',
        'retro-pale-green': '#9bbc0f',
      },
    },
  },
};

export default config;