# DAOball

## Introduction
TODO

## Logic
- If town health is 0, the population will decrease
- If town health is 100+, the population will increase
- All events trigger every 24 hours after genesis, refered to as a 'tick'
- Regenerative resources (wood, food) regenerate after every tick based on their current amount, with a cap on resources. Low regen with low amounts, high regen at med-high amounts, and low at high amounts
- Non regenerative resources (stone, gold) will NOT regenerate after ticks, but rather have a difficulty that will go up (linearly) which will reduce that resource haul that tick, with a minimum of 1 on high difficulty
- Towns can assign to jobs their population by setting worker count (1 worker = 1 population)
- Citizens/population not assigned a job will ????????????????????????
- Every tick each town will consume food equal to its population count
- Population is capped based on the city size
- City size can increase with an upgrade to the city, costing resources
- City sizes larger than 0 require maintenance costs per tick of wood and stone, the larger the more costs

## Development Status
DAOball is currently in its early development stages. We encourage the community to follow our progress, provide feedback, and contribute to this unique project.

## Follow Us
- **Website**: [daoball.xyz](https://daoball.xyz)
- **Twitter**: [@daoballxyz](https://twitter.com/daoballxyz)

We welcome your ideas, feedback, and contributions to make DAOball an inclusive, transparent, and community-driven endeavor.

---

# Basic Usage (** marks first run only)
- Run dfx `dfx start --background`
- ** Install [mops](https://mops.one) `npm i -g ic-mops` 
- ** Install mops packages `mops install`
- Deploy canisters `npm run deploy`
- Change to frontend directory `src/frontend`
- ** Install npm packages `npm install`
- Run `npm run dev`
- https://localhost:8080 in the browswer
