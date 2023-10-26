<script lang="ts">
  import { AuthClient } from "@dfinity/auth-client";
  import { identityStore } from "../stores/IdentityStore";

  $: identity = $identityStore;

  let login = async () => {
    let authClient = await AuthClient.create();
    await authClient.login({
      maxTimeToLive: BigInt(30) * BigInt(24) * BigInt(3_600_000_000_000), // 30 days
      identityProvider:
        process.env.DFX_NETWORK === "ic"
          ? "https://identity.ic0.app"
          : `http://localhost:4943/?canisterId=rdmx6-jaaaa-aaaaa-aaadq-cai`,
    });
    const identity = authClient.getIdentity();
    if (!identity.getPrincipal().isAnonymous()) {
      identityStore.set(identity);
    }
  };
  let logout = async () => {
    let authClient = await AuthClient.create();
    try {
      await authClient.logout();
    } finally {
      identityStore.set(null);
    }
  };
</script>

{#if identity}
  <button on:click={logout}>Logout</button>
{:else}
  <button on:click={login}>Login</button>
{/if}
