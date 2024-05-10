<script lang="ts">
    import { User } from "../../ic-agent/declarations/users";
    import { identityStore } from "../../stores/IdentityStore";
    import { teamStore } from "../../stores/TeamStore";
    import { userStore } from "../../stores/UserStore";
    import TeamLogo from "./TeamLogo.svelte";

    $: identity = $identityStore;
    $: teams = $teamStore;

    let user: User | undefined;

    $: {
        if (!identity.getPrincipal().isAnonymous()) {
            userStore.subscribeUser(identity.getPrincipal(), (u) => {
                user = u;
            });
        }
    }
    $: team = teams?.find((t) => t.id === user?.team[0]?.id);
</script>

{#if team}
    <TeamLogo {team} size="xs" stats={true} />
{:else}
    <div class="w-10 h-10" />
{/if}
