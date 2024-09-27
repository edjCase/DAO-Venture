import { defineConfig } from 'vite'
import { svelte } from '@sveltejs/vite-plugin-svelte'
import { nodePolyfills } from 'vite-plugin-node-polyfills'
import inject from '@rollup/plugin-inject'
import sveltePreprocess from 'svelte-preprocess';
import environment from 'vite-plugin-environment';
import dotenv from 'dotenv';


dotenv.config({ path: '../../.env' });

export default defineConfig({
    root: '.', // Set the root directory of your project
    build: {
        target: 'esnext',
        outDir: 'dist', // Specify the output directory for the build
        emptyOutDir: true, // Empty the output directory before building
    },
    plugins: [
        svelte({
            preprocess: sveltePreprocess({
                postcss: true
            }),
        }),
        nodePolyfills(),
        inject({
            Buffer: ['buffer', 'Buffer'],
        }),
        environment("all", { prefix: "CANISTER_" }),
        environment("all", { prefix: "DFX_" }),
    ],
    resolve: {
        alias: {
            // Add any necessary aliases here
        },
    },
    server: {
        fs: {
            allow: ['.'],
        },
    },
    css: {
        postcss: './postcss.config.cjs',
    },
})

