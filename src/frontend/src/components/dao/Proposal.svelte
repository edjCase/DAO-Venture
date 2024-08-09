<script lang="ts">
    import { toJsonString } from "../../utils/StringUtil";
    import { nanosecondsToDate } from "../../utils/DateUtils";
    import LoadingButton from "../common/LoadingButton.svelte";
    import { userStore } from "../../stores/UserStore";
    import { WorldProposal } from "../../ic-agent/declarations/main";
    import ProposalView from "./ProposalView.svelte";

    export let proposal: WorldProposal;
    export let onVote: (proposalId: bigint, vote: boolean) => Promise<void>;

    let yourVote: boolean | undefined;

    let vote = async (proposalId: bigint, vote: boolean) => {
        console.log("Voting on proposal", proposal.id, "vote", vote);
        await onVote(proposalId, vote);
    };

    $: user = $userStore;

    $: if (user) {
        let uId = user.id;
        let v = proposal.votes.find(
            ([memberId, _]) => memberId.compareTo(uId) == "eq",
        )?.[1];
        yourVote = v && v.choice.length > 0 ? v.choice[0] : undefined;
    } else {
        yourVote = undefined;
    }

    $: adoptPercentage =
        proposal.votes.length < 1
            ? 0
            : proposal.votes.filter(([_, v]) => v.choice[0] === true).length /
              proposal.votes.length;
    $: rejectPercentage =
        proposal.votes.length < 1
            ? 0
            : proposal.votes.filter(([_, v]) => v.choice[0] === false).length /
              proposal.votes.length;
</script>

<div class="border p-5">
    <div class="text-3xl text-center">#{proposal.id}</div>
    <div class="p-5">
        <ProposalView {proposal} />
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
        {#if "open" in proposal.status}
            {#if proposal.votes.some((v) => user?.id.toString() == v[0].toString())}
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
        {:else if "executing" in proposal.status}
            <div class="text-xl text-center text-green-600">
                Proposal Executing
            </div>
        {:else if "executed" in proposal.status}
            {#if proposal.status.executed.choice[0] === true}
                <div class="text-xl text-center text-green-600">
                    Proposal Executed
                </div>
            {:else}
                <div class="text-xl text-center text-red-600">
                    Proposal Rejected
                </div>
            {/if}
        {:else if "failedToExecute" in proposal.status}
            <div class="text-xl text-center text-red-500">
                Proposal Failed To Execute
            </div>
            <div class="text-lg text-center text-red-600">
                {proposal.status.failedToExecute.error}
            </div>
        {:else}
            NOT IMPLEMENTED: {toJsonString(proposal.status)}
        {/if}
    </div>
    <div class="text-xs">
        Created: {nanosecondsToDate(proposal.timeStart).toLocaleString()}
    </div>
    {#if proposal.timeEnd[0] !== undefined}
        <div class="text-xs">
            Ends: {nanosecondsToDate(proposal.timeEnd[0]).toLocaleString()}
        </div>
    {/if}
</div>
