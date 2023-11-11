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

<button class="button-style" on:click={toggleTheme}>Toggle theme</button>
