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
    ScenarioResolvedScenario,
  } from "../../models/Scenario";
  import { teamStore } from "../../stores/TeamStore";
  import { Team } from "../../models/Team";

  export let scenario: ScenarioInstance | ScenarioResolvedScenario;
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
  <div class="p-5 pt-0">
    {@html scenarioData.description}
  </div>
  {#if scenarioData.choice}
    <div>
      <div class="font-bold">
        {@html scenarioData.options[scenarioData.choice].title}
      </div>
      <div class="">
        {@html scenarioData.options[scenarioData.choice].description}
      </div>
    </div>
  {:else}
    <div class="flex flex-col items-center gap-2">
      {#each scenarioData.options as { id, title, description }, index}
        <div
          class="border border-gray-300 p-4 rounded-lg flex-1 cursor-pointer text-left w-96 text-base text-white"
          class:bg-gray-500={selectedChoice === id}
          class:border-gray-500={selectedChoice === id}
          class:bg-gray-800={selectedChoice !== id}
          on:click={() => {
            selectedChoice = id;
          }}
          on:keypress={() => {}}
          role="button"
          tabindex={index}
        >
          <div class="font-bold">{@html title}</div>
          <div class="">
            {@html description}
          </div>
        </div>
      {/each}
    </div>
    <div class="flex justify-center p-5">
      <Button
        on:click={() => {
          register();
        }}
      >
        Submit Vote
      </Button>
    </div>
  {/if}
</div>
