<script lang="ts">
  import { Router, Route } from "svelte-routing";
  import Home from "./routes/Home.svelte";
  import NotFound from "./routes/NotFound.svelte";
  import About from "./routes/About.svelte";
  import HowToPlay from "./routes/HowToPlay.svelte";
  import UserProfile from "./routes/UserProfile.svelte";
  import BottomNavigation from "./components/common/BottomNavigation.svelte";
  import Dao from "./routes/Dao.svelte";
  import Navbar from "./components/common/Navbar.svelte";
</script>

<Router>
  <main class="p-4 max-w-xl mx-auto custom-scrollbar">
    <Navbar />
    <div>
      <Route path="/" component={Home} />
      <Route path="/dao" component={Dao} />
      <Route path="/profile" component={UserProfile} />
      <Route path="/how-to-play" component={HowToPlay} />
      <Route path="/about" component={About} />
      <Route path="*" component={NotFound} />
    </div>
  </main>

  <BottomNavigation />
</Router>

<style lang="postcss">
  main {
    height: calc(100vh - 4rem);
    overflow-y: auto;
  }

  .custom-scrollbar {
    scrollbar-width: thin;
    scrollbar-color: #4ade80 #1f2937;
  }
</style>
