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
			class="group relative mt-2 flex h-[40px] w-full cursor-pointer overflow-hidden rounded-xl border border-primary text-sm font-light transition-colors duration-300 focus:outline-none
				{isGoing ? 'bg-primary text-white shadow-sm' : 'bg-transparent text-primary hover:bg-primary/5'}"
		>
			<div
				class="absolute inset-0 flex items-center justify-center gap-2 transition-all duration-300 {isGoing
					? 'scale-95 opacity-0'
					: 'scale-100 opacity-100 delay-75'}"
			>
				<Ticket size={18} class="transition-transform duration-300 group-hover:-rotate-12" />
				<span>Mark as Going</span>
			</div>

			<div
				class="absolute inset-0 flex items-center justify-center gap-2 transition-all duration-300 {isGoing
					? 'scale-100 opacity-100 delay-75'
					: 'scale-105 opacity-0'}"
			>
				<CheckCircle2 size={18} />
				<span>You're Going!</span>
			</div>
		</button>
	</div>
</div>
