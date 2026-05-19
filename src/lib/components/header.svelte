<script lang="ts">
	import { onMount } from 'svelte';
	import { supabase } from '$lib/supabaseclient.js';
	import { Dialog } from 'bits-ui';
	import { X } from 'lucide-svelte';
	import AddConcert from './addConcert.svelte';
	import { Button } from '$lib/components/ui/button/index.js';

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

<nav class="relative z-10 flex items-center justify-between px-6 py-4">
	<h1 class="text-xl font-bold tracking-tight text-black">FrontRow</h1>

	<div>
		{#if userEmail}
    <span class="hidden text-sm text-gray-600 sm:inline">{userEmail}</span>
			<Button
				variant="outline"
				onclick={handleLogout}
				class="text-red-600 transition-colors hover:text-red-800"
			>
				Log Out
			</Button>
		{:else}
			<Button href="/login">Log In</Button>
		{/if}
	</div>
</nav>
