<script lang="ts">
  import { Navbar } from "flowbite-svelte";
  import { Link } from "svelte-routing";
  import UserMenu from "../user/UserMenu.svelte";
  import { worldStore } from "../../stores/WorldStore";

  $: world = $worldStore;
</script>

<Navbar rounded color="form" class="mb-2">
  <div class="flex-1">
    <UserMenu />
  </div>
  <div class="flex-1">
    <Link to="/"><div class="text-center text-4xl">DAO TOWNS</div></Link>
  </div>
  <div class="flex-1 text-center">Turn: {world?.turn}</div>
</Navbar>
