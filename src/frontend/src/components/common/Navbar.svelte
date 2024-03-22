<script lang="ts">
  import { Navbar, NavBrand } from "flowbite-svelte";
  import { BellOutline, BellRingSolid } from "flowbite-svelte-icons";
  import { Link } from "svelte-routing";
  let notifications = false;
  let openNotifications = () => {
    // TODO
  };
</script>

<Navbar rounded color="form">
  <NavBrand>
    <Link to="/">
      <img src="/images/logo.png" class="h-16" alt="DAOball Logo" />
    </Link>
  </NavBrand>
  <div
    class="mx-5"
    on:click={openNotifications}
    role="button"
    tabindex="0"
    on:keydown={() => {}}
  >
    {#if notifications}
      <BellRingSolid size="md" />
    {:else}
      <BellOutline size="md" />
    {/if}
  </div>
</Navbar>
