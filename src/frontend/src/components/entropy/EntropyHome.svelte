<script lang="ts">
    import { Accordion, AccordionItem } from "flowbite-svelte";
    import { EntropyData, Team } from "../../ic-agent/declarations/main";
    import { entropyStore } from "../../stores/EntropyStore";
    import { teamStore } from "../../stores/TeamStore";
    import SectionWithOverview from "../common/SectionWithOverview.svelte";
    import EntropyGauge from "./EntropyGauge.svelte";
    import {
        ChevronDoubleDownOutline,
        ChevronDoubleUpOutline,
    } from "flowbite-svelte-icons";

    let teams: Team[] = [];
    let entropyData: EntropyData | undefined;

    teamStore.subscribe((t) => {
        if (!t) {
            return;
        }
        teams = t;
        teams.sort((a, b) => Number(b.entropy) - Number(a.entropy));
    });
    entropyStore.subscribeData((data) => {
        entropyData = data;
    });
</script>

<SectionWithOverview title="Entropy">
    <ul slot="details" class="list-disc list-inside text-sm space-y-1">
        <li>Entropy is a measure of chaos in the league</li>
        <li>
            If the entropy gets too high, the league will collapse into chaos
        </li>
        <li>
            Each team has their own entropy metric. When the team is
            collaborative the entropy goes down, when selfish it goes up
        </li>
    </ul>
    <div class="border-2 rounded border-gray-700 p-4">
        <div class="mx-auto">
            {#if !entropyData}
                <div></div>
            {:else}
                <EntropyGauge {entropyData} />
                <Accordion border={false} flush={true}>
                    <AccordionItem
                        paddingFlush=""
                        borderBottomClass=""
                        defaultClass="flex items-center font-medium w-full text-right justify-center gap-2"
                    >
                        <span slot="header">
                            <div class="text-md text-right">Entropy Data</div>
                        </span>
                        <span slot="arrowdown">
                            <ChevronDoubleDownOutline size="xs" />
                        </span>
                        <div slot="arrowup">
                            <ChevronDoubleUpOutline size="xs" />
                        </div>

                        <div class="flex flex-col items-center">
                            <div>💰 Dividend</div>
                            <div>
                                Max: {entropyData.maxDividend}
                            </div>
                            <div>
                                Current: {entropyData.currentDividend}
                            </div>
                        </div>
                    </AccordionItem>
                </Accordion>
            {/if}
        </div>
    </div>
</SectionWithOverview>
