<script lang="ts">
  export let id: string;

  $: baseUrl =
    process.env.DFX_NETWORK === "ic"
      ? `https://${process.env.MAIN_CANISTER_ID}.ic0.app`
      : `http://localhost:${process.env.LOCAL_NETWORK_PORT}`;

  $: imageUrl = `${baseUrl}/images/${id}.png`;
</script>

<img src={imageUrl} alt={id} />
