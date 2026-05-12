<script lang="ts">
	import { MapPin, X, Ticket, CheckCircle2 } from 'lucide-svelte';

	let { concert, closePopup } = $props();

	let isGoing = $state(false);

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
		<div class="relative overflow-hidden p-1.5">
			<img
				src={concert.image_url}
				alt={concert.name}
				class="h-32 w-full rounded-4xl object-cover"
			/>

			<button
				onclick={closePopup}
				aria-label="Close"
				class="absolute top-4 right-4 flex h-7 w-7 cursor-pointer items-center justify-center overflow-hidden rounded-xl border-[0.5px] border-white/20 bg-text/60 shadow-xl backdrop-blur-md transition-all hover:scale-105 hover:bg-text/80 active:scale-95"
			>
				<div
					class="pointer-events-none absolute inset-0 bg-linear-to-tr from-white/5 to-white/20"
				></div>
				<X size={14} strokeWidth={3} class="relative z-10 text-text-white" />
			</button>

			<div
				class="absolute right-4 bottom-4 overflow-hidden rounded-2xl border-[0.5px] border-white/20 bg-text/60 px-2.5 py-1.5 shadow-xl backdrop-blur-md"
			>
				<div
					class="pointer-events-none absolute inset-0 bg-linear-to-tr from-white/5 to-white/20"
				></div>
				<p class="relative z-10 text-xs text-text-white">
					{formattedDate}
				</p>
			</div>
		</div>
	{/if}

	<div class="p-4 pt-1">
		<h3 class="mb-1 text-base leading-tight font-bold tracking-tight text-primary uppercase">
			{concert.artist}
		</h3>
		<div class="mb-2 flex flex-row items-center gap-1 font-extralight">
			<MapPin size={16} class="text-primary" />
			<p class="text-sm text-text">{concert.venues?.name}</p>
		</div>
		<p class="mb-4 text-sm leading-tight font-extralight tracking-tight text-text">
			{concert.description}
		</p>

		<button
			onclick={() => (isGoing = !isGoing)}
			class="group mt-2 flex w-full items-center justify-center gap-2 rounded-xl py-2 text-sm font-light transition-all duration-300 focus:outline-none
        {isGoing
				? 'border border-primary bg-primary text-white'
				: 'border border-primary text-primary'}"
		>
			{#if isGoing}
				<CheckCircle2 size={18} class="animate-in zoom-in duration-300" />
				<span>You're Going!</span>
			{:else}
				<Ticket size={18} class="transition-transform duration-300 group-hover:-rotate-12" />
				<span>Mark as Going</span>
			{/if}
		</button>
	</div>
</div>
