<script lang="ts" context="module">
    import {
        ProposalStatusLogEntry,
        Vote,
    } from "../../ic-agent/declarations/league";

    export interface ProposalType {
        id: bigint;
        title: string;
        timeStart: bigint;
        timeEnd: bigint;
        votes: [Principal, Vote][];
        statusLog: ProposalStatusLogEntry[];
    }
</script>

<script lang="ts">
    import { toJsonString } from "../../utils/StringUtil";
    import { nanosecondsToDate } from "../../utils/DateUtils";
    import { Principal } from "@dfinity/principal";
    import { identityStore } from "../../stores/IdentityStore";
    import LoadingButton from "../common/LoadingButton.svelte";
    import { Identity } from "@dfinity/agent";

    export let proposal: ProposalType;
    export let onVote: (proposalId: bigint, vote: boolean) => Promise<void>;

    let identity: Identity | undefined;
    let yourVote: boolean | undefined;

    identityStore.subscribe((i) => {
        identity = i;
    });

    let vote = async (proposalId: bigint, vote: boolean) => {
        console.log("Voting on proposal", proposal.id, "vote", vote);
        await onVote(proposalId, vote);
    };

    $: userId = identity?.getPrincipal() ?? Principal.anonymous();

    $: if (!userId.isAnonymous()) {
        let uId = userId;
        let v = proposal.votes.find(
            ([memberId, _]) => memberId.compareTo(uId) == "eq",
        )?.[1];
        yourVote = v && v.value.length > 0 ? v.value[0] : undefined;
    } else {
        yourVote = undefined;
    }

    $: lastStatus = proposal.statusLog[proposal.statusLog.length - 1];

    $: adoptPercentage =
        proposal.votes.length < 1
            ? 0
            : proposal.votes.filter(([_, v]) => v.value[0] === true).length /
              proposal.votes.length;
    $: rejectPercentage =
        proposal.votes.length < 1
            ? 0
            : proposal.votes.filter(([_, v]) => v.value[0] === false).length /
              proposal.votes.length;
</script>

<div class="border p-5">
    <div class="text-3xl text-center">#{proposal.id} - {proposal.title}</div>
    <div class="p-5">
        <slot />
    </div>
    <div
        class="w-64 mx-auto h-5 flex justify-between bg-gray-300 bg-opacity-25"
    >
        <div
            class="h-full bg-green-500"
            style="width: {adoptPercentage * 100}%"
        ></div>
        <div
            class="h-full bg-red-500"
            style="width: {rejectPercentage * 100}%"
        ></div>
    </div>
    <div class="my-5">
        {#if !lastStatus}
            {#if proposal.votes.some((v) => userId.toString() == v[0].toString())}
                {#if yourVote === undefined}
                    <div class="flex justify-center gap-5 mb-6">
                        <LoadingButton onClick={() => vote(proposal.id, true)}>
                            Adopt
                        </LoadingButton>
                        <LoadingButton onClick={() => vote(proposal.id, false)}>
                            Reject
                        </LoadingButton>
                    </div>
                {:else}
                    <div class="text-xl text-center">
                        You have voted: {yourVote ? "Adopt" : "Reject"}
                    </div>
                {/if}
            {:else}
                You are not eligible to vote
            {/if}
        {:else if "executing" in lastStatus}
            <div class="text-xl text-center text-green-600">
                Proposal Executing
            </div>
        {:else if "executed" in lastStatus}
            <div class="text-xl text-center text-green-600">
                Proposal Executed
            </div>
        {:else if "failedToExecute" in lastStatus}
            <div class="text-xl text-center text-red-500">
                Proposal Failed To Execute
            </div>
            <div class="text-lg text-center text-red-600">
                {lastStatus.failedToExecute.error}
            </div>
        {:else if "rejected" in lastStatus}
            <div class="text-xl text-center text-red-600">
                Proposal Rejected
            </div>
        {:else}
            NOT IMPLEMENTED: {toJsonString(lastStatus)}
        {/if}
    </div>
    <div class="text-xs">
        Created: {nanosecondsToDate(proposal.timeStart).toLocaleString()}
    </div>
    <div class="text-xs">
        Ends: {nanosecondsToDate(proposal.timeEnd).toLocaleString()}
    </div>
</div>
