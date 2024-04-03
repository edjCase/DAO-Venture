<script lang="ts">
    import { ChangeColorContent } from "../../../../ic-agent/declarations/teams";
    import RgbColor from "../../../common/RgbColor.svelte";

    export let content: ChangeColorContent;
</script>

{content.color[0]},{content.color[1]},{content.color[2]}
<RgbColor value={content.color} disabled />
