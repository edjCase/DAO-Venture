<script lang="ts">
    import { Input, Label } from "flowbite-svelte";
    import { mainAgentFactory } from "../../ic-agent/Main";
    import { CreateTownTraitRequest } from "../../ic-agent/declarations/main";
    import LoadingButton from "../common/LoadingButton.svelte";
    import { traitStore } from "../../stores/TraitStore";

    let trait: CreateTownTraitRequest = {
        id: "",
        name: "",
        description: "",
    };

    let addTrait = async () => {
        if (!trait) {
            console.error("Trait not loaded. Cannot add.");
            return;
        }
        let mainAgent = await mainAgentFactory();
        let result = await mainAgent.createTownTrait(trait);
        if ("ok" in result) {
            console.log("Created trait: ", trait);
            traitStore.refetch();
        } else {
            console.error("Failed to make trait: ", trait, result);
        }
    };
</script>

<Label>Id</Label>
<Input type="text" bind:value={trait.id} />
<Label>Name</Label>
<Input type="text" bind:value={trait.name} />
<Label>Description</Label>
<Input type="text" bind:value={trait.description} />
<LoadingButton onClick={addTrait}>Add Trait</LoadingButton>
