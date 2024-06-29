import { loadEnv } from 'vite'
import { defineConfig } from 'vitest/config'
import { initCanisterIds } from './common.config'


const production = process.env.NODE_ENV === 'production'

const { canisterIds, network } = initCanisterIds(production)

export default defineConfig({
    test: {
        globals: true,
        environment: 'node',
        globalSetup: './vitest.global-setup.ts',
        setupFiles: ['./vitest.indexdb-setup.ts'],
        testTimeout: 30_000,
        env: {
            DFX_NETWORK: network,
            ...Object.fromEntries(
                Object.entries(canisterIds).flatMap(([name, ids]) => [
                    [`${name.toUpperCase()}_CANISTER_ID`, ids[network]],
                    [`CANISTER_ID_${name.toUpperCase()}`, ids[network]],
                ])
            ),
        }
    }
});