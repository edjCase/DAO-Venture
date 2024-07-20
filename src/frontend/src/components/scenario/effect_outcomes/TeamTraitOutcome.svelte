<script lang="ts">
    import { TownTraitTownEffectOutcome } from "../../../ic-agent/declarations/main";
    import { Town, Trait } from "../../../ic-agent/declarations/main";
    import { toJsonString } from "../../../utils/StringUtil";

    export let value: TownTraitTownEffectOutcome;
    export let traits: Trait[];
    export let towns: Town[];

    $: townName = towns.find((town) => town.id === value.townId)?.name ?? "";

    $: traitName = traits.find((t) => t.id == value.traitId)?.name ?? "";
</script>

Town {townName}
{#if "add" in value.kind}
    +
{:else if "remove" in value.kind}
    -
{:else}
    NOT IMPLEMENTED TEAM TRAIT KIND: {toJsonString(value.kind)}
{/if}
{traitName}
