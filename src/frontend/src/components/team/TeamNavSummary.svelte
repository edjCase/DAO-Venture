<script lang="ts">
    import { TeamStandingInfo } from "../../ic-agent/declarations/league";
    import { User } from "../../ic-agent/declarations/users";
    import { identityStore } from "../../stores/IdentityStore";
    import { teamStore } from "../../stores/TeamStore";
    import { userStore } from "../../stores/UserStore";
    import TeamLogo from "./TeamLogo.svelte";

    $: identity = $identityStore;
    $: teams = $teamStore;

    let user: User | undefined;
    let standings: TeamStandingInfo[] | undefined;

    teamStore.subscribeTeamStandings((s) => {
        standings = s;
    });

    $: {
        if (!identity.getPrincipal().isAnonymous()) {
            userStore.subscribeUser(identity.getPrincipal(), (u) => {
                user = u;
            });
        }
    }
    $: team = teams?.find((t) => t.id === user?.team[0]?.id);

    $: standing = standings?.find((s) => s.id == team?.id) || {
        wins: 0,
        losses: 0,
    };
</script>

{#if team}
    <div class="text-xs text-center flex items-center jusity-center gap-2">
        <TeamLogo {team} size="sm" />
        <div>
            <div>{standing.wins} - {standing.losses}</div>
            <div>Energy: {team.energy}</div>
            <div>Entropy: {team.entropy}</div>
        </div>
    </div>
{:else}
    <div class="w-10 h-10" />
{/if}
