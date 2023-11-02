<script>
  let showTooltip = false;
</script>

<div
  class="container"
  on:mouseover={() => (showTooltip = true)}
  on:focus={() => {}}
  on:mouseout={() => (showTooltip = false)}
  on:blur={() => {}}
>
  <slot name="content" />

  {#if showTooltip}
    <div class="tooltip">
      <slot name="tooltip" />
    </div>
  {/if}
</div>

<style>
  .container {
    position: relative;
    display: inline-block;
  }

  .tooltip {
    position: absolute;
    top: 0;
    right: 0;
    transform: translate(100%, -100%);
    background-color: white;
    border: black solid 1px;
    color: black;
    padding: 5px;
    border-radius: 3px;
    font-size: 12px;
    z-index: 1000; /* Ensure tooltip floats above everything */
  }
</style>
