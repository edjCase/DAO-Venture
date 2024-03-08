<script lang="ts">
  import LoginButton from "../common/LoginButton.svelte";
  import { Dropdown, DropdownItem } from "flowbite-svelte";
  import { CheckSolid, FileCopyOutline } from "flowbite-svelte-icons";
  import { userStore } from "../../stores/UserStore";
  import UserAvatar from "./UserAvatar.svelte";
  import UserPseudonym from "./UserPseudonym.svelte";

  $: user = $userStore;

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
  class="flex items-center space-x-2 md:order-1 cursor-pointer max-w-48"
  id="avatar-menu"
>
  {#if user}
    <UserAvatar userId={user.id} />
    <div class="space-y-1 font-medium dark:text-white text-center">
      <div>
        <UserPseudonym userId={user.id} />
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

    <DropdownItem on:click={logout}>Logout</DropdownItem>
  </Dropdown>
{/if}
