import { defineConfig } from 'vite'
import { svelte } from '@sveltejs/vite-plugin-svelte'
import { nodePolyfills } from 'vite-plugin-node-polyfills'
import inject from '@rollup/plugin-inject'
import replace from '@rollup/plugin-replace'
import sveltePreprocess from 'svelte-preprocess';
import { initCanisterIds } from './common.config';

const production = process.env.NODE_ENV === 'production'


const { canisterIds, network } = initCanisterIds(production)

// Fallback for undefined canister IDs
const UNDEFINED_CANISTER_IDS = {
    "process.env.INTERNET_IDENTITY_CANISTER_ID": JSON.stringify("undefined"),
}

export default defineConfig({
    root: '.', // Set the root directory of your project
    build: {
        target: 'esnext',
        sourcemap: !production,
        outDir: 'dist', // Specify the output directory for the build
        emptyOutDir: true, // Empty the output directory before building
    },
    plugins: [
        svelte({
            preprocess: sveltePreprocess({
                sourceMap: !production,
                postcss: true
            }),
        }),
        nodePolyfills(),
        inject({
            Buffer: ['buffer', 'Buffer'],
        }),
        replace({
            preventAssignment: true,
            "process.env.DFX_NETWORK": JSON.stringify(network),
            "process.env.LOCAL_NETWORK_PORT": JSON.stringify("4943"),
            "process.env.NODE_ENV": JSON.stringify(production ? "production" : "development"),
            "process.env.LOG_LEVEL": JSON.stringify(production ? "info" : "debug"),
            ...UNDEFINED_CANISTER_IDS,
            ...Object.fromEntries(
                Object.keys(canisterIds)
                    .filter((canisterName) => canisterName !== "__Candid_UI")
                    .flatMap((canisterName) => [
                        [`process.env.${canisterName.toUpperCase()}_CANISTER_ID`, JSON.stringify(canisterIds[canisterName][network])],
                        [`process.env.CANISTER_ID_${canisterName.toUpperCase()}`, JSON.stringify(canisterIds[canisterName][network])],
                    ])
            ),
        }),
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

