<script lang="ts">
  import { leagueAgentFactory } from "../ic-agent/League";
  import {
    PlayerSkills,
    mapPosition,
    playerLedgerAgentFactory,
  } from "../ic-agent/PlayerLedger";
  import type { Principal } from "@dfinity/principal";
  import { teamStore } from "../stores/TeamStore";
  import { playerStore } from "../stores/PlayerStore";
  import { Team, teams } from "../data/InitData";
  import generateName from "sillyname";
  import { Button } from "flowbite-svelte";
  import { FieldPosition } from "../models/FieldPosition";

  let createTeams = async function (teams: Team[]): Promise<void> {
    let leagueAgent = leagueAgentFactory();
    let promises = [];
    for (let i in teams) {
      let team = teams[i];
      let promise = leagueAgent.createTeam(team).then(async (result) => {
        if ("ok" in result) {
          let teamId = result.ok;
          console.log("Created team: ", teamId);
          await createPlayers(teamId);
        } else {
          console.log("Failed to make team: ", team);
        }
      });
      promises.push(promise);
    }
    await Promise.all(promises);
    teamStore.refetch();
  };

  let generateSkills = function (position: FieldPosition): PlayerSkills {
    let skills = {
      battingAccuracy: 0,
      battingPower: 0,
      catching: 0,
      defense: 0,
      piety: 0,
      speed: 0,
      throwingAccuracy: 0,
      throwingPower: 0,
    };
    switch (position) {
      case FieldPosition.Pitcher:
        skills.throwingPower += 1;
        break;
      case FieldPosition.FirstBase:
      case FieldPosition.SecondBase:
      case FieldPosition.ThirdBase:
      case FieldPosition.ShortStop:
        skills.throwingAccuracy += 1;
        break;
      case FieldPosition.LeftField:
      case FieldPosition.CenterField:
      case FieldPosition.RightField:
        skills.catching += 1;
        break;
    }
    return skills;
  };

  let createPlayers = async function (teamId: Principal) {
    let playerLedgerAgent = playerLedgerAgentFactory();
    let promises = [];
    // loop over count
    for (let positionString in Object.keys(FieldPosition)) {
      // Make 2 of every position
      for (let _ in [0, 1]) {
        let position =
          FieldPosition[positionString as keyof typeof FieldPosition];
        let name = generateName();
        let skills = generateSkills(position);
        let promise = playerLedgerAgent
          .create({
            name: name,
            position: mapPosition(position),
            teamId: [teamId],
            skills: skills,
          })
          .then((result) => {
            if ("created" in result) {
              console.log("Created player: ", result.created);
            } else {
              console.log("Failed to make player: ", result.invalid);
            }
          });
        promises.push(promise);
      }
    }
    await Promise.all(promises);
  };

  let initialize = async function () {
    await createTeams(teams);
    playerStore.refetch();
  };
</script>

<Button on:click={initialize}>Initialize With Default Data</Button>
