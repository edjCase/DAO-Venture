<script lang="ts">
    import { Input, Label } from "flowbite-svelte";
    import { TextInputScenario } from "../../../../ic-agent/declarations/main";
    export let value: TextInputScenario;
</script>

<Label>Description</Label>
<Input type="text" bind:value={value.description} />
