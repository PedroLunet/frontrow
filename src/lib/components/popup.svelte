<script lang="ts">
	let { concert } = $props();

	const formattedDate = new Date(concert.date).toLocaleDateString('en-US', {
		month: 'short',
		day: 'numeric',
		year: 'numeric'
	});
</script>

<div
	class="flex w-64 flex-col overflow-hidden rounded-lg bg-white font-sans text-gray-900 shadow-sm"
>
	{#if concert.image_url}
		<img src={concert.image_url} alt={concert.name} class="h-32 w-full object-cover" />
	{:else}
		<div class="flex h-32 w-full items-center justify-center bg-gray-200">
			<span class="text-gray-400">No image</span>
		</div>
	{/if}

	<div class="p-4">
		<p class="mb-1 text-xs font-bold tracking-wider text-orange-500 uppercase">
			{formattedDate}
		</p>
		<h3 class="mb-1 text-lg leading-tight font-bold text-black">{concert.artist}</h3>
		<p class="text-sm text-gray-500">{concert.venues?.name}</p>

		<button
			class="mt-4 w-full rounded-md bg-black py-2 text-sm font-medium text-white transition-colors hover:bg-gray-800"
		>
			View Details
		</button>
	</div>
</div>
