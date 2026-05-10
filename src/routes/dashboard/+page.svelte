<script lang="ts">
	import { onMount } from 'svelte';
	import { supabase } from '$lib/supabaseclient.js';
	import { goto } from '$app/navigation';

	let userEmail = $state('Loading...');

	onMount(async () => {
		const { data } = await supabase.auth.getUser();
		if (data.user) {
			userEmail = data.user.email || 'Unknown Email';
		} else {
			goto('/login');
		}
	});

	async function handleLogout() {
		await supabase.auth.signOut();
	}
</script>

<main class="mx-auto my-12 max-w-2xl px-4 font-sans text-gray-900">
	<div class="rounded-xl border border-gray-200 bg-white p-8 shadow-sm">
		<h1 class="mb-2 text-3xl font-bold tracking-tight">Your Dashboard</h1>
		<p class="mb-8 text-gray-500">
			You are securely logged in as <span class="font-bold text-black">{userEmail}</span>
		</p>

		<div class="rounded-lg border border-gray-100 bg-gray-50 p-6 text-center">
			<p class="mb-4 text-sm text-gray-400">More features coming soon...</p>

			<button
				onclick={handleLogout}
				class="rounded-lg border border-red-200 bg-red-50 px-6 py-2 font-medium text-red-600 transition-colors hover:bg-red-100 focus:ring-2 focus:ring-red-500 focus:ring-offset-2 focus:outline-none"
			>
				Log Out
			</button>
		</div>
	</div>
</main>
