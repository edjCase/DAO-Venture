<script lang="ts">
  export let id: string;

  $: baseUrl =
    process.env.DFX_NETWORK === "ic"
      ? `https://${process.env.MAIN_CANISTER_ID}.ic0.app`
      : `http://${process.env.MAIN_CANISTER_ID}.localhost:${process.env.LOCAL_NETWORK_PORT}`;

  $: imageUrl = `${baseUrl}/images/${id}`;
</script>

<img src={imageUrl} alt={id} width="256" height="256" />
