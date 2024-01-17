<script>
  import Navbar from "./Navbar.svelte";
  import Banner from "./Banner.svelte";
  import { BullhornSolid } from "flowbite-svelte-icons";
  import { Link } from "svelte-routing";
</script>

{#if true}
  <Banner>
    <p
      class="flex items-center text-sm font-normal text-gray-500 dark:text-gray-400"
    >
      New to DAOball? Check out our <Link
        to="/HowToPlay"
        class="inline ml-1 font-medium text-primary-600 underline dark:text-primary-500 underline-offset-2 decoration-600 dark:decoration-500 decoration-solid hover:no-underline"
        >How to Play Page</Link
      >
    </p>
  </Banner>
{/if}

<Navbar />
