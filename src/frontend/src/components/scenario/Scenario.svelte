<script lang="ts">
  import { Button } from "flowbite-svelte";

  import { teamAgentFactory } from "../../ic-agent/Team";
  import { teamStore } from "../../stores/TeamStore";
  import { VoteOnScenarioRequest } from "../../ic-agent/declarations/team";
  import { Scenario } from "../../ic-agent/declarations/league";
  import { identityStore } from "../../stores/IdentityStore";
  import { userStore } from "../../stores/UserStore";
  import { Principal } from "@dfinity/principal";
  import { User } from "../../ic-agent/declarations/users";

  export let scenario: Scenario;

  let selectedChoice: number | undefined;

  $: identity = $identityStore;

  let user: User | undefined;
  let teamId: Principal | undefined;
  let isOwner: boolean | undefined;
  $: {
    if (identity) {
      userStore.subscribeUser(identity.id, (u) => {
        user = u;
        teamId = user?.team[0]?.id;
        isOwner = teamId && "owner" in user!.team[0]!.kind;
      });
    }
  }

  let register = function () {
    if (!isOwner || !teamId) {
      console.log("User cant vote unless they are a team owner");
      return;
    }
    if (selectedChoice === undefined) {
      console.log("No choice selected");
      return;
    }
    let request: VoteOnScenarioRequest = {
      scenarioId: scenario.id,
      option: BigInt(selectedChoice),
    };
    console.log(
      `Voting for team ${teamId} and scenario ${scenario.id} with option ${selectedChoice}`,
      request,
    );
    teamAgentFactory(teamId)
      .voteOnScenario(request)
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
