<script lang="ts">
  import { Scenario } from "../../ic-agent/declarations/main";
  import { toJsonString } from "../../utils/StringUtil";

  export let scenario: Scenario;
</script>

<div class="p-6">
  <div class="text-3xl text-center">
    {scenario.title}
  </div>
  <div class="my-6">
    {scenario.description}
  </div>
  <div class="flex flex-col items-center gap-2">
    <div>
      {#if "mysteriousStructure" in scenario.kind}
        <div></div>
      {:else}
        NOT IMPLEMENTED SCENARIO KIND {toJsonString(scenario.kind)}
      {/if}
    </div>
    <div>
      {#each scenario.options as option}
        <div>
          <div>{option.description}</div>
        </div>
      {/each}
    </div>
    {#if scenario.outcome[0] !== undefined}
      {#each scenario.outcome[0].messages as message}
        <div>{message}</div>
      {/each}
    {/if}
  </div>
</div>
