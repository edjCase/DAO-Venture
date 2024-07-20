<script lang="ts">
    import { ChangeTownColorContent } from "../../../../ic-agent/declarations/main";
    import RgbColor from "../../../common/RgbColor.svelte";

    export let content: ChangeTownColorContent;
</script>

<RgbColor value={content.color} disabled />
