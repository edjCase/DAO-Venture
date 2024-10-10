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
  } from "flowbite-svelte-icons";
  import { navigate } from "svelte-routing";
  import { userStore } from "../../stores/UserStore";
  import UserAvatar from "../user/UserAvatar.svelte";
  import GenericBottomNavigation, {
    Item,
  } from "./GenericBottomNavigation.svelte";

  $: user = $userStore;

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

  let drawerItems: Item[] = [
    {
      label: "Profile",
      href: "/profile",
      icon: user ? UserAvatar : UserCircleSolid,
      onClick: () => navigate("/profile"),
    },
    {
      label: "About",
      href: "/about",
      icon: QuestionCircleOutline,
      onClick: () => navigate("/about"),
    },
    {
      label: "Game Overview",
      href: "/game-overview",
      icon: BookOutline,
      onClick: () => navigate("/game-overview"),
    },
    {
      label: "DAO Overview",
      href: "/dao-overview",
      icon: BookOutline,
      onClick: () => navigate("/dao-overview"),
    },
    {
      label: "Image Editor",
      href: "/image-editor",
      icon: BookOutline,
      onClick: () => navigate("/image-editor"),
    },
    {
      label: "Github",
      href: "https://github.com/edjcase/daoball",
      icon: GithubSolid,
      onClick: () =>
        window.open("https://github.com/edjcase/daoball", "_blank"),
    },
    {
      label: "Twitter",
      href: "https://twitter.com/daoventure_game",
      icon: TwitterSolid,
      onClick: () =>
        window.open("https://twitter.com/daoventure_game", "_blank"),
    },
  ];
</script>

<GenericBottomNavigation {items} {drawerItems} />
