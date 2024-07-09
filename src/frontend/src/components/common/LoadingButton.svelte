<script lang="ts">
    import { Button, Spinner } from "flowbite-svelte";

    export let onClick: () => Promise<void>;
    export let pill: boolean | undefined = undefined;
    export let outline: boolean | undefined = undefined;
    export let size: "xs" | "sm" | "lg" | "xl" | "md" | undefined = undefined;
    export let type: "submit" | "reset" | "button" | undefined | null =
        undefined;
    export let color:
        | "red"
        | "yellow"
        | "green"
        | "purple"
        | "blue"
        | "light"
        | "dark"
        | "primary"
        | "none"
        | "alternative"
        | undefined = undefined;
    export let shadow: boolean | undefined = undefined;
    export let tag: string | undefined = undefined;
    export let checked: boolean | undefined = undefined;

    let loading = false;
    let onClickHandler = async () => {
        loading = true;
        try {
            await onClick();
        } finally {
            loading = false;
        }
    };
</script>

<Button
    class={$$props.class}
    {pill}
    {outline}
    {size}
    {type}
    {color}
    {shadow}
    {tag}
    {checked}
    disabled={loading}
    on:click={onClickHandler}
>
    {#if loading}
        <div class="ml-2">
            <Spinner size="5" />
        </div>
    {:else}
        <slot />
    {/if}
</Button>
