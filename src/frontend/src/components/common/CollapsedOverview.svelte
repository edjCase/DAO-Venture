<script lang="ts">
  import { Accordion, AccordionItem } from "flowbite-svelte";
  import {
    ChevronDoubleDownOutline,
    ChevronDoubleUpOutline,
  } from "flowbite-svelte-icons";

  export let title: string;
</script>

<section class="schedule-overview bg-gray-800 p-6 text-gray-300">
  <div class="text-center mb-6">
    <h2 class="text-3xl font-bold text-gray-100">{title}</h2>
  </div>
  <Accordion border={false} flush={true}>
    <AccordionItem
      paddingFlush=""
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
      <slot />
    </AccordionItem>
  </Accordion>
</section>
