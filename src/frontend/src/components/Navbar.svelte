<script>
  import { Link } from "svelte-routing";
  import LoginButton from "./LoginButton.svelte";
  import UpdateLeagueCanistersButton from "./UpdateLeagueCanistersButton.svelte";
  import {
    Navbar,
    NavBrand,
    NavLi,
    NavUl,
    NavHamburger,
    Avatar,
    Dropdown,
    DropdownItem,
    DropdownHeader,
    DropdownDivider,
  } from "flowbite-svelte";
  import { ChevronDownOutline } from "flowbite-svelte-icons";
  import { onMount } from "svelte";

  let activeUrl = "";

  onMount(() => (activeUrl = window.location.pathname));
  let activeClass =
    "text-white bg-green-700 md:bg-transparent md:text-green-700 md:dark:text-white dark:bg-green-600 md:dark:bg-transparent";
  let nonActiveClass =
    "text-gray-700 hover:bg-gray-100 md:hover:bg-transparent md:border-0 md:hover:text-green-700 dark:text-gray-400 md:dark:hover:text-white dark:hover:bg-gray-700 dark:hover:text-white md:dark:hover:bg-transparent";
</script>

<Navbar rounded color="form" class="mb-4 mx-auto">
  <NavBrand href="/">
    <img src="/images/logo.jpg" class="me-3 h-6 sm:h-9" alt="DAOball Logo" />
    <span
      class="self-center whitespace-nowrap text-xl font-semibold dark:text-white"
    >
      DAOball
    </span>
  </NavBrand>
  <div class="flex items-center md:order-2">
    <Avatar id="avatar-menu" src="/images/logo.jpg" />
    <NavHamburger class1="w-full md:flex md:w-auto md:order-1" />
  </div>
  <Dropdown placement="bottom" triggeredBy="#avatar-menu">
    <DropdownHeader>
      <span class="block text-sm">Username</span>
      <span class="block truncate text-sm font-medium">100 points</span>
    </DropdownHeader>
    <DropdownItem href="/admin">Admin</DropdownItem>
    <DropdownItem>Sign out</DropdownItem>
  </Dropdown>
  <NavUl {activeUrl} {activeClass} {nonActiveClass}>
    <NavLi href="/">Home</NavLi>
    <NavLi href="/teams">Teams</NavLi>
    <NavLi href="/schedule">Schedule</NavLi>
    <NavLi class="cursor-pointer">
      Links<ChevronDownOutline
        class="w-3 h-3 ms-2 text-primary-800 dark:text-white inline"
      />
    </NavLi>
    <Dropdown class="w-44 z-20">
      <DropdownItem href="https://mora.app/planet/a46fs-ryaaa-aaaan-qdcyq-cai"
        >Blog</DropdownItem
      >
      <DropdownItem href="https://dscvr.one/p/daoball">DSCVR</DropdownItem>
      <DropdownItem href="https://github.com/edjcase/daoball"
        >Github</DropdownItem
      >
    </Dropdown>
  </NavUl>
</Navbar>
