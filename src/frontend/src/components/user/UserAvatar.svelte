<script lang="ts">
    import { Principal } from "@dfinity/principal";
    import { Avatar } from "flowbite-svelte";

    import { toSvg } from "jdenticon";

    export let userId: Principal | string;

    let userIdString = userId instanceof Principal ? userId.toString() : userId;
</script>

<Avatar border>
    {@html toSvg(userIdString, 100)}
</Avatar>
