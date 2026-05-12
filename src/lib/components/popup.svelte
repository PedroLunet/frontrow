<script lang="ts">
	import { MapPin } from 'lucide-svelte';

	let { concert } = $props();

	const formattedDate = new Date(concert.date).toLocaleDateString('en-US', {
		month: 'short',
		day: 'numeric',
		year: 'numeric'
	});
</script>

<div
	class="mb-4 flex min-w-64 flex-col overflow-hidden rounded-4xl border-2 border-accent bg-white font-sans text-gray-900"
>
	{#if concert.image_url}
		<img src={concert.image_url} alt={concert.name} class="h-38 rounded-4xl object-cover p-1.5" />
	{:else}
		<div class="flex h-32 w-full items-center justify-center bg-gray-200">
			<span class="text-gray-400">No image</span>
		</div>
	{/if}

	<div class="p-4 pt-1">
		<!-- <p class="mb-1 text-xs font-bold tracking-wider text-orange-500 uppercase">
			{formattedDate}
		</p> -->
		<h3 class="mb-1 text-base leading-tight font-bold tracking-tight text-primary uppercase">
			{concert.artist}
		</h3>
		<div class="mb-1 flex flex-row items-center gap-1 font-extralight">
			<MapPin size={16} class="text-primary" />
			<p class="text-sm text-text">{concert.venues?.name}</p>
		</div>
		<p class="mb-1 text-sm leading-tight font-extralight tracking-tight text-text">
			{concert.description}
		</p>

		<button
			class="mt-4 w-full rounded-md bg-black py-2 text-sm font-medium text-white transition-colors hover:bg-gray-800"
		>
			View Details
		</button>
	</div>
</div>
