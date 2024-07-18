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

    $: userIdString = userId instanceof Principal ? userId.toString() : userId;

    $: pseudonym = uniqueNamesGenerator({
        dictionaries: [adjectives, colors, animals],
        separator: " ",
        style: "capital",
        seed: userIdString,
    });

    $: truncateClass = maxWidth ? "truncate" : "";
    $: style = maxWidth ? `max-width: ${maxWidth};` : "";
</script>

<div class={`inline-block ${truncateClass}`} {style} title={pseudonym}>
    {pseudonym}
</div>
