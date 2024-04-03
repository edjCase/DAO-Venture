<script lang="ts">
    import { TrainContent } from "../../../../ic-agent/declarations/teams";

    export let content: TrainContent;
</script>

<div>Position: {proposal.content.train.position}</div>
<div>Skill: {toJsonString(proposal.content.train.skill)}</div>
