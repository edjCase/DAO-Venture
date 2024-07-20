<script lang="ts">
    import { ChangeTownLogoContent__1 } from "../../../../ic-agent/declarations/main";
    import { townStore } from "../../../../stores/TownStore";

    export let content: ChangeTownLogoContent__1;
    $: towns = $townStore;

    let town = towns?.find((town) => town.id === content.townId);
</script>

<div>Town Id: {content.townId}</div>
<div>Current Logo: {town?.name}</div>

<div class="flex justify-center">
    <img
        style="width: 100px; height: 100px"
        src={content.logoUrl}
        alt="New Logo"
    />
</div>
