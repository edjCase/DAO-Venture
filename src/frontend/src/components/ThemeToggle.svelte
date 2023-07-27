<script>
  let isDarkMode = true;

  const toggleTheme = () => {
    isDarkMode = !isDarkMode;
    document.documentElement.setAttribute(
      "data-theme",
      isDarkMode ? "dark" : "light"
    );
  };
</script>

<div on:click={toggleTheme} on:keypress={toggleTheme} class="toggle">
  {#if !isDarkMode} ☀️ {:else} 🌙 {/if}
</div>

<style>
  .toggle {
    cursor: pointer;
    font-size: 18px;
    padding-bottom: 3px;
  }
</style>
