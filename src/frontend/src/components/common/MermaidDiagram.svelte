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
    flowchart: {
      curve: "basis",
    },
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

    type Connection = { from: string; to: string };

    let usingConnections: Connection[] = [];
    let requiringConnections: Connection[] = [];
    // Add connections
    scenarios.forEach((scenario) => {
      const scenarioId = scenario.id;

      // Connect items
      scenario.paths.forEach((path) => {
        path.effects.forEach((effect) => {
          if ("addItem" in effect) {
            if ("raw" in effect.addItem) {
              const itemId = effect.addItem.raw;
              usingConnections.push({ from: scenarioId, to: itemId });
            } else if ("weighted" in effect.addItem) {
              for (const [itemId, _] of effect.addItem.weighted) {
                usingConnections.push({ from: scenarioId, to: itemId });
              }
            }
          }
          if ("removeItem" in effect) {
            let itemId: string;
            if ("specific" in effect.removeItem) {
              if ("raw" in effect.removeItem.specific) {
                itemId = effect.removeItem.specific.raw;
                usingConnections.push({ from: scenarioId, to: itemId });
              }
            }
          }
        });
      });

      // Connect traits and other requirements
      scenario.choices.forEach((choice) => {
        if (choice.requirement[0]) {
          if ("trait" in choice.requirement[0]) {
            requiringConnections.push({
              from: scenarioId,
              to: choice.requirement[0].trait,
            });
          } else if ("race" in choice.requirement[0]) {
            requiringConnections.push({
              from: scenarioId,
              to: choice.requirement[0].race,
            });
          } else if ("class" in choice.requirement[0]) {
            requiringConnections.push({
              from: scenarioId,
              to: choice.requirement[0].class,
            });
          }
        }
      });
    });

    usingConnections.forEach((connection) => {
      diagramCode += `${connection.from} --> ${connection.to}\n`;
    });
    requiringConnections.forEach((connection) => {
      diagramCode += `${connection.from} --> ${connection.to}\n`;
    });

    let usesIndexes = usingConnections.map((_, i) => i).join(",");
    // Uses
    diagramCode += `linkStyle ${usesIndexes} stroke:#4CAF50,stroke-width:2px;\n`;

    let requiresIndexes = requiringConnections
      .map((_, i) => i + usingConnections.length)
      .join(",");
    // Requires
    diagramCode += `linkStyle ${requiresIndexes} stroke:#F44336,stroke-width:2px;\n`;

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
    setTimeout(() => {
      mermaid.init();
    }, 0);
  });
</script>

<pre class="mermaid">
  {diagram}
</pre>
