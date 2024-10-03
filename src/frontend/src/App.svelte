<script lang="ts">
  import { Router, Route } from "svelte-routing";
  import Home from "./routes/Home.svelte";
  import Game from "./routes/Game.svelte";
  import NotFound from "./routes/NotFound.svelte";
  import About from "./routes/About.svelte";
  import GameOverview from "./routes/GameOverview.svelte";
  import DAOOverview from "./routes/DAOOverview.svelte";
  import UserProfile from "./routes/UserProfile.svelte";
  import Dao from "./routes/Dao.svelte";
  import ImageEditor from "./routes/ImageEditor.svelte";
  import Content from "./routes/Content.svelte";
  import WebLayout from "./WebLayout.svelte";

  const routes = [
    { path: "/", component: Home },
    { path: "/game", component: Game },
    { path: "/dao", component: Dao },
    { path: "/profile", component: UserProfile },
    { path: "/game-overview", component: GameOverview },
    { path: "/dao-overview", component: DAOOverview },
    { path: "/image-editor", component: ImageEditor },
    { path: "/content", component: Content },
    { path: "/about", component: About },
    { path: "*", component: NotFound },
  ];
</script>

<Router>
  {#each routes as route}
    <Route path={route.path}>
      {#if route.path === "/game"}
        <svelte:component this={route.component} />
      {:else}
        <WebLayout>
          <svelte:component this={route.component} />
        </WebLayout>
      {/if}
    </Route>
  {/each}
</Router>
