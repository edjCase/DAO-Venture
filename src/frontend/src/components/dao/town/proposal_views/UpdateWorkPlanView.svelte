<script lang="ts">
    import { UpdateWorkPlanContent } from "../../../../ic-agent/declarations/main";
    import WorkPlan from "../../../town/TownWorkPlan.svelte";

    export let content: UpdateWorkPlanContent;
    export let townId: bigint;
</script>

<div class="flex flex-col">
    <WorkPlan workPlan={content.workPlan} legend={true} />
</div>
