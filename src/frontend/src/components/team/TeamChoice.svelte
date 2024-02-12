<script lang="ts">
  import { teamStore } from "../../stores/TeamStore";
  import {
    VoteOnMatchGroupRequest,
    teamAgentFactory,
  } from "../../ic-agent/Team";
  import { Button } from "flowbite-svelte";
  import { TeamDetails } from "../../models/Match";
  import { Scenario } from "../../models/Scenario";

  export let team: TeamDetails;
  export let matchGroupId: number;

  let optionsOrUndefined: Options | undefined;

  type Card = {
    id: number;
    title: string;
    description: string;
  };

  type Options = {
    scenario: Scenario;
    optionCards: Card[];
    selectedOption: number | undefined;
  };

  let register = function (options: Options) {
    if (!options.selectedOption) {
      console.log("No offering selected");
      return;
    }
    let request: VoteOnMatchGroupRequest = {
      matchGroupId: matchGroupId,
      choice: options.selectedOption,
    };
    console.log(
      `Voting for team ${team.id.toString()} and match group ${matchGroupId}`,
      request
    );
    teamAgentFactory(team.id)
      .voteOnMatchGroup(request)
      .then((result) => {
        console.log("Voted for match: ", result);
        teamStore.refetch();
      })
      .catch((err) => {
        console.log("Failed to vote for match: ", err);
      });
  };

  if (team.scenario) {
    let optionCards = team.scenario.options.map((o, i) => {
      return {
        id: i,
        title: o.name,
        description: o.description,
      };
    });
    optionsOrUndefined = {
      scenario: team.scenario,
      optionCards: optionCards,
      selectedOption: undefined,
    };
  }
</script>

<div class="container">
  {#if optionsOrUndefined}
    <div>
      <div class="card-container">
        {#each optionsOrUndefined.optionCards as { id, title, description }, index}
          <div
            class="card"
            class:selected={optionsOrUndefined.selectedOption === id}
            on:click={() => {
              if (optionsOrUndefined) {
                optionsOrUndefined.selectedOption = id;
              }
            }}
            on:keypress={() => {}}
            role="button"
            tabindex={index}
          >
            <div class="title">{title}</div>
            <div class="description">{description}</div>
          </div>
        {/each}
      </div>
    </div>
    <Button
      on:click={() => {
        if (optionsOrUndefined) {
          register(optionsOrUndefined);
        }
      }}>Submit Vote</Button
    >
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
