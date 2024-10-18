# DAOventure

## Introduction

DAOventure is an experimental browser-based roguelite game built on the Internet Computer platform. It uniquely combines engaging gameplay with DAO (Decentralized Autonomous Organization) governance, aiming to create a community-driven game development ecosystem.

## Current Status: Open Alpha

DAOventure is currently in open alpha, available at:
https://bpo6s-4qaaa-aaaap-acava-cai.icp0.io/

Join our open chat community:
https://oc.app/community/cghnf-2qaaa-aaaar-baa6a-cai/?ref=nlzgz-paaaa-aaaaf-acwna-cai

Twitter:
[@daoventure_game](https://twitter.com/daoventure_game)

## Core Concept

DAOventure serves as a framework to experiment with bootstrapping a DAO and explore ideas for creating a functional, self-sustaining game ecosystem. The current phase focuses on laying the foundation for the game framework, while the next phase will emphasize DAO-driven game development.

## Gameplay Overview

- Character Creation: Select a randomly generated race and class combination
- World Exploration: Progress through multiple themed zones (3 per run)
- Scenario-based Gameplay: Face various challenges with branching paths
- Turn-based Combat: Engage in strategic battles
- Persistent Achievements: Unlock achievements that carry over between runs

## DAO Integration (In Development)

- Content Submission: Players can submit or edit game content through the DAO
- Governance: Participate in voting for new content and game changes
- Token Distribution: Earn tokens through gameplay, contributions, and governance
- Note: The current DAO implementation is centralized and serves as a test for future decentralized governance

## Technical Implementation

- Backend: Motoko programming language
- Frontend: Svelte with TypeScript
- Platform: Internet Computer (ICP), fully on-chain in canisters
- Browser-based game client
- Smart contracts for DAO governance and token distribution (planned)

## Development Roadmap

1. Current Phase: Establish basic game mechanics and DAO concept
2. Next Phase: Refine DAO mechanics and transition to community-driven development
3. Future Plans:
   - Implement NFT minting for successful character runs
   - Explore incentive structures for participation
   - Develop sustainable funding mechanisms

## Challenges and Limitations

- DAO implementation requires significant community engagement
- Solo development of the game framework presents inherent limitations
- Basic content available for gameplay, with the bulk intended for DAO creation

## Get Involved

We encourage the community to participate in this unique project that combines roguelite gameplay with decentralized governance. Test the game, provide feedback, and help shape the future of DAOventure!

Join us in this experimental journey of creating a community-driven game development ecosystem!

---

# Basic Usage (\*\* marks first run only)

- Run dfx `dfx start --background`
- \*\* Install [mops](https://mops.one) `npm i -g ic-mops`
- \*\* Install mops packages `mops install`
- Deploy canisters `npm run deploy`
- Change to frontend directory `src/frontend`
- \*\* Install npm packages `npm install`
- Run `npm run dev`
- https://localhost:8080 in the browser
