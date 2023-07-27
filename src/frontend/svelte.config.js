import sveltePreprocess from 'svelte-preprocess';

export default {
  preprocess: sveltePreprocess({
    tsconfig: './tsconfig.json',
  })
};
