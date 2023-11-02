<script lang="ts">
  import { teamStore } from "../stores/TeamStore";
  import CardList from "./CardList.svelte";
  import type { Principal } from "@dfinity/principal";
  import { VoteMatchOptionsRequest, teamAgentFactory } from "../ic-agent/Team";
  import type { Match, Offering } from "../ic-agent/Stadium";
  import { matchStore } from "../stores/MatchStore";
  import PlayerPicker from "./PlayerPicker.svelte";
  import { Player } from "../models/Player";

  export let teamId: Principal;
  export let stadiumId: Principal;
  export let matchId: number;

  type Card = {
    id: string;
    title: string;
    description: string;
  };

  let selectedOffering: string | undefined;
  let selectedChampion: number | undefined;
  let offeringCards: Card[] = [];
  let championChoices: Player[] | undefined;
  let match: Match | undefined;

  let register = function () {
    if (!selectedOffering || !selectedChampion) {
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
    let request: VoteMatchOptionsRequest = {
      stadiumId: stadiumId,
      matchId: matchId,
      vote: {
        offering: offering,
        champion: selectedChampion,
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
    }
  });
</script>

{#if match}
  <div>
    <h2>Offerings</h2>
    <CardList cards={offeringCards} onSelect={(i) => (selectedOffering = i)} />
  </div>
  <div>
    <h2>Champion</h2>
    <PlayerPicker players={championChoices || []} initialPlayerId={undefined} />
  </div>
  <button on:click={register}>Submit Vote</button>
{/if}
