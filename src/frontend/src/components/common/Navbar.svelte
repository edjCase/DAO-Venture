<script lang="ts">
  import { Navbar, NavBrand } from "flowbite-svelte";
  import { Link } from "svelte-routing";
  import UserMenu from "../user/UserMenu.svelte";
</script>

<Navbar rounded color="form">
  <NavBrand>
    <Link to="/">
      <img src="/images/logo.png" class="h-16" alt="DAOball Logo" />
    </Link>
  </NavBrand>

  <UserMenu />
  <div class="w-10 h-10"></div>
</Navbar>
