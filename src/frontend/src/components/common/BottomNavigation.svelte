<script lang="ts">
  import {
    BottomNav,
    BottomNavItem,
    Drawer,
    Sidebar,
    SidebarGroup,
    SidebarItem,
  } from "flowbite-svelte";
  import {
    BarsOutline,
    BookOutline,
    GithubSolid,
    HomeSolid,
    QuestionCircleOutline,
    TwitterSolid,
    ClipboardListSolid,
    UserCircleSolid,
    UserGroupSolid,
  } from "flowbite-svelte-icons";
  import { onMount } from "svelte";
  import { navigate, useLocation } from "svelte-routing";
  import { userStore } from "../../stores/UserStore";
  import UserAvatar from "../user/UserAvatar.svelte";

  let location = useLocation();
  let activeUrl: string | undefined;
  location.subscribe((location) => {
    activeUrl = location.pathname;
  });

  let navOnClick = (url: string) => (event: MouseEvent) => {
    event.preventDefault();
    event.stopPropagation();
    navigate(url);
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

  $: user = $userStore;
</script>

<BottomNav {activeUrl} position="fixed" classInner="grid-cols-4">
  <BottomNavItem btnName="Home" href="/" on:click={navOnClick("/")}>
    <HomeSolid class={iconClass} />
  </BottomNavItem>
  <BottomNavItem btnName="DAO" href="/dao" on:click={navOnClick("/dao")}>
    <UserGroupSolid class={iconClass} />
  </BottomNavItem>

  <BottomNavItem
    btnName="Content"
    href="/content"
    on:click={navOnClick("/content")}
  >
    <ClipboardListSolid class={iconClass} />
  </BottomNavItem>
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
      <SidebarItem
        label="Profile"
        href="/profile"
        on:click={navOnClick("/profile")}
      >
        <svelte:fragment slot="icon">
          {#if user}
            <div class={iconClass}>
              <UserAvatar userId={user.id} border={false} size="md" />
            </div>
          {:else}
            <UserCircleSolid class={iconClass} />
          {/if}
        </svelte:fragment>
      </SidebarItem>
      <SidebarItem label="About" href="/about" on:click={navOnClick("/about")}>
        <svelte:fragment slot="icon">
          <QuestionCircleOutline class={iconClass} />
        </svelte:fragment>
      </SidebarItem>
      <SidebarItem
        label="Game Overview"
        href="/game-overview"
        on:click={navOnClick("/game-overview")}
      >
        <svelte:fragment slot="icon">
          <BookOutline class={iconClass} />
        </svelte:fragment>
      </SidebarItem>
      <SidebarItem
        label="DAO Overview"
        href="/dao-overview"
        on:click={navOnClick("/dao-overview")}
      >
        <svelte:fragment slot="icon">
          <BookOutline class={iconClass} />
        </svelte:fragment>
      </SidebarItem>
      <SidebarItem
        label="Image Editor"
        href="/image-editor"
        on:click={navOnClick("/image-editor")}
      >
        <svelte:fragment slot="icon">
          <BookOutline class={iconClass} />
        </svelte:fragment>
      </SidebarItem>
      <SidebarGroup border={true}>
        <!-- <SidebarItem
          label="Taggr &nearr;"
          target="_blank"
          href="https://github.com/edjcase/daoball"
        >
          <svelte:fragment slot="icon">
            <GithubSolid class={iconClass} />
          </svelte:fragment>
        </SidebarItem> -->
        <SidebarItem
          label="Github &nearr;"
          target="_blank"
          href="https://github.com/edjcase/daoball"
        >
          <svelte:fragment slot="icon">
            <GithubSolid class={iconClass} />
          </svelte:fragment>
        </SidebarItem>
        <SidebarItem
          label="Twitter &nearr;"
          target="_blank"
          href="https://twitter.com/daoventure_game"
        >
          <svelte:fragment slot="icon">
            <TwitterSolid class={iconClass} />
          </svelte:fragment>
        </SidebarItem>
        <!-- <SidebarItem
          label="Blog &nearr;"
          target="_blank"
          href="https://mora.app/planet/a46fs-ryaaa-aaaan-qdcyq-cai"
        >
          <svelte:fragment slot="icon">
            <TwitterSolid class={iconClass} />
          </svelte:fragment>
        </SidebarItem> -->
      </SidebarGroup>
    </SidebarGroup>
  </Sidebar>
</Drawer>
