<script lang="ts" context="module">
    export let buildUserPseudonym = (userId: Principal | string) =>
        uniqueNamesGenerator({
            dictionaries: [adjectives, colors, animals],
            separator: " ",
            style: "capital",
            seed: userId instanceof Principal ? userId.toString() : userId,
        });
</script>

<script lang="ts">
    import { Principal } from "@dfinity/principal";
    import {
        uniqueNamesGenerator,
        adjectives,
        colors,
        animals,
    } from "unique-names-generator";

    export let userId: Principal | string;
    export let maxWidth: string | undefined = undefined;

    $: pseudonym = buildUserPseudonym(userId);

    $: truncateClass = maxWidth ? "truncate" : "";
    $: style = maxWidth ? `max-width: ${maxWidth};` : "";
</script>

<div class={`inline-block ${truncateClass}`} {style} title={pseudonym}>
    {pseudonym}
</div>
