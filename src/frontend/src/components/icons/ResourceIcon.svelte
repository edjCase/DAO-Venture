<script lang="ts" context="module">
    export let getResourceIcon = (kind: ResourceKind): string => {
        if ("gold" in kind) {
            return "🪙";
        } else if ("wood" in kind) {
            return "🪵";
        } else if ("stone" in kind) {
            return "🪨";
        } else if ("food" in kind) {
            return "🥕";
        } else {
            return `NOT IMPLEMENTED RESOURCE KIND: ${JSON.stringify(kind)}`;
        }
    };
</script>

<script lang="ts">
    import { ResourceKind } from "../../ic-agent/declarations/main";

    export let kind: ResourceKind;

    $: icon = getResourceIcon(kind);
</script>

{icon}
