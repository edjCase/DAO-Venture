Deploy static site:
cd src/static-site
npm run build
cd ../..
dfx deploy static_frontend --network ic
