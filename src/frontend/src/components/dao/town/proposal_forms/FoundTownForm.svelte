<script lang="ts">
    import { Input, Label } from "flowbite-svelte";
    import {
        FlagImage,
        TownProposalContent,
    } from "../../../../ic-agent/declarations/main";
    import LocationSelector from "../../../world/LocationSelector.svelte";
    import { Principal } from "@dfinity/principal";
    import FormTemplate from "./FormTemplate.svelte";
    import TownFlagCreator from "../../../town/TownFlagCreator.svelte";
    import UserMultiSelector from "../../../user/UserMultiSelector.svelte";
    import RgbColor from "../../../common/RgbColor.svelte";
    import { Rgb } from "../../../../models/PixelArt";

    export let townId: bigint;

    let name: string = "";
    let color: Rgb | undefined;
    let flag: FlagImage | undefined;
    let motto: string = "";
    let locationId: bigint = 0n;
    let migrantIds: Principal[] = [];
    let generateProposal = (): TownProposalContent | string => {
        if (name === "") {
            return "No name chosen";
        }
        if (locationId === undefined) {
            return "No location selected";
        }
        if (color === undefined) {
            return "No color selected";
        }
        if (flag === undefined) {
            return "No flag selected";
        }
        if (migrantIds.length === 0) {
            return "No migrants selected";
        }
        return {
            foundTown: {
                name: name,
                flag: flag,
                color: [color.red, color.green, color.blue],
                motto: motto,
                locationId: locationId,
                migrantIds: migrantIds,
            },
        };
    };
</script>

<FormTemplate {generateProposal} {townId}>
    <Label>Town Name</Label>
    <Input bind:value={name} />
    <Label>Color</Label>
    <RgbColor bind:value={color} />
    <Label>Flag</Label>
    <TownFlagCreator bind:value={flag} />
    <Label>Motto</Label>
    <Input bind:value={motto} />
    <Label>Location</Label>
    <LocationSelector bind:value={locationId} kind="explored" />
    <Label>Migrants</Label>
    <UserMultiSelector bind:value={migrantIds} {townId} />
</FormTemplate>
