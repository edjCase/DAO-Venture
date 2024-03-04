<script lang="ts">
  import { Button } from "flowbite-svelte";

  import { teamAgentFactory } from "../../ic-agent/Team";
  import { teamStore } from "../../stores/TeamStore";
  import { VoteOnMatchGroupRequest } from "../../ic-agent/declarations/team";
  import { Scenario } from "../../ic-agent/declarations/league";
  import { userStore } from "../../stores/UserStore";

  export let scenario: Scenario;
  export let matchGroupId: number;

  let selectedChoice: number | undefined;

  $: user = $userStore;

  let teamId = user?.user?.teamAssociation[0]?.id;
  let isOwner = teamId && user!.user!.teamAssociation[0]!.kind;

  let register = function () {
    if (!isOwner || !teamId) {
      console.log("User cant vote unless they are a team owner");
      return;
    }
    if (selectedChoice === undefined) {
      console.log("No choice selected");
      return;
    }
    let request: VoteOnMatchGroupRequest = {
      matchGroupId: BigInt(matchGroupId),
      scenarioChoice: selectedChoice,
    };
    console.log(
      `Voting for team ${teamId} and match group ${matchGroupId}`,
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
    {@html scenario.description}
  </div>
  <div class="flex flex-col items-center gap-2">
    {#each scenario.options as { title, description }, index}
      <div
        class="border border-gray-300 p-4 rounded-lg flex-1 cursor-pointer text-left w-96 text-base text-white"
        class:bg-gray-500={selectedChoice === index}
        class:border-gray-500={selectedChoice === index}
        class:bg-gray-800={selectedChoice !== index}
        on:click={() => {
          selectedChoice = index;
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
  {#if isOwner}
    <div class="flex justify-center p-5">
      <Button
        on:click={() => {
          register();
        }}
      >
        Submit Vote for Team {teamId}
      </Button>
    </div>
  {/if}
</div>
