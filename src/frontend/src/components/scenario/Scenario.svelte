<script lang="ts" context="module">
  export type ScenarioOptionData = {
    id: number;
    title: string;
    description: string;
    // TODO effect text
  };
  export type ScenarioData = {
    id: string;
    title: string;
    description: string;
    team: Team;
    opposingTeamName: string;
    otherTeamNames: string[];
    playerNames: string[];
    options: ScenarioOptionData[];
    choice: number | undefined;
  };
</script>

<script lang="ts">
  import { Button } from "flowbite-svelte";

  import {
    VoteOnMatchGroupRequest,
    teamAgentFactory,
  } from "../../ic-agent/Team";
  import {
    ScenarioInstance,
    ScenarioInstanceWithChoice,
  } from "../../models/Scenario";
  import { teamStore } from "../../stores/TeamStore";
  import { Team } from "../../models/Team";

  export let scenario: ScenarioInstance | ScenarioInstanceWithChoice;
  export let scenarioData: ScenarioData;
  export let matchGroupId: number;

  let selectedChoice: number | undefined;

  let register = function () {
    if (selectedChoice === undefined) {
      console.log("No choice selected");
      return;
    }
    let request: VoteOnMatchGroupRequest = {
      matchGroupId: matchGroupId,
      scenarioChoice: selectedChoice,
    };
    console.log(
      `Voting for team ${scenarioData.team.name} and match group ${matchGroupId}`,
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
</script>

<div>
  <div>
    {@html scenarioData.description}
  </div>
  {#if scenarioData.choice}
    <div>
      <div class="title">
        {@html scenarioData.options[scenarioData.choice].title}
      </div>
      <div class="description">
        {@html scenarioData.options[scenarioData.choice].description}
      </div>
    </div>
  {:else}
    <div class="flex flex-col">
      {#each scenarioData.options as { id, title, description }, index}
        <div
          class="card"
          class:selected={selectedChoice === id}
          on:click={() => {
            selectedChoice = id;
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
        register();
      }}
    >
      Submit Vote
    </Button>
  {/if}
</div>

<style>
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
