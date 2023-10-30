import svelte from "rollup-plugin-svelte";
import commonjs from "@rollup/plugin-commonjs";
import nodeResolve from "@rollup/plugin-node-resolve";
import livereload from "rollup-plugin-livereload";
import css from "rollup-plugin-css-only";
import replace from "@rollup/plugin-replace";
import inject from "rollup-plugin-inject";
import json from "@rollup/plugin-json";
import sveltePreprocess from "svelte-preprocess";
import typescript from '@rollup/plugin-typescript';
import nodePolyfill from 'rollup-plugin-polyfill-node';
import localCanisters from "../../.dfx/local/canister_ids.json" assert {
  type: 'json'
};
import prodCanisters from "../../canister_ids.json" assert {
  type: 'json'
};
import child_process from "child_process";

const production = !process.env.ROLLUP_WATCH;

function initCanisterIds() {
  const network =
    process.env.DFX_NETWORK ||
    (process.env.NODE_ENV === "production" ? "ic" : "local");

  console.log(network);

  const canisterIds =
    network === "local"
      ? { ...(localCanisters || {}) }
      : prodCanisters;

  return { canisterIds, network };
}
const { canisterIds, network } = initCanisterIds();

// Fallback to render "undefined" in the browser in case canisters have not been deployed
const UNDEFINED_CANISTER_IDS = {
  "process.env.INTERNET_IDENTITY_CANISTER_ID": "undefined",
  "process.env.BACKEND_CANISTER_ID": "undefined",
  "process.env.FRONTEND_CANISTER_ID": "undefined",
};

function serve() {
  let server;

  function toExit() {
    if (server) server.kill(0);
  }

  return {
    writeBundle() {
      if (server) return;
      server = child_process.spawn(
        "npm",
        ["run", "start", "--", "--dev", "--single"],
        {
          stdio: ["ignore", "inherit", "inherit"],
          shell: true,
        }
      );

      process.on("SIGTERM", toExit);
      process.on("exit", toExit);
    },
  };
}

export default {
  input: "src/main.ts",
  output: {
    sourcemap: !production,
    name: "app",
    format: "iife",
    file: "public/build/main.js",
    inlineDynamicImports: true,
  },
  plugins: [
    svelte({
      preprocess: sveltePreprocess({
        sourceMap: !production,
      }),
      compilerOptions: {
        // enable run-time checks when not in production
        dev: !production,
      },
    }),
    // we'll extract any component CSS out into
    // a separate file - better for performance
    css({ output: "bundle.css" }),

    // If you have external dependencies installed from
    // npm, you'll most likely need these plugins. In
    // some cases you'll need additional configuration -
    // consult the documentation for details:
    // https://github.com/rollup/plugins/tree/master/packages/commonjs
    nodeResolve({
      preferBuiltins: false,
      browser: true,
      dedupe: ["svelte"],
    }),
    commonjs(),
    nodePolyfill(),
    typescript({
        sourceMap: !production,
        inlineSources: !production
    }),
    inject({
      Buffer: ["buffer", "Buffer"],
    }),
    json(),
    // Add canister ID's & network to the environment
    replace(
      Object.assign(
        {
          preventAssignment: true,
          "process.env.DFX_NETWORK": JSON.stringify(network),
          "process.env.NODE_ENV": JSON.stringify(
            production ? "production" : "development"
          ),
          "process.env.LOG_LEVEL": JSON.stringify(
            production ? "info" : "debug"
          ),
          ...UNDEFINED_CANISTER_IDS,
        },
        ...Object.keys(canisterIds)
          .filter((canisterName) => canisterName !== "__Candid_UI")
          .map((canisterName) => ({
            ["process.env." + canisterName.toUpperCase() + "_CANISTER_ID"]:
              JSON.stringify(canisterIds[canisterName][network]),
            ["process.env.CANISTER_ID_" + canisterName.toUpperCase()]:
              JSON.stringify(canisterIds[canisterName][network]),
          }))
      )
    ),

    // In dev mode, call `npm run start` once
    // the bundle has been generated
    !production && serve(),

    // Watch the `public` directory and refresh the
    // browser on changes when not in production
    !production && livereload("public"),
  ],
  watch: {
    clearScreen: false,
  },
  onwarn: (warning, warn) => {
    // Suppress known warnings from specific files
    if (
      warning.code === 'THIS_IS_UNDEFINED' && 
      (warning.loc.file.includes('node_modules/@dfinity/agent')
      || warning.loc.file.includes('node_modules/@dfinity/identity'))
    ) return;
    
    // if (
    //   warning.code === 'CIRCULAR_DEPENDENCY' && 
    //   warning.importer.includes('node_modules/@dfinity/auth-client')
    // ) {
    //   return;}


    if (
      warning.code === 'EVAL' && 
      warning.loc.file.includes('node_modules/js-sha256')
    ) return;

    // Let Rollup handle all other warnings normally
    warn(warning);
  },
};