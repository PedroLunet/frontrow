<script lang="ts">
	import { onMount } from 'svelte';
	import { supabase } from '$lib/supabaseclient.js';
	import Map from '$lib/components/Map.svelte';

	let userEmail = $state<string | null>(null);

	onMount(async () => {
		const { data } = await supabase.auth.getUser();
		if (data.user) {
			userEmail = data.user.email || null;
		}
	});

	async function handleLogout() {
		await supabase.auth.signOut();
		userEmail = null;
	}
</script>

<main class="flex h-screen w-full flex-col bg-gray-100">
	<nav class="relative z-10 flex items-center justify-between bg-white px-6 py-4 shadow-sm">
		<h1 class="text-xl font-bold tracking-tight text-black">FrontRow</h1>

		<div>
			{#if userEmail}
				<div class="flex items-center gap-4">
					<span class="hidden text-sm text-gray-600 sm:inline">{userEmail}</span>
					<button
						onclick={handleLogout}
						class="text-sm font-medium text-red-600 transition-colors hover:text-red-800"
					>
						Log Out
					</button>
				</div>
			{:else}
				<a
					href="/login"
					class="rounded-lg bg-black px-4 py-2 text-sm font-medium text-white transition-all hover:bg-gray-800"
				>
					Log In
				</a>
			{/if}
		</div>
	</nav>

	<div class="h-full w-full p-8">
		<Map />
	</div>
</main>
