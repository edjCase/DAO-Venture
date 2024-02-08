<script lang="ts">
  import LoginButton from "../common/LoginButton.svelte";
  import { Avatar, Dropdown, DropdownItem } from "flowbite-svelte";
  import { CheckSolid, FileCopyOutline } from "flowbite-svelte-icons";
  import { Link } from "svelte-routing";
  import {
    uniqueNamesGenerator,
    adjectives,
    colors,
    animals,
  } from "unique-names-generator";
  import { toSvg } from "jdenticon";
  import { userStore } from "../../stores/UserStore";
  import { Principal } from "@dfinity/principal";

  let adminUsers: string[] = [];
  $: user = $userStore;
  $: isAdmin = user && adminUsers.includes(user.id.toString());

  userStore.subscribeAdmins((adminIds: Principal[]) => {
    adminUsers = adminIds.map((id) => id.toString());
  });

  let idCopied = false;
  let copyPrincipal = () => {
    if (user) {
      idCopied = true;
      navigator.clipboard.writeText(user.id.toString());
      setTimeout(() => {
        idCopied = false;
      }, 2000); // wait for 2 seconds
    }
  };
  let logout = () => {
    userStore.logout();
  };
</script>

<div
  class="flex items-center space-x-4 md:order-1 cursor-pointer"
  id="avatar-menu"
>
  {#if user}
    <Avatar border>
      {@html toSvg(user.id.toString(), 100)}
    </Avatar>
    <div class="space-y-1 font-medium dark:text-white">
      <div>
        {uniqueNamesGenerator({
          dictionaries: [adjectives, colors, animals],
          separator: " ",
          style: "capital",
          seed: user.id.toString(),
        })}
      </div>
      <div class="text-center text-sm text-gray-500 dark:text-gray-400">
        {#if user.user}
          Points: {user.user.points}
        {/if}
      </div>
    </div>
  {:else}
    <LoginButton />
  {/if}
</div>
{#if user}
  <Dropdown placement="bottom" triggeredBy="#avatar-menu" class="w-40">
    <div slot="header" class="p-1">
      <div
        class="text-sm text-gray-500 dark:text-gray-400 flex items-center w-36 gap-2"
      >
        <!-- TODO how to get dropdown not to close one clicking this? -->
        {#if idCopied}
          <CheckSolid />
        {:else}
          <FileCopyOutline on:click={copyPrincipal} class="flex-shrink-0" />
        {/if}
        <div class="text-center truncate flex-grow">
          {user.id.toString()}
        </div>
      </div>
    </div>
    {#if isAdmin}
      <Link to="/admin">
        <DropdownItem>Admin</DropdownItem>
      </Link>
    {/if}
    <DropdownItem on:click={logout} slot="footer">Logout</DropdownItem>
  </Dropdown>
{/if}
