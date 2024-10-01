<script lang="ts">
  export let entity: { id: string; name: string; description: string };
</script>

<div class="text-primary-500">Id</div>
<div>{entity.id}</div>
<div class="text-primary-500">Name</div>
<div>{entity.name}</div>
<div class="text-primary-500">Description</div>
<div>{entity.description}</div>
