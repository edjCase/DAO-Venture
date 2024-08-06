<script lang="ts">
    import FormTemplate from "./FormTemplate.svelte";
    import { TownProposalContent } from "../../../../ic-agent/declarations/main";
    import { worldStore } from "../../../../stores/WorldStore";
    import { Input, Label } from "flowbite-svelte";

    export let townId: bigint;

    let locationId: number | undefined;
    let leaveLocationId: number | undefined;

    $: world = $worldStore;

    let generateProposal = (): TownProposalContent | string => {
        if (locationId === undefined) {
            return "No location selected";
        }
        return {
            claimLocation: {
                locationId: BigInt(locationId),
                leaveLocationId:
                    leaveLocationId !== undefined
                        ? [BigInt(leaveLocationId)]
                        : [],
            },
        };
    };
</script>

{#if world}
    <FormTemplate {generateProposal} {townId}>
        <div class="p-2">Claims a location for the town.</div>
        <Label>Location Id</Label>
        <Input type="number" bind:value={locationId} />
        <Label>Leave Location Id</Label>
        <Input type="number" bind:value={leaveLocationId} />
    </FormTemplate>
{/if}
