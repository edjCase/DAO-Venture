<script lang="ts">
  import {
    BookOutline,
    GithubSolid,
    HomeSolid,
    QuestionCircleOutline,
    TwitterSolid,
    ClipboardListSolid,
    UserCircleSolid,
    UserGroupSolid,
    BarsOutline,
  } from "flowbite-svelte-icons";
  import { navigate, useLocation } from "svelte-routing";
  import { userStore } from "../../stores/UserStore";
  import UserAvatar from "../user/UserAvatar.svelte";
  import GenericBottomNavigation, {
    Item,
  } from "./GenericBottomNavigation.svelte";
  import { Sidebar, SidebarGroup, SidebarItem } from "flowbite-svelte";

  $: user = $userStore;

  let navOnClick = (url: string) => (event: MouseEvent) => {
    event.preventDefault();
    event.stopPropagation();
    navigate(url);
  };
  let location = useLocation();
  let activeUrl: string | undefined;
  location.subscribe((location) => {
    activeUrl = location.pathname;
  });

  let items: Item[] = [
    {
      label: "Home",
      href: "/",
      icon: HomeSolid,
      onClick: () => navigate("/"),
    },
    {
      label: "DAO",
      href: "/dao",
      icon: UserGroupSolid,
      onClick: () => navigate("/dao"),
    },
    {
      label: "Content",
      href: "/content",
      icon: ClipboardListSolid,
      onClick: () => navigate("/content"),
    },
  ];
  let iconClass =
    "w-5 h-5 mb-1 text-gray-500 dark:text-gray-400 group-hover:text-primary-600 dark:group-hover:text-primary-500";
</script>

<GenericBottomNavigation
  {items}
  drawerLocation="right"
  drawerIcon={BarsOutline}
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
</GenericBottomNavigation>
