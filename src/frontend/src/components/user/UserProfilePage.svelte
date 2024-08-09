<script lang="ts">
    import LoginButton from "../../components/common/LoginButton.svelte";
    import { userStore } from "../../stores/UserStore";
    import { townStore } from "../../stores/TownStore";
    import UserPseudonym from "./UserPseudonym.svelte";
    import TownFlag from "../town/TownFlag.svelte";
    import UserIdCopyButton from "./UserIdCopyButton.svelte";
    import { nanosecondsToDate } from "../../utils/DateUtils";

    $: user = $userStore;
    $: towns = $townStore;

    $: town = towns?.find((t) => t.id == user?.worldData?.townId);
</script>

<div class="bg-gray-800 p-4">
    {#if user}
        <div class="bg-gray-900 rounded-lg shadow-md p-6 w-full max-w-md">
            <div class="text-2xl font-bold mb-4">User Profile</div>
            <div class="mb-4">
                <div class="font-bold text-xl mb-2">Name</div>
                <div>
                    <UserPseudonym userId={user.id} />
                </div>
            </div>
            <div class="mb-4">
                <div class="font-bold text-xl mb-2">Id</div>
                <div class="flex items-center mt-2">
                    <div class="text-sm text-center mr-2">
                        {user.id.toString()}
                    </div>

                    <UserIdCopyButton userId={user.id} />
                </div>
            </div>
            {#if user.worldData !== undefined}
                <div class="mb-4">
                    <div class="font-bold text-xl mb-2">Town</div>
                    {#if town}
                        <TownFlag {town} size="md" />
                        <div class="text-center">{town.name}</div>
                        <div class="text-center text-sm text-gray-400">
                            Joined Town: {nanosecondsToDate(
                                user.worldData.atTownSince,
                            )}
                        </div>
                    {:else}
                        <div>None</div>
                    {/if}
                    <div>
                        Joined World: {nanosecondsToDate(
                            user.worldData.inWorldSince,
                        )}
                    </div>
                </div>
                <div class="mb-4">
                    <div class="font-bold text-xl mb-2">
                        Level - {user.worldData.level}
                    </div>
                </div>
            {/if}
        </div>
    {/if}

    <div class="mt-4">
        <LoginButton />
    </div>
</div>
