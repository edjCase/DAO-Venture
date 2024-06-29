import { defineConfig } from 'vite'
import { svelte } from '@sveltejs/vite-plugin-svelte'
import { nodePolyfills } from 'vite-plugin-node-polyfills'
import { resolve } from 'path'
import inject from '@rollup/plugin-inject'
import replace from '@rollup/plugin-replace'
import fs from 'fs'
import sveltePreprocess from 'svelte-preprocess';
import tailWindCssPlugin from "tailwindcss";
import autoprefixerPlugin from "autoprefixer";

const production = process.env.NODE_ENV === 'production'

function initCanisterIds() {
    const network = process.env.DFX_NETWORK || (production ? "ic" : "local")

    let localCanisters = {}
    let prodCanisters = {}

    try {
        localCanisters = JSON.parse(fs.readFileSync(resolve("..", "..", ".dfx", "local", "canister_ids.json")).toString())
    } catch (error) {
        console.log("No local canister_ids.json found. Continuing production")
    }

    try {
        prodCanisters = JSON.parse(fs.readFileSync(resolve("..", "..", "canister_ids.json")).toString())
    } catch (error) {
        console.log("No production canister_ids.json found. Continuing with local")
    }

    const canisterIds = network === "local" ? { ...(localCanisters || {}) } : prodCanisters

    return { canisterIds, network }
}

const { canisterIds, network } = initCanisterIds()

// Fallback for undefined canister IDs
const UNDEFINED_CANISTER_IDS = {
    "process.env.INTERNET_IDENTITY_CANISTER_ID": JSON.stringify("undefined"),
    "process.env.BACKEND_CANISTER_ID": JSON.stringify("undefined"),
    "process.env.FRONTEND_CANISTER_ID": JSON.stringify("undefined"),
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

