<script lang="ts">
  import { teamStore } from "../stores/TeamStore";
  import { stadiumStore } from "../stores/StadiumStore";
  import CardList from "./CardList.svelte";
  import type { Principal } from "@dfinity/principal";
  import { teamAgentFactory } from "../ic-agent/Team";
  import type { Match } from "../ic-agent/Stadium";
  import { matchStore } from "../stores/MatchStore";

  export let teamId: Principal;
  export let stadiumId: Principal;
  export let matchId: number;
  let selectedOffering = -1;
  let selectedSpecialRule = -1;
  let offeringCards;
  let specialRuleCards;
  let match: Match;

  let register = function () {
    let request = {
      stadiumId: stadiumId,
      matchId: matchId,
      vote: {
        offeringId: selectedOffering,
        specialRuleId: selectedOffering,
      },
    };
    console.log(
      `Voting for team ${teamId.toString()} and match ${matchId}`,
      request
    );
    teamAgentFactory(teamId)
      .voteForMatchOptions(request)
      .then((result) => {
        console.log("Voted for match: ", result);
        teamStore.refetch();
      })
      .catch((err) => {
        console.log("Failed to vote for match: ", err);
      });
  };

  matchStore.subscribe((matches) => {
    match = matches.find((item) => item.id == matchId);

    offeringCards = match.offerings.map((offering) => {
      return {
        id: offering.id,
        title: offering.deities.join(", "),
        description: offering.effects.join(", "),
      };
    });
    specialRuleCards = match.specialRules.map((r) => {
      return {
        id: r.id,
        title: r.name,
        description: r.description,
      };
    });
  });
</script>

{#if match}
  <div>
    <h2>Offerings</h2>
    <CardList cards={offeringCards} onSelect={(i) => (selectedOffering = i)} />
  </div>
  <div>
    <h2>Special Rule</h2>
    <CardList
      cards={specialRuleCards}
      onSelect={(i) => (selectedSpecialRule = i)}
    />
  </div>
  <button on:click={register}>Submit Vote</button>
{/if}
