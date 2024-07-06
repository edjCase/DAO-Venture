<script lang="ts">
  import { Link } from "svelte-routing";
  import { teamStore } from "../../stores/TeamStore";
  import { Button, Modal } from "flowbite-svelte";
  import TeamLogo from "./TeamLogo.svelte";
  import { StarOutline, StarSolid } from "flowbite-svelte-icons";
  import { userStore } from "../../stores/UserStore";
  import { identityStore } from "../../stores/IdentityStore";
  import { User } from "../../ic-agent/declarations/main";
  import LoadingButton from "../common/LoadingButton.svelte";
  import { Team } from "../../ic-agent/declarations/main";

  $: teams = $teamStore;
  $: identity = $identityStore;

  let user: User | undefined;
  let associatedTeamId: bigint | undefined;
  $: {
    if (!identity.getPrincipal().isAnonymous()) {
      userStore.subscribeUser(identity.getPrincipal(), (u) => {
        user = u;
        associatedTeamId = u?.team[0]?.id;
      });
    }
  }

  let confirmModal: boolean = false;
  let confirmFavoriteTeamId: bigint | undefined;
  let setFavoriteTeam = async () => {
    if (identity.getPrincipal().isAnonymous()) {
      console.error("User not logged in");
      return;
    }
    if (confirmFavoriteTeamId === undefined) {
      console.error("Favorite team not selected");
      return;
    }
    let result = await userStore.setFavoriteTeam(
      identity.getPrincipal(),
      confirmFavoriteTeamId,
    );
    if ("ok" in result) {
      console.log("Favorite team set");
      userStore.refetchUser(identity.getPrincipal());
    } else {
      console.error("Failed to set favorite team", result);
    }
  };
  let selectedTeam: Team | undefined;
  $: selectedTeam = teams && teams[0];
</script>

<div class="flex flex-col justify-between">
  <div class="pb-10">
    {#if selectedTeam}
      <div class="flex justify-center items-center">
        <div class="text-3xl text-center m-5">{selectedTeam.name}</div>
        <div>
          {#if user}
            {#if associatedTeamId !== undefined}
              {#if associatedTeamId == selectedTeam.id}
                <StarSolid size="lg" />
              {/if}
            {:else}
              <StarOutline
                size="lg"
                role="button"
                on:click={() => {
                  if (selectedTeam) {
                    confirmFavoriteTeamId = selectedTeam.id;
                    confirmModal = true;
                  }
                }}
              />
            {/if}
          {/if}
        </div>
      </div>
      <TeamLogo team={selectedTeam} size="lg" />
      <blockquote class="mx-auto mb-4 max-w-2xl">
        <div class="mt-5">
          <div class="text-lg team-info-text text-justify">
            {selectedTeam.description}
          </div>
        </div>
      </blockquote>
      <div class="flex justify-center">
        <Link to={`/teams/${selectedTeam.id.toString()}`}>
          <Button>View Team Page</Button>
        </Link>
      </div>
    {/if}
  </div>
  {#if teams !== undefined}
    <div class="flex flex-wrap justify-around">
      {#each teams as team}
        <div
          class="mb-5 {selectedTeam === team ? 'opacity-50' : ''}"
          role="button"
          tabindex="0"
          on:keydown={() => {}}
          on:click={() => (selectedTeam = team)}
        >
          <TeamLogo {team} size="md" />
        </div>
      {/each}

      <Modal bind:open={confirmModal} autoclose>
        <div class="text-center">
          <h3 class="mb-5 text-lg font-normal text-gray-500 dark:text-gray-400">
            Setting your team is permanent for the season. Are you sure?
          </h3>
          <LoadingButton color="red" class="me-2" onClick={setFavoriteTeam}>
            Yes, I'm sure
          </LoadingButton>
          <Button color="alternative">No, cancel</Button>
        </div>
      </Modal>
    </div>
  {/if}
</div>
