<script lang="ts">
  import { teamStore } from "../stores/TeamStore";
  import { stadiumStore } from "../stores/StadiumStore";
  import CardList from "./CardList.svelte";
  import { Principal } from "@dfinity/principal";
  import { teamAgentFactory, type MatchOptionsVote } from "../ic-agent/Team";
  import { stadiumAgentFactory, type Match } from "../ic-agent/Stadium";
  $: teams = $teamStore;
  $: stadiums = $stadiumStore;

  let teamId: string;
  let stadiumId: string;
  let matchId: number;
  let previousMatchId: number;
  let selectedOffering = -1;
  let selectedSpecialRule = -1;
  let offeringCards;
  let specialRuleCards;
  let match: Match;

  $: if (matchId && matchId != previousMatchId) {
    stadiumAgentFactory(stadiumId)
      .getMatch(matchId)
      .then((result) => {
        if (!result[0]) {
          console.log("No match found");
          return;
        }
        match = result[0];

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
        previousMatchId = matchId;
        console.log("Got match: ", result);
      })
      .catch((err) => {
        console.log("Failed to get match: ", err);
      });
  }

  let validate = function () {
    let errors = [];
    if (!teamId) {
      errors.push("Team is required");
    }
    if (!stadiumId) {
      errors.push("Stadium is required");
    }
    if (!matchId) {
      errors.push("Match Id is required");
    }
    if (selectedOffering === -1) {
      errors.push("Offering is required");
    }
    if (selectedSpecialRule === -1) {
      errors.push("Special Rule is required");
    }
    if (errors.length > 0) {
      console.log(errors.join("\n"));
      return false;
    }
    return true;
  };
  let register = function () {
    if (!validate()) {
      return;
    }
    let request = {
      stadiumId: Principal.from(stadiumId),
      matchId: matchId,
      vote: {
        offeringId: selectedOffering,
        specialRuleId: selectedOffering,
      },
    };
    console.log(`Voting for team ${teamId} and match ${matchId}`, request);
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
</script>

<div>
  <label for="team">Team</label>
  <select id="team" bind:value={teamId}>
    {#each teams as team (team.id)}
      <option value={team.id.toString()}>{team.name}</option>
    {/each}
  </select>
</div>
{#if teamId}
  <div>
    <label for="stadium">Stadium</label>
    <select id="stadium" bind:value={stadiumId}>
      {#each stadiums as stadium (stadium.id)}
        <option value={stadium.id}>{stadium.name}</option>
      {/each}
    </select>
  </div>
  <div>
    <label for="matchId">Match Id</label>
    <input type="number" id="matchId" bind:value={matchId} />
  </div>
  {#if match}
    <div>
      <h2>Offerings</h2>
      <CardList
        cards={offeringCards}
        onSelect={(i) => (selectedOffering = i)}
      />
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
{/if}
