<script lang="ts">
    import { ChangeTownMottoContent__1 } from "../../../../ic-agent/declarations/main";
    import { townStore } from "../../../../stores/TownStore";

    export let content: ChangeTownMottoContent__1;
    $: towns = $townStore;

    let town = towns?.find((town) => town.id === content.townId);
</script>

<div>Town Id: {content.townId}</div>
<div>Current Motto: {town?.name}</div>

<div>New Motto: {content.motto}</div>
