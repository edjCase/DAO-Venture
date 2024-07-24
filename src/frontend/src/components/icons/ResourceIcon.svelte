<script lang="ts">
    import { ResourceKind } from "../../ic-agent/declarations/main";
    import { getResourceIcon } from "../../utils/ResourceUtil";

    export let kind: ResourceKind;

    $: icon = getResourceIcon(kind);
</script>

{icon}
