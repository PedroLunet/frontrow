<script lang="ts">
	import Popup from './popup.svelte';

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
	<div
		class="flex items-center justify-between rounded-t-4xl border-b border-gray-200 bg-gray-50 px-3 py-2"
	>
		<button
			onclick={prev}
			disabled={currentIndex === 0}
			aria-label="Previous concert"
			class="flex h-7 w-7 cursor-pointer items-center justify-center rounded-lg border border-gray-300 bg-white text-gray-600 transition-colors hover:bg-gray-100 disabled:cursor-not-allowed disabled:opacity-40"
		>
			<svg
				width="14"
				height="14"
				viewBox="0 0 24 24"
				fill="none"
				stroke="currentColor"
				stroke-width="2.5"
			>
				<path d="M15 18l-6-6 6-6" />
			</svg>
		</button>

		<span class="text-xs font-medium text-gray-600">
			{currentIndex + 1} / {concerts.length}
		</span>

		<button
			onclick={next}
			disabled={currentIndex === concerts.length - 1}
			aria-label="Next concert"
			class="flex h-7 w-7 cursor-pointer items-center justify-center rounded-lg border border-gray-300 bg-white text-gray-600 transition-colors hover:bg-gray-100 disabled:cursor-not-allowed disabled:opacity-40"
		>
			<svg
				width="14"
				height="14"
				viewBox="0 0 24 24"
				fill="none"
				stroke="currentColor"
				stroke-width="2.5"
			>
				<path d="M9 18l6-6-6-6" />
			</svg>
		</button>
	</div>

	<Popup concert={currentConcert} {closePopup} {user} />
</div>
