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
    team: TeamWithId;
    opposingTeamName: string;
    otherTeamNames: string[];
    playerNames: string[];
    options: ScenarioOptionData[];
    choice: number | undefined;
  };
</script>

<script lang="ts">
  import { Button } from "flowbite-svelte";

  import { teamAgentFactory } from "../../ic-agent/Team";
  import { teamStore } from "../../stores/TeamStore";
  import { VoteOnMatchGroupRequest } from "../../ic-agent/declarations/team";
  import { TeamWithId } from "../../ic-agent/declarations/league";
  import { userStore } from "../../stores/UserStore";
  import { Principal } from "@dfinity/principal";

  export let scenarioData: ScenarioData;
  export let matchGroupId: bigint;

  let selectedChoice: number | undefined;

  $: user = $userStore;

  let register = function (teamId: Principal) {
    if (user === undefined) {
      console.log("No user logged in");
      return;
    }
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
      request,
    );
    teamAgentFactory(teamId)
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
    {#if user?.user?.teamId}
      <div class="flex justify-center p-5">
        <Button
          on:click={() => {
            register(user.user.teamId);
          }}
        >
          Submit Vote for Team {user.user?.favoriteTeamId}
        </Button>
      </div>
    {/if}
  {/if}
</div>
