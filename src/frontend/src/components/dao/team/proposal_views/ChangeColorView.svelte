<script lang="ts">
    import { ChangeTeamColorContent } from "../../../../ic-agent/declarations/main";
    import RgbColor from "../../../common/RgbColor.svelte";

    export let content: ChangeTeamColorContent;
</script>

<RgbColor value={content.color} disabled />
