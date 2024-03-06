<script lang="ts">
  import UserMenu from "../user/UserMenu.svelte";
  import {
    Navbar,
    NavBrand,
    NavLi,
    NavUl,
    NavHamburger,
    MegaMenu,
  } from "flowbite-svelte";
  import { ChevronDownOutline } from "flowbite-svelte-icons";
  import { onMount } from "svelte";
  import NavBarLink from "./NavBarLink.svelte";
  import { userStore } from "../../stores/UserStore";
  import { Principal } from "@dfinity/principal";
  import { Link } from "svelte-routing";

  let adminUsers: string[] = [];
  $: user = $userStore;

  userStore.subscribeAdmins((adminIds: Principal[]) => {
    adminUsers = adminIds.map((id) => id.toString());
  });

  $: isAdmin = user && adminUsers.includes(user.id.toString());

  let activeUrl = "";

  onMount(() => (activeUrl = window.location.pathname));
  let activeClass =
    "text-white bg-green-700 md:bg-transparent md:text-green-700 md:dark:text-white dark:bg-green-600 md:dark:bg-transparent";
  let nonActiveClass =
    "text-gray-700 hover:bg-gray-100 md:hover:bg-transparent md:border-0 md:hover:text-green-700 dark:text-gray-400 md:dark:hover:text-white dark:hover:bg-gray-700 dark:hover:text-white md:dark:hover:bg-transparent";

  let links = [
    {
      name: "Blog",
      href: "https://mora.app/planet/a46fs-ryaaa-aaaan-qdcyq-cai",
    },
    {
      name: "Taggr",
      href: "https://taggr.network/#/realm/DAOBALL",
    },
    {
      name: "DSCVR",
      href: "https://dscvr.one/p/daoball",
    },
    {
      name: "Github",
      href: "https://github.com/edjcase/daoball",
    },
  ];
</script>

<Navbar rounded color="form" class="mb-4 mt-4 mx-auto" let:hidden let:toggle>
  <NavBrand>
    <Link to="/">
      <img src="/images/logo.png" class="h-16" alt="DAOball Logo" />
    </Link>
  </NavBrand>
  <UserMenu />
  <NavHamburger on:click={toggle} />
  <NavUl {activeUrl} {activeClass} {nonActiveClass} {hidden}>
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
    <MegaMenu
      items={links}
      full={false}
      ulClass="grid grid-flow-row gap-y-4 gap-x-4 auto-col-max auto-row-max"
      let:item
    >
      <a
        href={item.href}
        class="hover:text-primary-600 dark:hover:text-primary-500"
        >{item.name}</a
      >
    </MegaMenu>
    {#if isAdmin}
      <NavBarLink to="/admin">Admin</NavBarLink>
    {/if}
  </NavUl>
</Navbar>
