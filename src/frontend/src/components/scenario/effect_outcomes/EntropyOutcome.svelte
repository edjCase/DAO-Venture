<script lang="ts">
    import { EntropyTownEffectOutcome } from "../../../ic-agent/declarations/main";
    import { Town } from "../../../ic-agent/declarations/main";

    export let value: EntropyTownEffectOutcome;
    export let towns: Town[];

    let absDelta = Math.abs(Number(value.delta));
    let gainOrLoss = value.delta >= 0 ? "+" : "-";

    $: townName = towns.find((town) => town.id === value.townId)?.name ?? "";
</script>

<div>
    Town {townName}
    {gainOrLoss}{absDelta} 🔥
</div>
