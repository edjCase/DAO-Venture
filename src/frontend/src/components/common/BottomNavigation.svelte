<script lang="ts">
    import { BottomNav, BottomNavItem } from "flowbite-svelte";
    import {
        BellRingSolid,
        BullhornSolid,
        HomeSolid,
        UserCircleSolid,
    } from "flowbite-svelte-icons";
    import { navigate, useLocation } from "svelte-routing";

    let location = useLocation();
    let activeUrl: string | undefined;
    location.subscribe((location) => {
        activeUrl = location.pathname;
    });

    let navOnClick = (url: string) => (event: MouseEvent) => {
        event.preventDefault();
        event.stopPropagation();
        navigate(url);
    };
</script>

<BottomNav {activeUrl} position="fixed" classInner="grid-cols-4">
    <BottomNavItem btnName="Home" href="/" on:click={navOnClick("/")}>
        <HomeSolid
            class="w-5 h-5 mb-1 text-gray-500 dark:text-gray-400 group-hover:text-primary-600 dark:group-hover:text-primary-500"
        />
    </BottomNavItem>
    <BottomNavItem
        btnName="Scenarios"
        href="/scenarios"
        on:click={navOnClick("/scenarios")}
    >
        <BellRingSolid
            class="w-5 h-5 mb-1 text-gray-500 dark:text-gray-400 group-hover:text-primary-600 dark:group-hover:text-primary-500"
        />
    </BottomNavItem>
    <BottomNavItem
        btnName="Season"
        href="/season"
        on:click={navOnClick("/season")}
    >
        <BullhornSolid
            class="w-5 h-5 mb-1 text-gray-500 dark:text-gray-400 group-hover:text-primary-600 dark:group-hover:text-primary-500"
        />
    </BottomNavItem>
    <BottomNavItem
        btnName="My Team"
        href="/my-team"
        on:click={navOnClick("/my-team")}
    >
        <UserCircleSolid
            class="w-5 h-5 mb-1 text-gray-500 dark:text-gray-400 group-hover:text-primary-600 dark:group-hover:text-primary-500"
        />
    </BottomNavItem>
</BottomNav>
