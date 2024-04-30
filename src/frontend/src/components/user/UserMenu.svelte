<script lang="ts">
  import LoginButton from "../common/LoginButton.svelte";
  import { userStore } from "../../stores/UserStore";
  import UserAvatar from "./UserAvatar.svelte";
  import UserPseudonym from "./UserPseudonym.svelte";
  import { identityStore } from "../../stores/IdentityStore";
  import { User } from "../../ic-agent/declarations/users";

  $: identity = $identityStore;

  let user: User | undefined;
  $: {
    if (!identity.getPrincipal().isAnonymous()) {
      userStore.subscribeUser(identity.getPrincipal(), (u) => {
        user = u;
      });
    }
  }
</script>

<div class="flex flex-col items-center">
  {#if !identity.getPrincipal().isAnonymous()}
    <UserAvatar userId={identity.getPrincipal()} size="lg" />
    <div class="font-medium text-center">
      <div>
        <UserPseudonym userId={identity.getPrincipal()} />
      </div>
      <div class="text-center text-sm text-gray-500 dark:text-gray-400">
        {#if user}
          {user.points} <span class="text-lg">🔮</span>
        {/if}
      </div>
    </div>
  {:else}
    <LoginButton />
  {/if}
</div>
