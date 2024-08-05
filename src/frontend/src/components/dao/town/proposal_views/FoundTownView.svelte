<script lang="ts">
    import { FoundTownContent } from "../../../../ic-agent/declarations/main";
    import PixelArtFlag from "../../../common/PixelArtFlag.svelte";
    import UserAvatar from "../../../user/UserAvatar.svelte";
    import UserPseudonym from "../../../user/UserPseudonym.svelte";

    export let content: FoundTownContent;
    export let townId: bigint;
</script>

<div>Name: {content.name}</div>
<div>Flag: <PixelArtFlag pixels={content.flag.pixels} size="sm" /></div>
<div>Motto: {content.motto}</div>
<div>Location: {content.locationId}</div>
<div>Users:</div>
<ul>
    {#each content.users as userId}
        <li>
            <UserAvatar {userId} size="xs" />
            <UserPseudonym {userId} />
        </li>
    {/each}
</ul>
