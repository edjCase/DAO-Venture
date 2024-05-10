<script lang="ts">
    import { Label, Select, SelectOptionType } from "flowbite-svelte";
    import { traitStore } from "../../../stores/TraitStore";

    export let value: string;

    $: traits = $traitStore;
    let traitItems: SelectOptionType<string>[];
    $: traitItems =
        traits?.map((t) => ({
            value: t.id,
            name: t.name,
        })) ?? [];
</script>

<Label>Trait</Label>
<Select items={traitItems} bind:value />
