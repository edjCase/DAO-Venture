<script lang="ts">
    import TeamCreateProposal from "../components/dao/TeamCreateProposal.svelte";
    import TeamProposalList from "../components/dao/TeamProposalList.svelte";
    import TeamLogo from "../components/team/TeamLogo.svelte";
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
    <div class="text-5xl text-center mb-2">{team.name}</div>
    <TeamLogo {team} size="lg" />
    {#if coOwner}
        <div class="mt-5">
            <TeamProposalList teamId={team.id} />
        </div>
        <div class="mt-5">
            <TeamCreateProposal teamId={team.id} />
        </div>
    {:else}
        You are just a fan
    {/if}
{:else}
    <div>No Team</div>
{/if}
