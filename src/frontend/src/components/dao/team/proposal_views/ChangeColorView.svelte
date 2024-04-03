<script lang="ts">
    import { ChangeColorContent } from "../../../../ic-agent/declarations/teams";
    import RgbColor from "../../../common/RgbColor.svelte";

    export let content: ChangeColorContent;
</script>

<RgbColor
    red={content.color[0]}
    green={content.color[1]}
    blue={content.color[2]}
/>
