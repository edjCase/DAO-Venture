<script lang="ts">
  import { Link } from "svelte-routing";
  import { teamStore } from "../../stores/TeamStore";
  import { Button, Card, Modal } from "flowbite-svelte";
  import TeamLogo from "./TeamLogo.svelte";
  import { StarOutline, StarSolid } from "flowbite-svelte-icons";
  import { userStore } from "../../stores/UserStore";
  import { identityStore } from "../../stores/IdentityStore";
  import { User } from "../../ic-agent/declarations/users";

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
      console.log("User not logged in");
      return;
    }
    if (confirmFavoriteTeamId) {
      await userStore.setFavoriteTeam(
        identity.getPrincipal(),
        confirmFavoriteTeamId,
      );
    }
  };
</script>

<div>
  <Card
    padding="none"
    size="xl"
    class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4"
  >
    {#each teams as team}
      <figure
        class="p-8 rounded-t-lg border-b md:rounded-t-none md:rounded-tl-lg md:border-e bg-white border-gray-200 dark:bg-gray-800 dark:border-gray-700"
      >
        <div class="flex justify-center items-center gap-5">
          <div class="text-2xl font-semibold text-center">
            {team.name}
          </div>
          <div>
            {#if user}
              {#if associatedTeamId !== undefined}
                {#if associatedTeamId == team.id}
                  <StarSolid size="lg" />
                {/if}
              {:else}
                <StarOutline
                  size="lg"
                  role="button"
                  on:click={() => {
                    confirmFavoriteTeamId = team.id;
                    confirmModal = true;
                  }}
                />
              {/if}
            {/if}
          </div>
        </div>
        <div class="team-logo-container m-5">
          <Link to={`/teams/${team.id.toString()}`}>
            <TeamLogo {team} size="lg" />
          </Link>
        </div>
        <blockquote class="mx-auto mb-4 max-w-2xl">
          <div class="team-info">
            <div class="text-lg team-info-text text-justify">
              {team.description}
            </div>
          </div>
        </blockquote>
      </figure>
    {/each}
  </Card>

  <Modal bind:open={confirmModal} autoclose>
    <div class="text-center">
      <h3 class="mb-5 text-lg font-normal text-gray-500 dark:text-gray-400">
        Setting your team is permanent for the season. Are you sure?
      </h3>
      <Button color="red" class="me-2" on:click={setFavoriteTeam}>
        Yes, I'm sure
      </Button>
      <Button color="alternative">No, cancel</Button>
    </div>
  </Modal>
</div>

<style>
  .team-logo-container {
    flex: 1;
    display: flex;
    justify-content: center;
  }

  .team-info {
    margin: 5px 0;
    display: block;
  }
  .team-info-text {
    font-weight: normal;
  }
</style>
