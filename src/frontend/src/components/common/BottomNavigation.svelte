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
        BellRingSolid,
        BookOutline,
        BullhornSolid,
        CalendarMonthOutline,
        GithubSolid,
        HomeSolid,
        QuestionCircleOutline,
        TwitterSolid,
        UserCircleSolid,
        UsersSolid,
    } from "flowbite-svelte-icons";
    import { onMount } from "svelte";
    import { navigate, useLocation } from "svelte-routing";
    import UserMenu from "../user/UserMenu.svelte";

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
</script>

<BottomNav {activeUrl} position="fixed" classInner="grid-cols-5">
    <BottomNavItem btnName="Home" href="/" on:click={navOnClick("/")}>
        <HomeSolid class={iconClass} />
    </BottomNavItem>
    <BottomNavItem
        btnName="Scenarios"
        href="/scenarios"
        on:click={navOnClick("/scenarios")}
    >
        <BellRingSolid class={iconClass} />
    </BottomNavItem>
    <BottomNavItem
        btnName="Season"
        href="/season"
        on:click={navOnClick("/season")}
    >
        <BullhornSolid class={iconClass} />
    </BottomNavItem>
    <BottomNavItem
        btnName="Team"
        href="/my-team"
        on:click={navOnClick("/my-team")}
    >
        <UsersSolid class={iconClass} />
    </BottomNavItem>
    <BottomNavItem id="hamburger" btnName="" on:click={toggleDrawer}>
        <BarsOutline class={iconClass} />
    </BottomNavItem>
    <Drawer
        id="drawer"
        backdrop={false}
        bind:hidden={drawerHidden}
        activateClickOutside={false}
        placement="right"
        transitionType="fly"
        width="w-42"
        position="fixed"
        divClass="overflow-y-auto z-50 p-4 bg-white dark:bg-gray-800 mb-16"
    >
        <Sidebar asideClass="w-32" {activeUrl}>
            <SidebarGroup ulClass="mb-10">
                <div
                    class="cursor-pointer"
                    on:click={navOnClick("/profile")}
                    role="button"
                    tabindex="0"
                    on:keydown={() => {}}
                >
                    <UserMenu />
                </div>
            </SidebarGroup>
            <SidebarGroup>
                <SidebarItem
                    label="Teams"
                    href="/teams"
                    on:click={navOnClick("/teams")}
                >
                    <svelte:fragment slot="icon">
                        <UsersSolid class={iconClass} />
                    </svelte:fragment>
                </SidebarItem>
                <SidebarItem
                    label="Players"
                    href="/players"
                    on:click={navOnClick("/players")}
                >
                    <svelte:fragment slot="icon">
                        <UserCircleSolid class={iconClass} />
                    </svelte:fragment>
                </SidebarItem>
                <SidebarItem
                    label="Schedule"
                    href="/schedule"
                    on:click={navOnClick("/schedule")}
                >
                    <svelte:fragment slot="icon">
                        <CalendarMonthOutline class={iconClass} />
                    </svelte:fragment>
                </SidebarItem>
                <SidebarItem
                    label="How To Play"
                    href="/how-to-play"
                    on:click={navOnClick("/how-to-play")}
                >
                    <svelte:fragment slot="icon">
                        <BookOutline class={iconClass} />
                    </svelte:fragment>
                </SidebarItem>
                <SidebarItem
                    label="About"
                    href="/about"
                    on:click={navOnClick("/about")}
                >
                    <svelte:fragment slot="icon">
                        <QuestionCircleOutline class={iconClass} />
                    </svelte:fragment>
                </SidebarItem>
                <SidebarGroup border={true}>
                    <SidebarItem
                        label="Taggr &nearr;"
                        target="_blank"
                        href="https://github.com/edjcase/daoball"
                    >
                        <svelte:fragment slot="icon">
                            <GithubSolid class={iconClass} />
                        </svelte:fragment>
                    </SidebarItem>
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
                        href="https://twitter.com/daoballxyz"
                    >
                        <svelte:fragment slot="icon">
                            <TwitterSolid class={iconClass} />
                        </svelte:fragment>
                    </SidebarItem>
                    <SidebarItem
                        label="Blog &nearr;"
                        target="_blank"
                        href="https://mora.app/planet/a46fs-ryaaa-aaaan-qdcyq-cai"
                    >
                        <svelte:fragment slot="icon">
                            <TwitterSolid class={iconClass} />
                        </svelte:fragment>
                    </SidebarItem>
                </SidebarGroup>
            </SidebarGroup>
            <SidebarGroup border={true}>
                <SidebarItem
                    label="Admin"
                    href="/admin"
                    on:click={navOnClick("/admin")}
                >
                    <svelte:fragment slot="icon">
                        <UserCircleSolid class={iconClass} />
                    </svelte:fragment>
                </SidebarItem>
            </SidebarGroup>
        </Sidebar>
    </Drawer>
</BottomNav>
