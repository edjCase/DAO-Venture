<script lang="ts">
  import { teamStore } from "../../stores/TeamStore";
  import CardList from "../common/CardList.svelte";
  import type { Principal } from "@dfinity/principal";
  import {
    VoteOnMatchGroupRequest,
    teamAgentFactory,
  } from "../../ic-agent/Team";
  import PlayerPicker from "./../player/PlayerPicker.svelte";
  import { playerStore } from "../../stores/PlayerStore";
  import { get } from "svelte/store";
  import { scheduleStore } from "../../stores/ScheduleStore";
  import { Offering } from "../../models/Offering";
  import { Button } from "flowbite-svelte";
  import { Player } from "../../ic-agent/PlayerLedger";

  export let teamId: Principal;
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

  let match: Match | undefined;

  let register = function (match: Match) {
    if (!match.selectedOffering || !match.selectedChampion) {
      console.log("No offering or champion selected");
      return;
    }
    let offering: Offering = { [match.selectedOffering]: null } as Offering;
    let request: VoteOnMatchGroupRequest = {
      matchGroupId: BigInt(matchGroupId),
      offering: offering,
      championId: match.selectedChampion,
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

  scheduleStore.subscribeMatchGroups((matchGroups) => {
    let matchGroup = matchGroups.find((g) => g.id == matchGroupId);
    if (!matchGroup) {
      return;
    }
    let unmappedMatch = matchGroup.matches.find(
      (m) => m.team1.id == teamId || m.team2.id == teamId
    );
    if (!unmappedMatch || !unmappedMatch.offeringOptions) {
      return;
    }
    let offeringCards = unmappedMatch.offeringOptions.map((o) => {
      return {
        id: Object.keys(o.offering)[0],
        title: o.name,
        description: o.description,
      };
    });
    let players = get(playerStore);
    let championChoices =
      players.filter(
        (p) => p.teamId.length > 0 && p.teamId[0]?.compareTo(teamId) == "eq"
      ) || [];
    match = {
      offeringCards: offeringCards,
      selectedOffering: undefined,
      championChoices: championChoices,
      selectedChampion: undefined,
    };
  });
</script>

<div class="container">
  {#if match}
    <div>
      <h2>Offerings</h2>
      <CardList
        cards={match.offeringCards}
        onSelect={(i) => {
          if (match) {
            match.selectedOffering = i;
          }
        }}
      />
    </div>
    <div>
      <h2>Champion</h2>
      {#if match.championChoices}
        <PlayerPicker
          players={match.championChoices}
          onPlayerSelected={(pId) => {
            if (match) {
              match.selectedChampion = pId;
            }
          }}
        />
      {/if}
    </div>
    <Button
      on:click={() => {
        if (match) {
          register(match);
        }
      }}>Submit Vote</Button
    >
  {/if}
</div>

<style>
  .container {
    display: flex;
    flex-direction: column;
  }
</style>
