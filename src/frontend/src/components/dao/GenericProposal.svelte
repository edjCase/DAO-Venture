<script lang="ts" context="module">
    import {
        ProposalStatusLogEntry,
        Vote,
    } from "../../ic-agent/declarations/league";

    export interface ProposalType {
        id: bigint;
        title: string;
        description: string;
        timeStart: bigint;
        timeEnd: bigint;
        votes: [Principal, Vote][];
        statusLog: ProposalStatusLogEntry[];
    }
</script>

<script lang="ts">
    import { Button } from "flowbite-svelte";
    import { toJsonString } from "../../utils/StringUtil";
    import { nanosecondsToDate } from "../../utils/DateUtils";
    import { Principal } from "@dfinity/principal";
    import { identityStore } from "../../stores/IdentityStore";

    export let proposal: ProposalType;
    export let onVote: (proposalId: bigint, vote: boolean) => Promise<void>;

    let userId: Principal = Principal.anonymous();
    let yourVote: boolean | undefined;

    identityStore.subscribe((i) => {
        userId = i.getPrincipal();
        if (!userId.isAnonymous()) {
            let v = proposal.votes.find(
                ([memberId, _]) => memberId.compareTo(userId) == "eq",
            )?.[1];
            yourVote = v && v.value.length > 0 ? v.value[0] : undefined;
        } else {
            yourVote = undefined;
        }
    });

    let vote = async (proposalId: bigint, vote: boolean) => {
        console.log("Voting on proposal", proposal.id, "vote", vote);
        await onVote(proposalId, vote);
    };
    let lastStatus: ProposalStatusLogEntry | undefined =
        proposal.statusLog[proposal.statusLog.length - 1];
</script>

<div class="border p-5">
    <div class="text-3xl">Proposal: {proposal.id}</div>
    <div>Created: {nanosecondsToDate(proposal.timeStart).toLocaleString()}</div>
    <div>Ends: {nanosecondsToDate(proposal.timeEnd).toLocaleString()}</div>
    <slot />
    {#if !lastStatus}
        <div class="text-2xl">Vote:</div>
        {#if proposal.votes.some((v) => userId.toString() == v[0].toString())}
            {#if yourVote === undefined}
                <div class="mb-6">
                    <Button on:click={() => vote(proposal.id, true)}>
                        Adopt
                    </Button>
                    <Button on:click={() => vote(proposal.id, false)}>
                        Reject
                    </Button>
                </div>
            {:else}
                <div class="text-xl">
                    You have voted: {yourVote ? "Adopt" : "Reject"}
                </div>
            {/if}
        {:else}
            You are not eligible to vote
        {/if}
    {:else if "executing" in lastStatus}
        <div class="text-xl">Proposal Executing</div>
    {:else if "executed" in lastStatus}
        <div class="text-xl">Proposal Executed</div>
    {:else if "failedToExecute" in lastStatus}
        <div class="text-xl">Proposal Failed To Execute</div>
    {:else if "rejected" in lastStatus}
        <div class="text-xl">Proposal Rejected</div>
    {:else}
        NOT IMPLEMENTED: {toJsonString(lastStatus)}
    {/if}
</div>
