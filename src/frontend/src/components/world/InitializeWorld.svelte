<script lang="ts">
    import { Input, Label } from "flowbite-svelte";
    import LoginButton from "../common/LoginButton.svelte";
    import { FlagImage } from "../../ic-agent/declarations/main";
    import TownFlagCreator from "../town/TownFlagCreator.svelte";
    import { userStore } from "../../stores/UserStore";
    import { mainAgentFactory } from "../../ic-agent/Main";
    import RgbColor from "../common/RgbColor.svelte";
    import { Rgb } from "../../models/PixelArt";
    import LoadingButton from "../common/LoadingButton.svelte";
    import { worldStore } from "../../stores/WorldStore";
    import { townStore } from "../../stores/TownStore";

    $: user = $userStore;

    let townName: string;
    let townMotto: string;
    let townFlag: FlagImage;
    let townColor: Rgb;

    let intializeWorld = async () => {
        if (user === undefined) {
            console.error("User not logged in");
            return;
        }
        let mainAgent = await mainAgentFactory();
        let result = await mainAgent.intializeWorld({
            town: {
                name: townName,
                motto: townMotto,
                flag: townFlag,
                color: [townColor.red, townColor.green, townColor.blue],
            },
        });
        if ("ok" in result) {
            console.log("World initialized");
            userStore.refetchCurrentUser();
            userStore.refetchStats();
            worldStore.refetch();
            townStore.refetch();
        } else {
            console.error("Failed to initialize world", result.err);
        }
    };
</script>

<div class="text-center text-3xl">Initialize World</div>
<div class="px-20 mt-10">
    {#if user === undefined}
        <LoginButton />
    {:else}
        <div class="text-center">Create the first town</div>
        <div>
            <Label>Name</Label>
            <Input type="text" bind:value={townName} />
            <Label>Motto</Label>
            <Input type="text" bind:value={townMotto} />
            <Label>Color</Label>
            <RgbColor bind:value={townColor} />
            <Label>Flag</Label>
            <TownFlagCreator bind:value={townFlag} />
            <div class="text-center mt-5">
                <LoadingButton onClick={intializeWorld} size="xl">
                    Initialize
                </LoadingButton>
            </div>
        </div>
    {/if}
</div>
