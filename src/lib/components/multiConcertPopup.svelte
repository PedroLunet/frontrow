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

<div class="flex w-fit flex-col">
	<div class="relative z-10 drop-shadow-md">
		<Popup concert={currentConcert} {closePopup} {user} />
	</div>

	<div
		class="relative z-0 -mt-8 flex items-center justify-between rounded-b-3xl border-2 border-text-white bg-white px-6 pt-10 pb-3"
	>
		<button
			onclick={prev}
			disabled={currentIndex === 0}
			aria-label="Previous concert"
			class="flex aspect-square h-7 cursor-pointer items-center justify-center rounded-lg border border-gray-300 bg-white text-primary transition-colors hover:bg-gray-100 active:scale-95 disabled:cursor-not-allowed disabled:opacity-60"
		>
			<ChevronLeft size={14} strokeWidth={2.5} />
		</button>

		<span class="text-xs font-medium text-text tabular-nums">
			{currentIndex + 1} / {concerts.length}
		</span>

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
