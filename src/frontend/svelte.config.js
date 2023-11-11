import { vitePreprocess } from "@sveltejs/vite-plugin-svelte";
import sveltePreprocess from "svelte-preprocess";
import tailWindCssPlugin from "tailwindcss";
import autoprefixerPlugin from "autoprefixer";

export default {
  preprocess: [
    sveltePreprocess({
      tsconfig: "./tsconfig.json",
      postcss: {
        plugins: [
          tailWindCssPlugin,
          autoprefixerPlugin
        ],
      }
    }),
    vitePreprocess({}),
  ],
};
