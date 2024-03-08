<script lang="ts">
    import { onDestroy } from "svelte";
    import { Principal } from "@dfinity/principal";
    import { memberStore } from "../../stores/MemberStore";
    import UserAvatar from "../user/UserAvatar.svelte";
    import UserPseudonym from "../user/UserPseudonym.svelte";
    import { Member } from "../../ic-agent/declarations/team";

    export let teamId: string | Principal;

    let members: Member[] = [];
    let unsubscribeToTeamMembers = () => {};

    $: {
        unsubscribeToTeamMembers(); // Unsubscribe from the old subscription
        unsubscribeToTeamMembers = memberStore.subscribeToTeam(
            teamId,
            (updatedMembers) => {
                members = updatedMembers;
            },
        );
    }

    onDestroy(() => {
        unsubscribeToTeamMembers();
    });
</script>

{#each members as member}
    <div class="border p-5">
        <UserAvatar userId={member.id} />
        <UserPseudonym userId={member.id} />
        <div>{member.id}</div>
    </div>
{/each}
