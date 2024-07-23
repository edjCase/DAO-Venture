<script lang="ts">
    import { ResourceTownEffectOutcome } from "../../../ic-agent/declarations/main";
    import { Town } from "../../../ic-agent/declarations/main";
    import ResourceIcon from "../../icons/ResourceIcon.svelte";

    export let value: ResourceTownEffectOutcome;
    export let towns: Town[];

    let absDelta = Math.abs(Number(value.delta));
    let gainOrLoss = value.delta >= 0 ? "+" : "-";

    $: town = towns?.find((town) => town.id === value.townId);
    $: townName = town?.name ?? "";
</script>

<div>
    Town {townName}
    {gainOrLoss}{absDelta}
    <ResourceIcon kind={value.kind} />
</div>
