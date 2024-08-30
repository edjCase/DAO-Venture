<script lang="ts">
  import { Tooltip } from "flowbite-svelte";
  import { Trait } from "../../ic-agent/declarations/main";

  export let traits: Trait[];
</script>

<ul class="flex">
  {#each traits as trait}
    <li>
      <div class="text-xl">✨</div>
      <Tooltip>
        <div class="text-sm">
          {trait.name}
          <br />
          {trait.description}
        </div>
      </Tooltip>
    </li>
  {/each}
</ul>
