<script lang="ts">
    import { ChangeTownNameContent } from "../../../../ic-agent/declarations/main";
    import { townStore } from "../../../../stores/TownStore";

    export let content: ChangeTownNameContent;

    $: towns = $townStore;

    let town = towns?.find((town) => town.id === content.townId);
</script>

<div>Town Id: {content.townId}</div>
<div>Current Name: {town?.name}</div>
<div>New Name: {content.name}</div>
