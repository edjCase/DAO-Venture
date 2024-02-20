<script lang="ts" context="module">
  export type ScenarioInfo = ScenarioInstance & {
    choice: number | undefined;
  };
</script>

<script lang="ts">
  import { teamStore } from "../../stores/TeamStore";
  import { Accordion, AccordionItem } from "flowbite-svelte";
  import { Principal } from "@dfinity/principal";
  import {
    ScenarioInstance,
    ScenarioInstanceWithChoice,
    ScenarioTemplate,
  } from "../../models/Scenario";
  import { Team } from "../../models/Team";
  import { playerStore } from "../../stores/PlayerStore";
  import { Player } from "../../ic-agent/Players";
  import Scenario, { ScenarioData } from "./Scenario.svelte";
  import TeamLogo from "../team/TeamLogo.svelte";
  import { scenarioTemplateStore } from "../../stores/ScenarioTemplateStore";

  export let scenarios: ScenarioInfo[];
  export let matchGroupId: number;

  let buildData = function (
    template: ScenarioTemplate,
    scenario: ScenarioInstance | ScenarioInstanceWithChoice,
    allTeams: Team[],
    allPlayers: Player[]
  ): ScenarioData | undefined {
    if (allTeams.length == 0 || allPlayers.length == 0) {
      return undefined;
    }
    let getTeam = (id: Principal): Team => {
      let teamOrUndefined = allTeams.find(
        (team) => team.id.compareTo(id) === "eq"
      );
      if (teamOrUndefined === undefined) {
        throw new Error(`Team with id ${id} not found`);
      }
      return teamOrUndefined;
    };
    let getPlayer = (id: number): Player => {
      let playerOrUndefined = allPlayers.find((player) => player.id == id);
      if (playerOrUndefined === undefined) {
        throw new Error(`Player with id ${id} not found`);
      }
      return playerOrUndefined;
    };
    let scenarioTeam = getTeam(scenario.teamId);
    let opposingTeam = getTeam(scenario.opposingTeamId);
    let otherTeams = scenario.otherTeamIds.map((id) => getTeam(id));

    // TODO for some reason .map is not working here
    let scenarioPlayers: Player[] = [];
    scenario.playerIds.forEach((id) => {
      const player = getPlayer(id);
      scenarioPlayers.push(player);
    });

    let replaceStringValue = function (
      text: string,
      key: string,
      value: string,
      color: [number, number, number]
    ): string {
      let regex = new RegExp(`{${key}}`, "g");
      value =
        `<span class='font-bold' style='color: rgb(${color})'>` +
        value +
        "</span>";
      return text.replace(regex, value);
    };

    let replaceText = function (text: string): string {
      text = replaceStringValue(
        text,
        "ScenarioTeam",
        scenarioTeam.name,
        scenarioTeam.color
      );
      text = replaceStringValue(
        text,
        "OpposingTeam",
        opposingTeam.name,
        opposingTeam.color
      );
      for (let i = 0; i < otherTeams.length; i++) {
        text = replaceStringValue(
          text,
          `OtherTeam${i}`,
          otherTeams[i].name,
          otherTeams[i].color
        );
      }
      for (let i = 0; i < scenarioPlayers.length; i++) {
        let player = scenarioPlayers[i];
        let playerTeam = getTeam(player.teamId);
        text = replaceStringValue(
          text,
          `Player${i}`,
          player.name,
          playerTeam.color
        );
      }
      return text;
    };
    let options = template.options.map((option, i) => {
      return {
        id: i,
        title: replaceText(option.title),
        description: replaceText(option.description),
      };
    });
    return {
      id: template.id,
      title: replaceText(template.title),
      description: replaceText(template.description),
      team: scenarioTeam,
      opposingTeamName: opposingTeam.name,
      otherTeamNames: otherTeams.map((team: Team) => team.name),
      playerNames: scenarioPlayers.map((player: Player) => player.name),
      options: options,
      choice: "choice" in scenario ? scenario.choice : undefined,
    };
  };

  $: teams = $teamStore;
  $: players = $playerStore;
  $: templates = $scenarioTemplateStore;
  $: scenariosWithData = scenarios.map<
    [ScenarioInfo, ScenarioData | undefined]
  >((s) => {
    let template = templates.find((t) => t.id == s.templateId);
    let data;
    if (template) {
      data = buildData(template, s, teams, players);
    }
    return [s, data];
  });
</script>

<div class="container">
  <Accordion>
    {#each scenariosWithData as [scenario, scenarioData]}
      {#if !scenarioData}
        <div>Loading...</div>
      {:else}
        <AccordionItem>
          <span slot="header">
            <div class="flex items-center gap-5 text-xl font-bold">
              <TeamLogo
                team={scenarioData.team}
                size="sm"
                popover={true}
                borderColor={undefined}
              />
              {@html scenarioData.title}
            </div>
          </span>
          <Scenario {scenario} {scenarioData} {matchGroupId} />
        </AccordionItem>
      {/if}
    {/each}
  </Accordion>
</div>

<style>
  .container {
    display: flex;
    flex-direction: column;
  }
</style>
