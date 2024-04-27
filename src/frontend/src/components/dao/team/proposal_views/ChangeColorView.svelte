<script lang="ts">
    import { ChangeColorContent } from "../../../../ic-agent/declarations/teams";
    import RgbColor from "../../../common/RgbColor.svelte";

    export let content: ChangeColorContent;
</script>

<RgbColor value={content.color} disabled />
