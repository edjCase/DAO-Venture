<script lang="ts">
    import { ChangeTownNameContent__1 } from "../../../../ic-agent/declarations/main";
    import { townStore } from "../../../../stores/TownStore";

    export let content: ChangeTownNameContent__1;

    $: towns = $townStore;

    let town = towns?.find((town) => town.id === content.townId);
</script>

<div>Town Id: {content.townId}</div>
<div>Current Name: {town?.name}</div>
<div>New Name: {content.name}</div>
