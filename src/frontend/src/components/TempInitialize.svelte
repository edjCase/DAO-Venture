<script lang="ts">
  import { leagueAgentFactory } from "../ic-agent/League";
  import { Player, playerLedgerAgentFactory } from "../ic-agent/PlayerLedger";
  import type { Principal } from "@dfinity/principal";
  import { stadiumStore } from "../stores/StadiumStore";
  import { teamStore } from "../stores/TeamStore";
  import { playerStore } from "../stores/PlayerStore";
  import { divisions } from "../Data/Players";
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
    let promises = [];
    for (let i in divisions) {
      let division = divisions[i];
      let promise = leagueAgentFactory()
        .createDivision(division)
        .then(async (result) => {
          if ("ok" in result) {
            console.log("Created division: ", result.ok);
            let teamsWithDivisionId = division.teams.map((t) => {
              return { ...t, divisionId: result.ok };
            });
            await createTeams(teamsWithDivisionId);
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

  let createTeams = async function (teams: any[]): Promise<
    {
      id: Principal;
      players: any[];
    }[]
  > {
    let leagueAgent = leagueAgentFactory();
    let promises = [];
    for (let i in teams) {
      let team = teams[i];
      let promise = leagueAgent.createTeam(team).then(async (result) => {
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
    players: Player[]
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
          deity: player.deity,
          skills: player.skills,
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
