<script lang="ts">
	import Popup from './popup.svelte';
	import { ChevronLeft, ChevronRight } from 'lucide-svelte';
	import { Button } from '$lib/components/ui/button/index.js';

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
		class="border-text-white relative z-0 -mt-8.5 flex items-center justify-between rounded-b-3xl border-2 bg-gray-50/90 px-6 pt-10 pb-2"
	>
		<Button onclick={prev} disabled={currentIndex === 0} aria-label="Previous concert">
			<ChevronLeft size={14} strokeWidth={2.5} />
		</Button>

		<div class="flex flex-col items-center justify-center gap-1.5">
			<span
				class="text-[10px] leading-none font-bold tracking-widest text-gray-400 uppercase tabular-nums"
			>
				{currentIndex + 1} / {concerts.length}
			</span>

			<div class="flex items-center gap-1">
				{#each concerts as concert, i (concert.id)}
					<div
						class="h-1.5 rounded-full transition-all duration-500 ease-[cubic-bezier(0.2,0.8,0.2,1)]
            {i === currentIndex ? 'w-4 bg-primary' : 'w-1.5 bg-gray-300'}"
					></div>
				{/each}
			</div>
		</div>

		<Button
			onclick={next}
			disabled={currentIndex === concerts.length - 1}
			aria-label="Next concert"
		>
			<ChevronRight size={14} strokeWidth={2.5} />
		</Button>
	</div>
</div>
