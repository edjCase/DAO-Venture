<script lang="ts">
  import { leagueAgentFactory } from "../ic-agent/League";
  import { playerLedgerAgentFactory } from "../ic-agent/PlayerLedger";
  import type { Principal } from "@dfinity/principal";
  import { teamStore } from "../stores/TeamStore";
  import { playerStore } from "../stores/PlayerStore";
  import { Team, teams, Player } from "../data/InitData";

  let createTeams = async function (teams: Team[]): Promise<void> {
    let leagueAgent = leagueAgentFactory();
    let promises = [];
    for (let i in teams) {
      let team = teams[i];
      let promise = leagueAgent.createTeam(team).then(async (result) => {
        if ("ok" in result) {
          let teamId = result.ok;
          console.log("Created team: ", teamId);
          await createPlayers(teamId, team.players);
        } else {
          console.log("Failed to make team: ", team);
        }
      });
      promises.push(promise);
    }
    await Promise.all(promises);
    teamStore.refetch();
  };

  let createPlayers = async function (
    teamId: Principal | undefined,
    players: Player[]
  ) {
    if (!teamId) {
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
    await createTeams(teams);
    playerStore.refetch();
  };
</script>

<button class="button-style" on:click={initialize}>
  Initialize With Default Data
</button>
