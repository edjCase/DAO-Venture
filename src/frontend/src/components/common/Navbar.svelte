<script lang="ts">
  import { Indicator, Navbar, NavBrand } from "flowbite-svelte";
  import { BellOutline, BellRingSolid } from "flowbite-svelte-icons";
  import { Link } from "svelte-routing";
  let notificationCount = 0;
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
    {#if notificationCount > 0}
      <div class="relative p-2">
        <BellRingSolid size="md" />
        <Indicator color="red" size="lg" placement="top-right">
          <span class="text-white text-xs font-bold">{notificationCount}</span>
        </Indicator>
      </div>
    {:else}
      <BellOutline size="md" />
    {/if}
  </div>
</Navbar>
