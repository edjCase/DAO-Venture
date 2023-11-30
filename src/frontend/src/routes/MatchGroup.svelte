<script lang="ts">
  import VoteForMatchGroup from "../components/VoteForMatchGroup.svelte";
  import MatchGroupCardGrid, {
    MatchGroupVariant,
  } from "../components/MatchGroupCardGrid.svelte";
  import { navigate } from "svelte-routing";
  import { SeasonMatchGroups, scheduleStore } from "../stores/ScheduleStore";

  export let matchGroupIdString: string;

  let matchGroupId = Number(matchGroupIdString);
  if (isNaN(matchGroupId)) {
    // Handle the error, such as redirecting to an error page or showing a message
    navigate("/404", { replace: true });
  }

  let matchGroup: MatchGroupVariant | undefined;

  scheduleStore.subscribeMatchGroups(
    (seasonMatchGroups: SeasonMatchGroups | undefined) => {
      if (seasonMatchGroups) {
        let completedMatchGroup = seasonMatchGroups.completed.find(
          (mg) => mg.id == matchGroupId
        );
        if (completedMatchGroup) {
          matchGroup = { completed: completedMatchGroup };
          return;
        }
        let nextMatchGroup =
          seasonMatchGroups.next?.id == matchGroupId
            ? seasonMatchGroups.next
            : undefined;
        if (nextMatchGroup) {
          if ("inProgress" in nextMatchGroup.type) {
            matchGroup = { live: nextMatchGroup.type.inProgress };
          } else {
            matchGroup = { next: nextMatchGroup.type.scheduled };
          }
          return;
        }
        let upcomingMatchGroup = seasonMatchGroups.upcoming.find(
          (mg) => mg.id == matchGroupId
        );
        if (upcomingMatchGroup) {
          matchGroup = { upcoming: upcomingMatchGroup };
          return;
        }
      }
      throw new Error(
        `Match group ${matchGroupId} not found in season schedule`
      );
    }
  );
</script>

{#if !!matchGroup}
  <section>
    <section class="match-details">
      {#if "upcoming" in matchGroup}
        <h1>
          Start Time: {matchGroup.upcoming.time.toLocaleString()}
        </h1>
      {:else if "completed" in matchGroup}
        <div>Match Group is over</div>
      {:else if "live" in matchGroup}
        <div>Match Group is LIVE!</div>
      {/if}

      <MatchGroupCardGrid {matchGroup} />

      {#if "next" in matchGroup}
        {#each matchGroup.next.matches as match, index}
          <h1>Vote: {match.team1.name} vs {match.team2.name}</h1>
          <div class="match-vote">
            <div class="team-vote">
              <h1>{match.team1.name}</h1>
              <VoteForMatchGroup matchGroupId={index} teamId={match.team1.id} />
            </div>
            <div class="team-vote">
              <h1>{match.team2.name}</h1>
              <VoteForMatchGroup matchGroupId={index} teamId={match.team2.id} />
            </div>
          </div>
        {/each}
      {/if}
    </section>
  </section>
{:else}
  Loading...
{/if}

<style>
  section {
    margin-bottom: 20px;
  }
  .match-details {
    display: flex;
    flex-direction: column;
    align-items: center;
  }
  .match-vote {
    display: flex;
    flex-direction: row;
    align-items: center;
  }
  .team-vote {
    margin: 20px;
  }
</style>
