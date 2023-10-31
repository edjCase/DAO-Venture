<script lang="ts">
  import { teamStore } from "../stores/TeamStore";
  import CardList from "./CardList.svelte";
  import type { Principal } from "@dfinity/principal";
  import { VoteMatchOptionsRequest, teamAgentFactory } from "../ic-agent/Team";
  import type { Match, Offering, SpecialRule } from "../ic-agent/Stadium";
  import { matchStore } from "../stores/MatchStore";

  export let teamId: Principal;
  export let stadiumId: Principal;
  export let matchId: number;

  type Card = {
    id: string;
    title: string;
    description: string;
  };

  let selectedOffering: string | undefined;
  let selectedSpecialRule: string | undefined;
  let offeringCards: Card[] = [];
  let specialRuleCards: Card[] = [];
  let match: Match | undefined;

  let register = function () {
    if (!selectedOffering || !selectedSpecialRule) {
      return;
    }
    let offering: Offering;
    switch (selectedOffering) {
      case "mischief":
        offering = { mischief: { a: null } };
        break;
      case "war":
        offering = { war: { b: null } };
        break;
      case "indulgence":
        offering = { indulgence: { c: null } };
        break;
      case "pestilence":
        offering = { pestilence: { d: null } };
        break;
      default:
        throw new Error("Invalid offering: " + selectedOffering);
    }
    let specialRule: SpecialRule;
    switch (selectedSpecialRule) {
      case "playersAreFaster":
        specialRule = { playersAreFaster: null };
        break;
      case "explodingBalls":
        specialRule = { explodingBalls: null };
        break;
      case "fastBallsHardHits":
        specialRule = { fastBallsHardHits: null };
        break;
      case "highBlessingAndCurses":
        specialRule = { highBlessingAndCurses: null };
        break;
      default:
        throw new Error("Invalid special rule: " + selectedSpecialRule);
    }
    let request: VoteMatchOptionsRequest = {
      stadiumId: stadiumId,
      matchId: matchId,
      vote: {
        offering: offering,
        specialRule: specialRule,
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
    if (match) {
      offeringCards = match.offerings.map((o) => {
        let a = Object.keys(o)[0]; // TODO
        return {
          id: a,
          title: a,
          description: a,
        };
      });
      specialRuleCards = match.specialRules.map((r) => {
        let a = Object.keys(r)[0]; // TODO
        return {
          id: a,
          title: a,
          description: a,
        };
      });
    }
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
