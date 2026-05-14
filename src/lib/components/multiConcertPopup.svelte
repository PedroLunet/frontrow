<script lang="ts">
	import Popup from './popup.svelte';
	import { ChevronLeft, ChevronRight } from 'lucide-svelte';

	let { concerts, closePopup, user = null } = $props();

	let currentIndex = $state(0);

	function next() {
		if (currentIndex < concerts.length - 1) {
			currentIndex++;
		}
	}

	function prev() {
		if (currentIndex > 0) {
			currentIndex--;
		}
	}

	let currentConcert = $derived(concerts[currentIndex]);
</script>

<div class="flex w-64 flex-col">
	<div class="relative z-10 drop-shadow-lg">
		<Popup concert={currentConcert} {closePopup} {user} />
	</div>

	<div
		class="relative z-0 -mt-8.5 flex items-center justify-between rounded-b-3xl border-2 border-text-white bg-gray-50/90 px-6 pt-10 pb-2"
	>
		<button
			onclick={prev}
			disabled={currentIndex === 0}
			aria-label="Previous concert"
			class="flex aspect-square h-7 cursor-pointer items-center justify-center rounded-lg border border-gray-300 bg-white text-primary transition-colors hover:bg-gray-100 active:scale-95 disabled:cursor-not-allowed disabled:opacity-60"
		>
			<ChevronLeft size={14} strokeWidth={2.5} />
		</button>

		<div class="flex flex-col items-center justify-center gap-1.5">
			<span
				class="text-[10px] leading-none font-bold tracking-widest text-gray-400 uppercase tabular-nums"
			>
				{currentIndex + 1} / {concerts.length}
			</span>

			<div class="flex items-center gap-1">
				{#each concerts as concert, i (concert)}
					<div
						class="h-1.5 rounded-full transition-all duration-500 ease-[cubic-bezier(0.2,0.8,0.2,1)]
            {i === currentIndex ? 'w-4 bg-primary' : 'w-1.5 bg-gray-300'}"
					></div>
				{/each}
			</div>
		</div>

		<button
			onclick={next}
			disabled={currentIndex === concerts.length - 1}
			aria-label="Next concert"
			class="flex aspect-square h-7 cursor-pointer items-center justify-center rounded-lg border border-gray-300 bg-white text-primary transition-colors hover:bg-gray-100 active:scale-95 disabled:cursor-not-allowed disabled:opacity-60"
		>
			<ChevronRight size={14} strokeWidth={2.5} />
		</button>
	</div>
</div>
