<script lang="ts">
	import Map from '$lib/components/Map.svelte';
	import Header from '$lib/components/Header.svelte';
</script>

<main class="flex h-screen w-full flex-col">
	<Header />
	<div class="h-full w-full p-6 pt-2">
		<Map />
	</div>
</main>
