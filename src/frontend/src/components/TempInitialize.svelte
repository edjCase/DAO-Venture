<script lang="ts">
  import { leagueAgentFactory } from "../ic-agent/League";
  import { playerLedgerAgentFactory } from "../ic-agent/PlayerLedger";
  import type { Principal } from "@dfinity/principal";
  import { stadiumStore } from "../stores/StadiumStore";
  import { teamStore } from "../stores/TeamStore";
  import { playerStore } from "../stores/PlayerStore";
  import { divisionAgentFactory } from "../ic-agent/Division";

  let createStadium = async function () {
    let result = await leagueAgentFactory().createStadium();
    if ("ok" in result) {
      console.log("Created stadium: ", result.ok);
    } else {
      console.log("Failed to make stadium");
    }
    stadiumStore.refetch();
  };

  let createDivisions = async function () {
    let divisions = [
      {
        name: "Division 1",
        teams: [
          {
            id: null,
            name: "Crabz",
            logoUrl:
              "https://imgs.search.brave.com/OFu2Rv3v86otnalo0qA4e59PZtqCmw5IOZIIH5PIH8o/rs:fit:860:0:0/g:ce/aHR0cHM6Ly90NC5m/dGNkbi5uZXQvanBn/LzAxLzc3LzEzLzQ1/LzM2MF9GXzE3NzEz/NDU0OF9kN1ljYlBW/TDVselMxWG5mMTlC/QXEybGFKU2U1QnV2/Zi5qcGc",
            tokenName: "Crabz",
            tokenSymbol: "CRABZ",
            players: [
              {
                name: "Shelldon Pinch",
                position: { pitcher: null },
              },
              {
                name: "Coraline Claw",
                position: { firstBase: null },
              },
              {
                name: "Sandy Shore",
                position: { secondBase: null },
              },
              {
                name: "Barnacle Bill",
                position: { thirdBase: null },
              },
              {
                name: "Tidepool Tim",
                position: { shortStop: null },
              },
              {
                name: "Wharf Willy",
                position: { leftField: null },
              },
              {
                name: "Ocean Oliver",
                position: { centerField: null },
              },
              {
                name: "Waverly Waters",
                position: { rightField: null },
              },
              {
                name: "Kelpie Krab",
                position: { pitcher: null },
              },
              {
                name: "Anemone Andy",
                position: { firstBase: null },
              },
              {
                name: "Reef Ricky",
                position: { secondBase: null },
              },
              {
                name: "Mussel Mike",
                position: { thirdBase: null },
              },
              {
                name: "Bubbly Bob",
                position: { shortStop: null },
              },
              {
                name: "Tsunami Tami",
                position: { leftField: null },
              },
              {
                name: "Harbor Harry",
                position: { centerField: null },
              },
              {
                name: "Beachcomber Betty",
                position: { rightField: null },
              },
            ],
          },
          {
            id: null,
            name: "Lobsterz",
            logoUrl:
              "https://imgs.search.brave.com/cIAAkBmDWBtXzxwWspYcqbg2M2aiTOKDqGAsuGkhY_I/rs:fit:860:0:0/g:ce/aHR0cHM6Ly90My5m/dGNkbi5uZXQvanBn/LzAyLzA0LzczLzky/LzM2MF9GXzIwNDcz/OTI5MV9LM25mZEdK/d0FrSjlLQnVLUlZp/NHhtWEtVaU94OXlR/Si5qcGc",
            tokenName: "Lobsterz",
            tokenSymbol: "LOBZ",
            players: [
              {
                name: "Lobster Larry",
                position: { pitcher: null },
              },
              {
                name: "Coral Courtney",
                position: { firstBase: null },
              },
              {
                name: "Buoyant Benny",
                position: { secondBase: null },
              },
              {
                name: "Reefy Ruth",
                position: { thirdBase: null },
              },
              {
                name: "Shelly Shore",
                position: { shortStop: null },
              },
              {
                name: "Pincer Paul",
                position: { leftField: null },
              },
              {
                name: "Tidal Tina",
                position: { centerField: null },
              },
              {
                name: "Oceanic Olga",
                position: { rightField: null },
              },
              {
                name: "Abyss Andy",
                position: { pitcher: null },
              },
              {
                name: "Marina Mary",
                position: { firstBase: null },
              },
              {
                name: "Current Chris",
                position: { secondBase: null },
              },
              {
                name: "Seaweed Sally",
                position: { thirdBase: null },
              },
              {
                name: "Whirlpool Willie",
                position: { shortStop: null },
              },
              {
                name: "Surfing Sam",
                position: { leftField: null },
              },
              {
                name: "Nautical Nancy",
                position: { centerField: null },
              },
              {
                name: "Divey Dave",
                position: { rightField: null },
              },
            ],
          },
          {
            id: null,
            name: "Jellyz",
            logoUrl:
              "https://imgs.search.brave.com/4ZUlZt5Y_B7DSKkE3GO58ZVXlM2RxGkoOukG7U6Gqqk/rs:fit:860:0:0/g:ce/aHR0cHM6Ly9pbWcu/ZnJlZXBpay5jb20v/ZnJlZS12ZWN0b3Iv/amVsbHlmaXNoLXNl/YS1hbmltYWwtY2Fy/dG9vbi1zdGlja2Vy/XzEzMDgtNzg1MzAu/anBnP3NpemU9NjI2/JmV4dD1qcGc",
            tokenName: "Jellyz",
            tokenSymbol: "JELZ",
            players: [
              {
                name: "Jellybean Jill",
                position: { pitcher: null },
              },
              {
                name: "Tentacle Ted",
                position: { firstBase: null },
              },
              {
                name: "Stinger Steve",
                position: { secondBase: null },
              },
              {
                name: "Bubbly Bill",
                position: { thirdBase: null },
              },
              {
                name: "Floaty Frank",
                position: { shortStop: null },
              },
              {
                name: "Mano-War Maria",
                position: { leftField: null },
              },
              {
                name: "Pulsing Polly",
                position: { centerField: null },
              },
              {
                name: "Drifty Dave",
                position: { rightField: null },
              },
              {
                name: "Moonbeam Molly",
                position: { pitcher: null },
              },
              {
                name: "Luminous Lou",
                position: { firstBase: null },
              },
              {
                name: "Hydro Harry",
                position: { secondBase: null },
              },
              {
                name: "Glowy Gwen",
                position: { thirdBase: null },
              },
              {
                name: "Blubber Bob",
                position: { shortStop: null },
              },
              {
                name: "Necton Ned",
                position: { leftField: null },
              },
              {
                name: "Cnidarian Cindy",
                position: { centerField: null },
              },
              {
                name: "Zephyr Zoe",
                position: { rightField: null },
              },
            ],
          },
          {
            id: null,
            name: "Toadz",
            logoUrl:
              "https://imgs.search.brave.com/Rm7Nj0SD_nUMzAjs3we-upMoynWtEwkB2WacPgf9IAQ/rs:fit:860:0:0/g:ce/aHR0cHM6Ly9tZWRp/YS5pc3RvY2twaG90/by5jb20vaWQvMTIw/OTE0MjI2Mi92ZWN0/b3IvZnJvZy1sb2dv/LmpwZz9zPTYxMng2/MTImdz0wJms9MjAm/Yz02YU4tSF83eUNH/bEwzQmZ1YVcwY3hl/cmo4bzNmd25WZkVP/TnZMOHVxVE80PQ",
            tokenName: "Toadz",
            tokenSymbol: "TOADZ",
            players: [
              {
                name: "Toadstool Todd",
                position: { pitcher: null },
              },
              {
                name: "Hoppy Hank",
                position: { firstBase: null },
              },
              {
                name: "Boggy Bill",
                position: { secondBase: null },
              },
              {
                name: "Pond Paul",
                position: { thirdBase: null },
              },
              {
                name: "Croaky Chris",
                position: { shortStop: null },
              },
              {
                name: "Lily Lily",
                position: { leftField: null },
              },
              {
                name: "Ribbit Rick",
                position: { centerField: null },
              },
              {
                name: "Swampy Sue",
                position: { rightField: null },
              },
              {
                name: "Muddy Mike",
                position: { pitcher: null },
              },
              {
                name: "Warty Wendy",
                position: { firstBase: null },
              },
              {
                name: "Bumpy Bob",
                position: { secondBase: null },
              },
              {
                name: "Puddle Pete",
                position: { thirdBase: null },
              },
              {
                name: "Tadpole Tim",
                position: { shortStop: null },
              },
              {
                name: "Froggy Fran",
                position: { leftField: null },
              },
              {
                name: "Algae Amy",
                position: { centerField: null },
              },
              {
                name: "Marshy Matt",
                position: { rightField: null },
              },
            ],
          },
          {
            id: null,
            name: "Squidz",
            logoUrl:
              "https://imgs.search.brave.com/ejjzShq4jh4B2_l43F-or_BchEQdx9DwRic6SIV5T9A/rs:fit:860:0:0/g:ce/aHR0cHM6Ly9zdGF0/aWMudGhlbm91bnBy/b2plY3QuY29tL3Bu/Zy81ODM5NTYxLTIw/MC5wbmc",
            tokenName: "Squidz",
            tokenSymbol: "SQUIDZ",
            players: [
              {
                name: "Inky Ian",
                position: { pitcher: null },
              },
              {
                name: "Squiggly Steve",
                position: { firstBase: null },
              },
              {
                name: "Darting Dan",
                position: { secondBase: null },
              },
              {
                name: "Tentacle Tom",
                position: { thirdBase: null },
              },
              {
                name: "Jetty Jerry",
                position: { shortStop: null },
              },
              {
                name: "Kraken Kevin",
                position: { leftField: null },
              },
              {
                name: "Salty Sam",
                position: { centerField: null },
              },
              {
                name: "Ocean Owen",
                position: { rightField: null },
              },
              {
                name: "Coral Carl",
                position: { pitcher: null },
              },
              {
                name: "Sinker Scott",
                position: { firstBase: null },
              },
              {
                name: "Reef Randy",
                position: { secondBase: null },
              },
              {
                name: "Mantle Mason",
                position: { thirdBase: null },
              },
              {
                name: "Deepsea Dean",
                position: { shortStop: null },
              },
              {
                name: "Barnacle Brad",
                position: { leftField: null },
              },
              {
                name: "Wave Walter",
                position: { centerField: null },
              },
              {
                name: "Gill Gary",
                position: { rightField: null },
              },
            ],
          },
          {
            id: null,
            name: "Salamanderz",
            logoUrl:
              "https://imgs.search.brave.com/0WHTTsaSLs4aqG8P9vON1KcL6ID84ARAEfEhdk_LJUc/rs:fit:860:0:0/g:ce/aHR0cHM6Ly9jZG4u/dmVjdG9yc3RvY2su/Y29tL2kvcHJldmll/dy0xeC81OS84NS9z/YWxhbWFuZGVyLWhh/bmQtZHJhd24tc2tl/dGNoLWljb24tdmVj/dG9yLTE5Mzk1OTg1/LmpwZw",
            tokenName: "Salamanderz",
            tokenSymbol: "SALMZ",
            players: [
              {
                name: "Sunny Sal",
                position: { pitcher: null },
              },
              {
                name: "Newt Nate",
                position: { firstBase: null },
              },
              {
                name: "Gilly Gil",
                position: { secondBase: null },
              },
              {
                name: "Axolotl Alex",
                position: { thirdBase: null },
              },
              {
                name: "Crested Cory",
                position: { shortStop: null },
              },
              {
                name: "Mudskipper Max",
                position: { leftField: null },
              },
              {
                name: "Lava Lance",
                position: { centerField: null },
              },
              {
                name: "Skink Steve",
                position: { rightField: null },
              },
              {
                name: "Siren Sam",
                position: { pitcher: null },
              },
              {
                name: "Triton Troy",
                position: { firstBase: null },
              },
              {
                name: "Firefly Finn",
                position: { secondBase: null },
              },
              {
                name: "Slimy Sean",
                position: { thirdBase: null },
              },
              {
                name: "Camo Kyle",
                position: { shortStop: null },
              },
              {
                name: "Gecko Gary",
                position: { leftField: null },
              },
              {
                name: "Hydra Harry",
                position: { centerField: null },
              },
              {
                name: "Mossy Marty",
                position: { rightField: null },
              },
            ],
          },
        ],
      },
      {
        name: "Division 2",
        teams: [
          {
            id: null,
            name: "Barnaclez",
            logoUrl:
              "https://imgs.search.brave.com/ir4LXuCwuUxldHx7W4mSZzUOIifEzo6bSmjoAsOVvlc/rs:fit:860:0:0/g:ce/aHR0cHM6Ly9kb2Rv/LmFjL25wL2ltYWdl/cy9hL2E0L0Fjb3Ju/X0Jhcm5hY2xlX05I/X0ljb24ucG5n",
            tokenName: "Barnaclez",
            tokenSymbol: "BARNZ",
            players: [
              {
                name: "Buoyant Barry",
                position: { pitcher: null },
              },
              {
                name: "Marine Mark",
                position: { firstBase: null },
              },
              {
                name: "Salty Steve",
                position: { secondBase: null },
              },
              {
                name: "Ocean Owen",
                position: { thirdBase: null },
              },
              {
                name: "Coral Carl",
                position: { shortStop: null },
              },
              {
                name: "Tidepool Tom",
                position: { leftField: null },
              },
              {
                name: "Harbor Harry",
                position: { centerField: null },
              },
              {
                name: "Anchor Andy",
                position: { rightField: null },
              },
              {
                name: "Seaweed Simon",
                position: { pitcher: null },
              },
              {
                name: "Barny Bernard",
                position: { firstBase: null },
              },
              {
                name: "Deckhand Dan",
                position: { secondBase: null },
              },
              {
                name: "Reef Randy",
                position: { thirdBase: null },
              },
              {
                name: "Manta Ray",
                position: { shortStop: null },
              },
              {
                name: "Nautical Nate",
                position: { leftField: null },
              },
              {
                name: "Mollusk Mike",
                position: { centerField: null },
              },
              {
                name: "Guppy Gary",
                position: { rightField: null },
              },
            ],
          },
          {
            id: null,
            name: "Newtz",
            logoUrl:
              "https://imgs.search.brave.com/yOFowXI6oh5bfO45qXKdqFMR9I2J0pFMD1n9WNWz0f8/rs:fit:860:0:0/g:ce/aHR0cHM6Ly9zdGF0/aWMudGhlbm91bnBy/b2plY3QuY29tL3Bu/Zy8yNTM1NzI2LTIw/MC5wbmc",
            tokenName: "Newtz",
            tokenSymbol: "NEWTZ",
            players: [
              {
                name: "Newt Nolan",
                position: { pitcher: null },
              },
              {
                name: "Salamander Sam",
                position: { firstBase: null },
              },
              {
                name: "Gilly Gary",
                position: { secondBase: null },
              },
              {
                name: "Triton Travis",
                position: { thirdBase: null },
              },
              {
                name: "Eft Eddie",
                position: { shortStop: null },
              },
              {
                name: "Sticky Stuart",
                position: { leftField: null },
              },
              {
                name: "Aquatic Alex",
                position: { centerField: null },
              },
              {
                name: "Mudskipper Mark",
                position: { rightField: null },
              },
              {
                name: "Wetland Walt",
                position: { pitcher: null },
              },
              {
                name: "Slick Steve",
                position: { firstBase: null },
              },
              {
                name: "Paddle Paul",
                position: { secondBase: null },
              },
              {
                name: "Swimmy Scott",
                position: { thirdBase: null },
              },
              {
                name: "Lagoon Leo",
                position: { shortStop: null },
              },
              {
                name: "Boggy Blake",
                position: { leftField: null },
              },
              {
                name: "Pond Peter",
                position: { centerField: null },
              },
              {
                name: "Marshland Mike",
                position: { rightField: null },
              },
            ],
          },
          {
            id: null,
            name: "Cuttlefizh",
            logoUrl:
              "https://imgs.search.brave.com/hiYh3mpfyCj0U3lggVQ5Zj8mwN7HqHZqtYPNPjjk7lo/rs:fit:860:0:0/g:ce/aHR0cHM6Ly9zdGF0/aWMudGhlbm91bnBy/b2plY3QuY29tL3Bu/Zy8yMDQyMTcyLTIw/MC5wbmc",
            tokenName: "Cuttlefizh",
            tokenSymbol: "CTLFZ",
            players: [
              {
                name: "Cephalo Carlos",
                position: { pitcher: null },
              },
              {
                name: "Ink Ian",
                position: { firstBase: null },
              },
              {
                name: "Squiddy Steve",
                position: { secondBase: null },
              },
              {
                name: "Tentacle Tom",
                position: { thirdBase: null },
              },
              {
                name: "Jet Jack",
                position: { shortStop: null },
              },
              {
                name: "Siphon Sam",
                position: { leftField: null },
              },
              {
                name: "Mantle Max",
                position: { centerField: null },
              },
              {
                name: "Beak Ben",
                position: { rightField: null },
              },
              {
                name: "Kraken Keith",
                position: { pitcher: null },
              },
              {
                name: "Armstrong Arthur",
                position: { firstBase: null },
              },
              {
                name: "Camo Kevin",
                position: { secondBase: null },
              },
              {
                name: "Nauti Nick",
                position: { thirdBase: null },
              },
              {
                name: "Reef Ralph",
                position: { shortStop: null },
              },
              {
                name: "Deepsea Dave",
                position: { leftField: null },
              },
              {
                name: "Floaty Phil",
                position: { centerField: null },
              },
              {
                name: "Ocean Oliver",
                position: { rightField: null },
              },
            ],
          },
          {
            id: null,
            name: "Turtlez",
            logoUrl:
              "https://imgs.search.brave.com/ZZao2qgmU4PNC-m1GIzgXrZuYKSdZ_wLJMXZgjpZzP0/rs:fit:860:0:0/g:ce/aHR0cHM6Ly90My5m/dGNkbi5uZXQvanBn/LzAxLzczLzk3Lzg4/LzM2MF9GXzE3Mzk3/ODgyMl8yM0FSVEJX/Q3MwMHhiRmRkckU0/SndBUmxVcWRpZWlP/WC5qcGc",
            tokenName: "Turtlez",
            tokenSymbol: "TRLZ",
            players: [
              {
                name: "Shelly Shane",
                position: { pitcher: null },
              },
              {
                name: "Hardshell Hank",
                position: { firstBase: null },
              },
              {
                name: "Slider Sid",
                position: { secondBase: null },
              },
              {
                name: "Terrapin Tim",
                position: { thirdBase: null },
              },
              {
                name: "Basker Barry",
                position: { shortStop: null },
              },
              {
                name: "Snapper Sam",
                position: { leftField: null },
              },
              {
                name: "Reef Ralph",
                position: { centerField: null },
              },
              {
                name: "Coral Carl",
                position: { rightField: null },
              },
              {
                name: "Digger Doug",
                position: { pitcher: null },
              },
              {
                name: "Mossback Max",
                position: { firstBase: null },
              },
              {
                name: "Sunny Steve",
                position: { secondBase: null },
              },
              {
                name: "Loggerhead Larry",
                position: { thirdBase: null },
              },
              {
                name: "Ripple Rick",
                position: { shortStop: null },
              },
              {
                name: "Scooter Scott",
                position: { leftField: null },
              },
              {
                name: "Splasher Sean",
                position: { centerField: null },
              },
              {
                name: "Chomper Chad",
                position: { rightField: null },
              },
            ],
          },
          {
            id: null,
            name: "Snailz",
            logoUrl:
              "https://imgs.search.brave.com/ZOR-_-9QRxAHdLyD5QoIp34xv516vZGTolrDc1z-aC4/rs:fit:860:0:0/g:ce/aHR0cHM6Ly9kMjlm/aHB3MDY5Y3R0Mi5j/bG91ZGZyb250Lm5l/dC9pY29uL2ltYWdl/LzEyMDE4MC9wcmV2/aWV3LnN2Zw.svg",
            tokenName: "Snailz",
            tokenSymbol: "SNLZ",
            players: [
              {
                name: "Shelly Sam",
                position: { pitcher: null },
              },
              {
                name: "Slimy Steve",
                position: { firstBase: null },
              },
              {
                name: "Spiral Sid",
                position: { secondBase: null },
              },
              {
                name: "Slugger Seth",
                position: { thirdBase: null },
              },
              {
                name: "Slick Scott",
                position: { shortStop: null },
              },
              {
                name: "Shellback Sean",
                position: { leftField: null },
              },
              {
                name: "Silky Sandra",
                position: { centerField: null },
              },
              {
                name: "Salty Sara",
                position: { rightField: null },
              },
              {
                name: "Snail Pace Pat",
                position: { pitcher: null },
              },
              {
                name: "Snaily Sally",
                position: { firstBase: null },
              },
              {
                name: "Sandy Simon",
                position: { secondBase: null },
              },
              {
                name: "Slimeball Stan",
                position: { thirdBase: null },
              },
              {
                name: "Slithering Sophie",
                position: { shortStop: null },
              },
              {
                name: "Speedy Stu",
                position: { leftField: null },
              },
              {
                name: "Silent Sue",
                position: { centerField: null },
              },
              {
                name: "Scaly Steve",
                position: { rightField: null },
              },
            ],
          },
          {
            id: null,
            name: "Anemonez",
            logoUrl:
              "https://imgs.search.brave.com/YpB2meSALUOhh1k8Xuwwt7wJcULL7EFXvaRZzqNHMP4/rs:fit:860:0:0/g:ce/aHR0cHM6Ly9jZG4t/aWNvbnMtcG5nLmZs/YXRpY29uLmNvbS8x/MjgvNzU5MS83NTkx/MDAyLnBuZw",
            tokenName: "Anemonez",
            tokenSymbol: "ANEMZ",
            players: [
              {
                name: "Coral Carl",
                position: { pitcher: null },
              },
              {
                name: "Reef Rick",
                position: { pitcher: null },
              },
              {
                name: "Barnacle Ben",
                position: { firstBase: null },
              },
              {
                name: "Tidepool Tom",
                position: { firstBase: null },
              },
              {
                name: "Surfing Sam",
                position: { secondBase: null },
              },
              {
                name: "Waverider Will",
                position: { secondBase: null },
              },
              {
                name: "Kelpie Kyle",
                position: { thirdBase: null },
              },
              {
                name: "Anemone Andy",
                position: { thirdBase: null },
              },
              {
                name: "Sandy Steve",
                position: { shortStop: null },
              },
              {
                name: "Diver Dan",
                position: { shortStop: null },
              },
              {
                name: "Marine Marcy",
                position: { leftField: null },
              },
              {
                name: "Seashell Sally",
                position: { leftField: null },
              },
              {
                name: "Ocean Oliver",
                position: { centerField: null },
              },
              {
                name: "Current Chris",
                position: { centerField: null },
              },
              {
                name: "Manta Ray Ray",
                position: { rightField: null },
              },
              {
                name: "Nautical Nate",
                position: { rightField: null },
              },
            ],
          },
        ],
      },
    ];
    let promises = [];
    for (let i in divisions) {
      let division = divisions[i];
      let promise = leagueAgentFactory()
        .createDivision(division)
        .then(async (result) => {
          if ("ok" in result) {
            console.log("Created division: ", result.ok);
            await createTeams(result.ok, division.teams);
          } else if ("nameTaken" in result) {
            console.log("Division name taken: ", division);
          } else {
            console.log("Failed to make division: ", division);
          }
        });
      promises.push(promise);
    }
    await Promise.all(promises);
  };

  let createTeams = async function (
    divisionId: Principal,
    teams: any[]
  ): Promise<
    {
      id: Principal;
      players: any[];
    }[]
  > {
    let divisionAgent = divisionAgentFactory(divisionId);
    let promises = [];
    for (let i in teams) {
      let team = teams[i];
      let promise = divisionAgent.createTeam(team).then(async (result) => {
        if ("ok" in result) {
          let teamId = result.ok;
          team.id = teamId;
          console.log("Created team: ", teamId);
          await createPlayers(team.id, team.players);
        } else {
          console.log("Failed to make team: ", team);
        }
      });
      promises.push(promise);
    }
    await Promise.all(promises);
    teamStore.refetch();
    return teams.map((t) => {
      return { id: t.id, players: t.players };
    });
  };

  let createPlayers = async function (
    teamId: Principal | null,
    players: { name: string; position: any }[]
  ) {
    if (teamId === null) {
      return;
    }
    let playerLedgerAgent = playerLedgerAgentFactory();
    let promises = [];
    for (let j in players) {
      let player = players[j];
      let promise = playerLedgerAgent
        .create({
          name: player.name,
          position: player.position,
          teamId: [teamId],
        })
        .then((result) => {
          if ("created" in result) {
            console.log("Created player: ", result.created);
          } else {
            console.log("Failed to make player: ", player, result.invalid);
          }
        });
      promises.push(promise);
    }
    await Promise.all(promises);
  };

  let initialize = async function () {
    await createStadium();
    await createDivisions();
    playerStore.refetch();
  };
</script>

<button on:click={initialize}>Initialize With Default Data</button>
