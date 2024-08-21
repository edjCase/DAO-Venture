<script lang="ts">
  import { onMount } from "svelte";
  import mermaid from "mermaid";
  import {
    Class,
    Item,
    Race,
    ScenarioMetaData,
    Trait,
  } from "../../ic-agent/declarations/main";
  import { mainAgentFactory } from "../../ic-agent/Main";

  let diagram: string | undefined;

  mermaid.initialize({
    startOnLoad: false,
    theme: "forest",
    darkMode: true,
    flowchart: {},
  });

  function generateMermaidDiagram(
    scenarios: ScenarioMetaData[],
    items: Item[],
    traits: Trait[],
    races: Race[],
    classes: Class[]
  ): string {
    let diagramCode = "graph LR\n";

    // Add subgraphs
    diagramCode += addSubgraph(
      "Scenarios",
      scenarios.map((s) => ({ id: s.id, name: s.title }))
    );
    diagramCode += addSubgraph("Items", items);
    diagramCode += addSubgraph("Traits", traits);
    diagramCode += addSubgraph("Races", races);
    diagramCode += addSubgraph("Classes", classes);

    // Add connections
    scenarios.forEach((scenario) => {
      const scenarioId = scenario.id;

      // Connect items
      scenario.paths.forEach((path) => {
        path.effects.forEach((effect) => {
          if ("addItem" in effect) {
            if ("raw" in effect.addItem) {
              const itemId = effect.addItem.raw;
              diagramCode += `${scenarioId} -->|Uses| ${itemId}\n`;
            } else if ("weighted" in effect.addItem) {
              for (const [itemId, _] of effect.addItem.weighted) {
                diagramCode += `${scenarioId} -->|Uses| ${itemId}\n`;
              }
            }
          }
          if ("removeItem" in effect) {
            let itemId: string;
            if ("specific" in effect.removeItem) {
              if ("raw" in effect.removeItem.specific) {
                itemId = effect.removeItem.specific.raw;
                diagramCode += `${scenarioId} -->|Uses| ${itemId}\n`;
              }
            }
          }
        });
      });

      // Connect traits and other requirements
      scenario.choices.forEach((choice) => {
        if (choice.requirement[0]) {
          if ("trait" in choice.requirement[0]) {
            diagramCode += `${scenarioId} -->|Option requires trait| ${choice.requirement[0].trait}\n`;
          } else if ("race" in choice.requirement[0]) {
            diagramCode += `${scenarioId} -->|Option requires race| ${choice.requirement[0].race}\n`;
          } else if ("class" in choice.requirement[0]) {
            diagramCode += `${scenarioId} -->|Option requires class| ${choice.requirement[0].class}\n`;
          }
        }
      });
    });

    return diagramCode;
  }

  function addSubgraph(
    name: string,
    entities: { id: string; name: string }[]
  ): string {
    let subgraph = `subgraph ${name}\n`;
    entities.forEach((entity) => {
      subgraph += `    ${entity.id}[${entity.name}]\n`;
    });
    subgraph += "end\n\n";
    return subgraph;
  }

  onMount(async () => {
    let mainAgent = await mainAgentFactory();

    const [scenarios, items, traits, races, classes] = await Promise.all([
      mainAgent.getScenarioMetaDataList(),
      mainAgent.getItems(),
      mainAgent.getTraits(),
      mainAgent.getRaces(),
      mainAgent.getClasses(),
    ]);

    diagram = generateMermaidDiagram(scenarios, items, traits, races, classes);
    console.log(diagram);
    setTimeout(() => {
      mermaid.init();
    }, 0);
  });
</script>

<pre class="mermaid">
  {diagram}
</pre>
