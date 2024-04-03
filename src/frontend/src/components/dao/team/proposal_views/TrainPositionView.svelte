<script lang="ts">
    import { TrainContent } from "../../../../ic-agent/declarations/teams";
    import { toJsonString } from "../../../../utils/StringUtil";

    export let content: TrainContent;
</script>

<div>Position: {content.position}</div>
<div>Skill: {toJsonString(content.skill)}</div>
