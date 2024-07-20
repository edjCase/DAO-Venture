<script lang="ts">
    import { ChangeTownFlagContent } from "../../../../ic-agent/declarations/main";

    export let content: ChangeTownFlagContent;
</script>

<div class="flex justify-center">
    <img
        style="width: 100px; height: 100px"
        src={content.logoUrl}
        alt="New Logo"
    />
</div>
