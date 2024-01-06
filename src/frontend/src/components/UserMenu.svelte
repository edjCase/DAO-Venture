<script>
  import LoginButton from "./LoginButton.svelte";
  import { Avatar } from "flowbite-svelte";
  import { Dropdown, DropdownItem } from "flowbite-svelte";
  import {
    uniqueNamesGenerator,
    adjectives,
    colors,
    animals,
  } from "unique-names-generator";
  import { toSvg } from "jdenticon";
  import { identityStore } from "../stores/IdentityStore";

  $: identity = $identityStore;
</script>

<div
  class="flex items-center space-x-4 md:order-1 cursor-pointer"
  id="avatar-menu"
>
  {#if identity}
    <Avatar border>
      {@html toSvg(identity.getPrincipal().toString(), 100)}
    </Avatar>
    <div class="space-y-1 font-medium dark:text-white">
      <div>
        {uniqueNamesGenerator({
          dictionaries: [adjectives, colors, animals],
          separator: " ",
          style: "capital",
          seed: identity.getPrincipal().toString(),
        })}
      </div>
      <div class="text-sm text-gray-500 dark:text-gray-400">110 points</div>
    </div>
    <Dropdown placement="bottom" triggeredBy="#avatar-menu" class="w-full">
      <DropdownItem href="/admin">Admin</DropdownItem>
      <DropdownItem on:click={() => identityStore.logout()}>
        Sign out
      </DropdownItem>
    </Dropdown>
  {:else}
    <LoginButton />
  {/if}
</div>
