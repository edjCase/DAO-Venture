<script lang="ts">
    import { teamStore } from "../../stores/TeamStore";
    import { userStore } from "../../stores/UserStore";
    import TeamLogo from "./TeamLogo.svelte";

    $: user = $userStore;
    $: teams = $teamStore;

    $: team = teams?.find((t) => t.id === user?.team[0]?.id);
</script>

{#if team}
    <TeamLogo {team} size="xs" stats={true} />
{:else}
    <div class="w-10 h-10" />
{/if}
