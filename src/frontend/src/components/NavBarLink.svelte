<script lang="ts">
  import { Link, useLocation } from "svelte-routing";
  import { NavLi } from "flowbite-svelte";

  export let to: string;
  let linkClasses = "";
  useLocation().subscribe((location) => {
    if (location.pathname == to) {
      linkClasses =
        "text-white bg-primary-700 md:bg-transparent md:text-primary-700 md:dark:text-white dark:bg-primary-600 md:dark:bg-transparent";
    } else {
      linkClasses = "";
    }
  });
</script>

<NavLi>
  <Link {to} class={linkClasses}><slot /></Link>
</NavLi>
