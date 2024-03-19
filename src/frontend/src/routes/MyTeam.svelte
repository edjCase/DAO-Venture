<script lang="ts">
    import TeamCreateProposal from "../components/dao/TeamCreateProposal.svelte";
    import TeamProposalList from "../components/dao/TeamProposalList.svelte";
    import { User } from "../ic-agent/declarations/users";
    import { identityStore } from "../stores/IdentityStore";
    import { teamStore } from "../stores/TeamStore";
    import { userStore } from "../stores/UserStore";

    $: identity = $identityStore;
    $: teams = $teamStore;

    let user: User | undefined;

    $: {
        if (identity.getPrincipal().isAnonymous()) {
            user = undefined;
        } else {
            userStore.subscribeUser(identity.getPrincipal(), (u) => {
                user = u;
            });
        }
    }
    $: team = teams.find((t) => t.id == user?.team[0]?.id);
    $: coOwner = user?.team[0]?.kind && "owner" in user.team[0].kind;
</script>

{#if team}
    <div class="text-3xl text-center">{team.name}</div>
    {#if coOwner}
        <TeamProposalList teamId={team.id} />
        <TeamCreateProposal teamId={team.id} />
    {:else}
        You are just a fan
    {/if}
{:else}
    <div>No Team</div>
{/if}
