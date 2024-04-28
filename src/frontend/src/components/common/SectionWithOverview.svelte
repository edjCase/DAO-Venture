<script lang="ts">
    import { Accordion, AccordionItem } from "flowbite-svelte";
    import {
        ChevronDoubleDownOutline,
        ChevronDoubleUpOutline,
    } from "flowbite-svelte-icons";

    export let title: string;
</script>

<section class="bg-gray-800 text-gray-300">
    <div class="p-2 pt-4">
        <div class="text-center">
            <div class="flex items-center justify-center gap-2">
                <slot name="title-img" />
                <div class="text-3xl font-bold text-gray-100">{title}</div>
            </div>
        </div>
        {#if $$slots.details}
            <Accordion border={false} flush={true}>
                <AccordionItem
                    paddingFlush=""
                    borderBottomClass=""
                    defaultClass="flex items-center font-medium w-full text-right justify-center gap-2"
                >
                    <span slot="header">
                        <div class="text-md text-right">Details</div>
                    </span>
                    <span slot="arrowdown">
                        <ChevronDoubleDownOutline size="xs" />
                    </span>
                    <div slot="arrowup">
                        <ChevronDoubleUpOutline size="xs" />
                    </div>
                    <slot name="details" />
                </AccordionItem>
            </Accordion>
        {/if}
    </div>
    <div class="p-2">
        <slot />
    </div>
</section>
