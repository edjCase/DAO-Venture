<script lang="ts">
  import { teamStore } from "../stores/TeamStore";
  import CardList from "./CardList.svelte";
  import type { Principal } from "@dfinity/principal";
  import { VoteOnMatchGroupRequest, teamAgentFactory } from "../ic-agent/Team";
  import type { Offering } from "../ic-agent/Stadium";
  import PlayerPicker from "./PlayerPicker.svelte";
  import { Player } from "../models/Player";
  import { playerStore } from "../stores/PlayerStore";
  import {
    getOfferingDetails,
    matchGroupStore,
  } from "../stores/MatchGroupStore";
  import { get } from "svelte/store";

  export let teamId: Principal;
  export let stadiumId: Principal;
  export let matchGroupId: number;

  type Card = {
    id: string;
    title: string;
    description: string;
  };

  type Match = {
    offeringCards: Card[];
    selectedOffering: string | undefined;
    championChoices: Player[];
    selectedChampion: number | undefined;
  };

  let matches: Match[] | undefined;

  let register = function (match: Match) {
    if (!match.selectedOffering || !match.selectedChampion) {
      console.log("No offering or champion selected");
      return;
    }
    let offering: Offering;
    switch (match.selectedOffering) {
      case "mischief":
        offering = { shuffleAndBoost: null };
        break;
      // case "war":
      //   offering = { war: { b: null } };
      //   break;
      // case "indulgence":
      //   offering = { indulgence: { c: null } };
      //   break;
      // case "pestilence":
      //   offering = { pestilence: { d: null } };
      //   break;
      default:
        throw new Error("Invalid offering: " + match.selectedOffering);
    }
    let request: VoteOnMatchGroupRequest = {
      matchGroupId: matchGroupId,
      offering: offering,
      champion: match.selectedChampion,
    };
    console.log(
      `Voting for team ${teamId.toString()} and match group ${matchGroupId}`,
      request
    );
    teamAgentFactory(teamId)
      .voteOnMatchGroup(request)
      .then((result) => {
        console.log("Voted for match: ", result);
        teamStore.refetch();
      })
      .catch((err) => {
        console.log("Failed to vote for match: ", err);
      });
  };

  matchGroupStore.subscribe((matchGroups) => {
    let matchGroup = matchGroups.find((g) => g.id == matchGroupId);
    if (matchGroup) {
      matches = matchGroup.matches.map((m, i) => {
        let offeringCards = m.offerings.map((o) => {
          let offeringDetails = getOfferingDetails(o);
          return {
            id: i.toString(),
            title: offeringDetails.name,
            description: offeringDetails.description,
          };
        });
        let players = get(playerStore);
        let championChoices = players || [];
        return {
          offeringCards: offeringCards,
          selectedOffering: undefined,
          championChoices: championChoices,
          selectedChampion: undefined,
        };
      });
    }
  });
</script>

{#if matches}
  {#each matches as match}
    <div>
      <h2>Offerings</h2>
      <CardList
        cards={match.offeringCards}
        onSelect={(i) => (match.selectedOffering = i)}
      />
    </div>
    <div>
      <h2>Champion</h2>
      {#if match.championChoices}
        <PlayerPicker
          players={match.championChoices}
          onPlayerSelected={(pId) => (match.selectedChampion = pId)}
        />
      {/if}
    </div>
    <button on:click={() => register(match)}>Submit Vote</button>
  {/each}
{/if}
