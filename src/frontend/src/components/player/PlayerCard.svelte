<script lang="ts">
    import UniqueAvatar from "../common/UniqueAvatar.svelte";
    import { fieldPositionToString } from "../../models/FieldPosition";
    import PlayerSkillChart from "./PlayerSkillChart.svelte";
    import {
        ChevronDoubleDownOutline,
        ChevronDoubleUpOutline,
    } from "flowbite-svelte-icons";
    import { Accordion, AccordionItem } from "flowbite-svelte";
    import { Player } from "../../ic-agent/declarations/league";

    export let player: Player;
</script>

<div class="mt-2 border rounded p-2">
    <div class="flex justify-around">
        <div class="flex flex-col items-center justify-center">
            <div class="text-2xl">{fieldPositionToString(player.position)}</div>

            <UniqueAvatar
                id={player.id}
                size={40}
                borderStroke={undefined}
                condition={undefined}
            />
            <div class="">
                #{player.id}
                {player.name}
            </div>
        </div>
        <div class="flex flex-col items-center justify-center">
            <PlayerSkillChart skills={player.skills} />
        </div>
    </div>
    <div class="flex items-center justify-center">
        <Accordion border={false} flush={true}>
            <AccordionItem
                paddingFlush=""
                defaultClass="flex items-center font-medium w-full text-right justify-center gap-2"
            >
                <span slot="header">
                    <div class="text-md">Details</div>
                </span>
                <span slot="arrowdown">
                    <ChevronDoubleDownOutline size="xs" />
                </span>
                <div slot="arrowup">
                    <ChevronDoubleUpOutline size="xs" />
                </div>
                <div class="p-2 text-left">
                    <div class="text-lg font-bold text-center">
                        {player.title}
                    </div>
                    <div class="text-sm text-gray-600">
                        {player.description}
                    </div>
                    <div class="mt-2">
                        <div class="font-semibold">Quirks:</div>
                        <ul class="list-disc list-inside">
                            {#each player.quirks as quirk}
                                <li>{quirk}</li>
                            {/each}
                        </ul>
                    </div>
                    <div class="mt-2">
                        <div class="font-semibold">Likes:</div>
                        <ul class="list-disc list-inside">
                            {#each player.likes as like}
                                <li>{like}</li>
                            {/each}
                        </ul>
                    </div>
                    <div class="mt-2">
                        <div class="font-semibold">Dislikes:</div>
                        <ul class="list-disc list-inside">
                            {#each player.dislikes as dislike}
                                <li>{dislike}</li>
                            {/each}
                        </ul>
                    </div>
                </div>
            </AccordionItem>
        </Accordion>
    </div>
</div>
