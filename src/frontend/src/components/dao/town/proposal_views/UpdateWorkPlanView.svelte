<script lang="ts">
    import { UpdateWorkPlanContent } from "../../../../ic-agent/declarations/main";
    import WorkPlan from "../../../town/TownWorkPlan.svelte";

    export let content: UpdateWorkPlanContent;
    export let townId: bigint;
</script>

<div>Gather Food: {content.workPlan.gatherFood.weight}</div>
<div>Gather Wood: {content.workPlan.gatherWood.weight}</div>
<div>Gather Stone: {content.workPlan.gatherStone.weight}</div>
<div>Gather Gold: {content.workPlan.gatherGold.weight}</div>
<div>Process Stone: {content.workPlan.processStone.weight}</div>
<div>Process Wood: {content.workPlan.processWood.weight}</div>
<WorkPlan workPlan={content.workPlan} />
