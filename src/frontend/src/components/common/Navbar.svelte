<script>
  import { Link } from "svelte-routing";
  import UserMenu from "../user/UserMenu.svelte";
  import UpdateLeagueCanistersButton from "../UpdateLeagueCanistersButton.svelte";
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
  import { ChevronDownOutline, UserOutline } from "flowbite-svelte-icons";
  import { onMount } from "svelte";
  import NavBarLink from "./NavBarLink.svelte";

  let activeUrl = "";

  onMount(() => (activeUrl = window.location.pathname));
  let activeClass =
    "text-white bg-green-700 md:bg-transparent md:text-green-700 md:dark:text-white dark:bg-green-600 md:dark:bg-transparent";
  let nonActiveClass =
    "text-gray-700 hover:bg-gray-100 md:hover:bg-transparent md:border-0 md:hover:text-green-700 dark:text-gray-400 md:dark:hover:text-white dark:hover:bg-gray-700 dark:hover:text-white md:dark:hover:bg-transparent";
</script>

<Navbar rounded color="form" class="mb-4 mt-4 mx-auto">
  <NavBrand href="/">
    <img src="/images/logo.png" class="me-3 h-16" alt="DAOball Logo" />
    <span
      class="self-center whitespace-nowrap text-xl font-semibold dark:text-white"
    >
      DAOball
    </span>
  </NavBrand>
  <UserMenu />
  <NavUl {activeUrl} {activeClass} {nonActiveClass}>
    <NavBarLink to="/">Home</NavBarLink>
    <NavBarLink to="/teams">Teams</NavBarLink>
    <NavBarLink to="/players">Players</NavBarLink>
    <NavBarLink to="/schedule">Schedule</NavBarLink>
    <NavBarLink to="/HowToPlay">How To Play</NavBarLink>
    <NavBarLink to="/about">About</NavBarLink>
    <NavLi class="cursor-pointer">
      Links
      <ChevronDownOutline
        class="w-3 h-3 ms-2 text-primary-800 dark:text-white inline"
      />
    </NavLi>
    <Dropdown class="w-44 z-20">
      <DropdownItem href="https://mora.app/planet/a46fs-ryaaa-aaaan-qdcyq-cai">
        Blog
      </DropdownItem>
      <DropdownItem href="https://taggr.network/#/realm/DAOBALL">
        Taggr
      </DropdownItem>
      <DropdownItem href="https://dscvr.one/p/daoball">DSCVR</DropdownItem>
      <DropdownItem href="https://github.com/edjcase/daoball">
        Github
      </DropdownItem>
    </Dropdown>
  </NavUl>
</Navbar>
