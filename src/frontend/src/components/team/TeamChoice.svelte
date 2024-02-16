<script lang="ts">
  import { teamStore } from "../../stores/TeamStore";
  import {
    VoteOnMatchGroupRequest,
    teamAgentFactory,
  } from "../../ic-agent/Team";
  import { Button } from "flowbite-svelte";
  import { Principal } from "@dfinity/principal";
  import {
    ScenarioInstance,
    ScenarioInstanceWithChoice,
  } from "../../models/Scenario";
  import { Team } from "../../models/Team";
  import { playerStore } from "../../stores/PlayerStore";
  import { Player } from "../../ic-agent/Players";

  export let scenario: ScenarioInstance | ScenarioInstanceWithChoice;
  export let matchGroupId: number;

  type ScenarioOptionData = {
    id: number;
    title: string;
    description: string;
    // TODO effect text
  };

  type ScenarioData = {
    id: string;
    title: string;
    description: string;
    teamName: string;
    opposingTeamName: string;
    otherTeamNames: string[];
    playerNames: string[];
    options: ScenarioOptionData[];
    choice: number | undefined;
  };

  type Options = {
    scenario: ScenarioData;
    selectedOption: number | undefined;
  };

  let register = function (options: Options) {
    if (!options.selectedOption) {
      console.log("No choice selected");
      return;
    }
    let request: VoteOnMatchGroupRequest = {
      matchGroupId: matchGroupId,
      choice: options.selectedOption,
    };
    console.log(
      `Voting for team ${scenario.teamId.toString()} and match group ${matchGroupId}`,
      request
    );
    teamAgentFactory(scenario.teamId)
      .voteOnMatchGroup(request)
      .then((result) => {
        console.log("Voted for match: ", result);
        teamStore.refetch();
      })
      .catch((err) => {
        console.log("Failed to vote for match: ", err);
      });
  };

  let buildData = function (
    allTeams: Team[],
    allPlayers: Player[]
  ): Options | undefined {
    if (allTeams.length == 0 || allPlayers.length == 0) {
      return undefined;
    }
    let getTeam = (id: Principal): Team => {
      let teamOrUndefined = allTeams.find(
        (team) => team.id.compareTo(id) === "eq"
      );
      if (teamOrUndefined === undefined) {
        throw new Error(`Team with id ${id} not found`);
      }
      return teamOrUndefined;
    };
    let getPlayer = (id: number): Player => {
      let playerOrUndefined = allPlayers.find((player) => player.id == id);
      if (playerOrUndefined === undefined) {
        throw new Error(`Player with id ${id} not found`);
      }
      return playerOrUndefined;
    };
    let scenarioTeam = getTeam(scenario.teamId);
    let opposingTeam = getTeam(scenario.opposingTeamId);
    let otherTeams = scenario.otherTeamIds.map((id) => getTeam(id));
    let players = scenario.playerIds.map((id) => getPlayer(id));

    let replaceStringValue = function (
      text: string,
      key: string,
      value: string,
      color: [number, number, number]
    ): string {
      let regex = new RegExp(`{${key}}`, "g");
      value =
        `<span class='font-bold' style='color: rgb(${color})'>` +
        value +
        "</span>";
      return text.replace(regex, value);
    };

    let replaceText = function (text: string): string {
      text = replaceStringValue(
        text,
        "ScenarioTeam",
        scenarioTeam.name,
        scenarioTeam.color
      );
      text = replaceStringValue(
        text,
        "OpposingTeam",
        opposingTeam.name,
        opposingTeam.color
      );
      for (let i = 0; i < otherTeams.length; i++) {
        text = replaceStringValue(
          text,
          `OtherTeam${i}`,
          otherTeams[i].name,
          otherTeams[i].color
        );
      }
      for (let i = 0; i < players.length; i++) {
        let player = players[i];
        let playerTeam = player && getTeam(player.teamId);
        text = replaceStringValue(
          text,
          `Player${i}`,
          player.name,
          playerTeam.color
        );
      }
      return text;
    };
    let options = scenario.template.options.map((option, i) => {
      return {
        id: i,
        title: replaceText(option.title),
        description: replaceText(option.description),
      };
    });
    return {
      scenario: {
        id: scenario.template.id,
        title: replaceText(scenario.template.title),
        description: replaceText(scenario.template.description),
        teamName: scenarioTeam.name,
        opposingTeamName: opposingTeam.name,
        otherTeamNames: otherTeams.map((team: Team) => team.name),
        playerNames: players.map((player: Player) => player.name),
        options: options,
        choice: "choice" in scenario ? scenario.choice : undefined,
      },
      selectedOption: undefined,
    };
  };

  $: teams = $teamStore;
  $: players = $playerStore;
  $: data = buildData(teams, players);
</script>

<div class="container">
  {#if !data}
    <div>Loading...</div>
  {:else}
    <div>
      {@html data.scenario.title}
    </div>
    <div>
      {@html data.scenario.description}
    </div>
    {#if data.scenario.choice}
      <div>
        <div class="title">
          {@html data.scenario.options[data.scenario.choice].title}
        </div>
        <div class="description">
          {@html data.scenario.options[data.scenario.choice].description}
        </div>
      </div>
    {:else}
      <div class="card-container">
        {#each data.scenario.options as { id, title, description }, index}
          <div
            class="card"
            class:selected={data.selectedOption === id}
            on:click={() => {
              if (data) {
                data.selectedOption = id;
              }
            }}
            on:keypress={() => {}}
            role="button"
            tabindex={index}
          >
            <div class="title">{@html title}</div>
            <div class="description">
              {@html description}
            </div>
          </div>
        {/each}
      </div>
      <Button
        on:click={() => {
          if (data) {
            register(data);
          }
        }}
      >
        Submit Vote
      </Button>
    {/if}
  {/if}
</div>

<style>
  .container {
    display: flex;
    flex-direction: column;
  }
  .card-container {
    display: flex;
    gap: 16px;
  }
  .card {
    border: 1px solid #ddd;
    padding: 16px;
    background-color: var(--color-bg-dark);
    border-radius: 8px;
    flex: 1;
    cursor: pointer;
    text-align: left;
    width: 400px;
    font-size: 1em;
    color: var(--color-text);
  }
  .card.selected {
    background-color: #e0f7fa;
    border-color: #00838f;
    color: black;
  }

  .title {
    font-weight: bold;
  }
</style>
