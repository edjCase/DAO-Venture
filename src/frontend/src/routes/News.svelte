<script lang="ts">
    import type { Article } from "../types/News";
    let articles: Article[] = [
        {
            id: 1,
            title: "Article 1",
            text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam laoreet nunc ultrices, rutrum lacus at, venenatis sem. Donec dictum turpis eget leo tempus, nec dictum massa tempor. Integer blandit mattis augue, eu aliquam tellus porttitor quis. Aenean efficitur, nunc eget condimentum rhoncus, orci nisi blandit sem, vitae condimentum tellus ligula commodo lacus. Duis id massa semper, laoreet lorem ut, bibendum quam. Fusce at orci id sem efficitur pretium sed ac nunc. Sed est dui, cursus sed leo at, euismod sollicitudin eros. Curabitur eleifend in magna at venenatis. Quisque a augue sagittis, sollicitudin lacus nec, pharetra quam. Cras eu pharetra purus, ac pharetra elit. In venenatis cursus scelerisque.\n\nNam condimentum tincidunt congue. Cras sodales finibus dignissim. Vestibulum mollis metus non dolor porttitor egestas ac at nunc. Pellentesque eget accumsan nunc. Fusce id elementum elit, ut faucibus erat. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Nullam vulputate tempor lectus vitae cursus. Praesent sem ante, sodales sed molestie eu, bibendum malesuada massa. Morbi scelerisque metus consectetur, auctor tortor vel, elementum libero.",
        },
        {
            id: 2,
            title: "Article 2",
            text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam laoreet nunc ultrices, rutrum lacus at, venenatis sem. Donec dictum turpis eget leo tempus, nec dictum massa tempor. Integer blandit mattis augue, eu aliquam tellus porttitor quis. Aenean efficitur, nunc eget condimentum rhoncus, orci nisi blandit sem, vitae condimentum tellus ligula commodo lacus. Duis id massa semper, laoreet lorem ut, bibendum quam. Fusce at orci id sem efficitur pretium sed ac nunc. Sed est dui, cursus sed leo at, euismod sollicitudin eros. Curabitur eleifend in magna at venenatis. Quisque a augue sagittis, sollicitudin lacus nec, pharetra quam. Cras eu pharetra purus, ac pharetra elit. In venenatis cursus scelerisque.\n\nNam condimentum tincidunt congue. Cras sodales finibus dignissim. Vestibulum mollis metus non dolor porttitor egestas ac at nunc. Pellentesque eget accumsan nunc. Fusce id elementum elit, ut faucibus erat. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Nullam vulputate tempor lectus vitae cursus. Praesent sem ante, sodales sed molestie eu, bibendum malesuada massa. Morbi scelerisque metus consectetur, auctor tortor vel, elementum libero.",
        },
    ];
</script>

<div class="news">
    <h1>News</h1>
    {#each articles as article}
        <div class="article">
            <h2>{article.title}</h2>
            <p>{article.text}</p>
        </div>
    {/each}
</div>

<style>
    .news {
        margin: auto;
        max-width: 800px;
        text-align: center;
    }
    .article {
        margin-bottom: 50px;
        text-align: left;
    }
</style>
