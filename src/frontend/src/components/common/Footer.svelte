<script>
  import {
    Footer,
    FooterCopyright,
    FooterLinkGroup,
    FooterLink,
    FooterBrand,
    FooterIcon,
  } from "flowbite-svelte";
  import {
    FacebookSolid,
    GithubSolid,
    DiscordSolid,
    TwitterSolid,
  } from "flowbite-svelte-icons";
</script>

<div class="mt-12">
  <Footer footerType="socialmedia">
    <div class="flex justify-between">
      <FooterCopyright
        href="https://edjcase.com"
        by="Edjcase"
        copyrightMessage=""
      />
      <div class="flex gap-5">
        <FooterIcon href="https://github.com/edjCase/daoball">
          <TwitterSolid
            class="w-4 h-4 text-gray-500 dark:text-gray-500 hover:text-gray-900 dark:hover:text-white"
          />
        </FooterIcon>
        <FooterIcon href="https://github.com/edjCase/daoball">
          <GithubSolid
            class="w-4 h-4 text-gray-500 dark:text-gray-500 hover:text-gray-900 dark:hover:text-white"
          />
        </FooterIcon>
      </div>
    </div>
  </Footer>
</div>
