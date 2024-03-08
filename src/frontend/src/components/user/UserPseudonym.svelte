<script lang="ts">
    import { Principal } from "@dfinity/principal";
    import {
        uniqueNamesGenerator,
        adjectives,
        colors,
        animals,
    } from "unique-names-generator";

    export let userId: Principal | string;

    let userIdString = userId instanceof Principal ? userId.toString() : userId;
</script>

{uniqueNamesGenerator({
    dictionaries: [adjectives, colors, animals],
    separator: " ",
    style: "capital",
    seed: userIdString,
})}
