<script>
  import LoginButton from "../common/LoginButton.svelte";
  import { Avatar, Dropdown, DropdownItem, Button } from "flowbite-svelte";
  import { FileCopyOutline } from "flowbite-svelte-icons";
  import { Link } from "svelte-routing";
  import {
    uniqueNamesGenerator,
    adjectives,
    colors,
    animals,
  } from "unique-names-generator";
  import { toSvg } from "jdenticon";
  import { identityStore } from "../../stores/IdentityStore";

  $: identity = $identityStore;

  let copyPrincipal = () => {
    navigator.clipboard.writeText(identity.id.toString());
  };
  let logout = () => {
    identityStore.logout();
  };
</script>

<div
  class="flex items-center space-x-4 md:order-1 cursor-pointer"
  id="avatar-menu"
>
  {#if identity}
    <Avatar border>
      {@html toSvg(identity.id.toString(), 100)}
    </Avatar>
    <div class="space-y-1 font-medium dark:text-white">
      <div>
        {uniqueNamesGenerator({
          dictionaries: [adjectives, colors, animals],
          separator: " ",
          style: "capital",
          seed: identity.id.toString(),
        })}
      </div>
      <div
        class="text-sm text-gray-500 dark:text-gray-400 flex items-center w-32"
      >
        <div class="truncate flex-grow">
          {identity.id.toString()}
        </div>
        <FileCopyOutline on:click={copyPrincipal} class="flex-shrink-0" />
      </div>
    </div>
    <Dropdown placement="bottom" triggeredBy="#avatar-menu" class="w-40">
      {#if identity.isAdmin}
        <Link to="/admin">
          <DropdownItem>Admin</DropdownItem>
        </Link>
      {/if}
      <DropdownItem on:click={logout} slot="footer">Logout</DropdownItem>
    </Dropdown>
  {:else}
    <LoginButton />
  {/if}
</div>
