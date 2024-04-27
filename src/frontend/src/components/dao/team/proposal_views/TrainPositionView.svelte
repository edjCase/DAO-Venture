<script lang="ts">
    import { TrainContent } from "../../../../ic-agent/declarations/teams";
    import { fieldPositionToString } from "../../../../models/FieldPosition";
    import { skillToString } from "../../../../models/Skill";

    export let content: TrainContent;
</script>

<div>Position: {fieldPositionToString(content.position)}</div>
<div>Skill: {skillToString(content.skill)}</div>
<div>Amount: 1</div>
<div>Cost: 1 Enegy</div>
