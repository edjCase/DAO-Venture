<script lang="ts">
    import { ChangeTownMottoContent } from "../../../../ic-agent/declarations/main";
    import { townStore } from "../../../../stores/TownStore";

    export let content: ChangeTownMottoContent;
    $: towns = $townStore;

    let town = towns?.find((town) => town.id === content.townId);
</script>

<div>Town Id: {content.townId}</div>
<div>Current Motto: {town?.name}</div>

<div>New Motto: {content.motto}</div>
