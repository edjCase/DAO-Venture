<script lang="ts" context="module">
  export interface Item {
    label: string;
    href?: string;
    onClick: () => void;
    icon: any;
  }
</script>

<script lang="ts">
  import { BottomNav, BottomNavItem, Drawer } from "flowbite-svelte";
  import { BarsOutline } from "flowbite-svelte-icons";
  import Sidebar from "flowbite-svelte/Sidebar.svelte";
  import SidebarGroup from "flowbite-svelte/SidebarGroup.svelte";
  import SidebarItem from "flowbite-svelte/SidebarItem.svelte";
  import { onMount } from "svelte";
  import { useLocation } from "svelte-routing";

  export let items: Item[];
  export let drawerItems: Item[];
  let location = useLocation();
  let activeUrl: string | undefined;
  location.subscribe((location) => {
    activeUrl = location.pathname;
  });
  let onItemClick = (onClick: () => void) => (event: MouseEvent) => {
    event.preventDefault();
    event.stopPropagation();
    onClick();
    drawerHidden = true;
  };
  let drawerHidden = true;
  let toggleDrawer = () => {
    drawerHidden = !drawerHidden;
  };

  let iconClass =
    "w-5 h-5 mb-1 text-gray-500 dark:text-gray-400 group-hover:text-primary-600 dark:group-hover:text-primary-500";

  onMount(() => {
    window.addEventListener("click", (event) => {
      const drawer = document.getElementById("drawer");
      const hamburger = document.getElementById("hamburger");
      if (
        drawer &&
        hamburger &&
        !drawer.contains(event.target as Node) &&
        !hamburger.contains(event.target as Node)
      ) {
        drawerHidden = true;
      }
    });
  });
</script>

<BottomNav
  {activeUrl}
  position="fixed"
  classInner="grid-cols-{items.length + 1}"
>
  {#each items as item}
    <BottomNavItem
      btnName={item.label}
      href={item.href}
      on:click={onItemClick(item.onClick)}
    >
      <svelte:component this={item.icon} class={iconClass} />
    </BottomNavItem>
  {/each}
  <BottomNavItem id="hamburger" btnName="" on:click={toggleDrawer}>
    <BarsOutline class={iconClass} />
  </BottomNavItem>
</BottomNav>

<Drawer
  id="drawer"
  backdrop={false}
  bind:hidden={drawerHidden}
  activateClickOutside={false}
  placement="right"
  transitionType="fly"
  width="w-42"
  position="fixed"
  divClass="overflow-y-auto z-40 p-4 bg-gray-800 flex flex-col justify-center"
>
  <Sidebar asideClass="w-32" {activeUrl}>
    <SidebarGroup>
      {#each drawerItems as item}
        <SidebarItem
          label={item.label}
          href={item.href}
          on:click={onItemClick(item.onClick)}
        >
          <svelte:fragment slot="icon">
            <svelte:component this={item.icon} class={iconClass} />
          </svelte:fragment>
        </SidebarItem>
      {/each}
    </SidebarGroup>
  </Sidebar>
</Drawer>
