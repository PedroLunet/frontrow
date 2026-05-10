<script lang="ts">
	import './layout.css';
	import favicon from '$lib/assets/favicon.svg';
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';
	import { supabase } from '$lib/supabaseclient.js';

	let { children } = $props();

	let session = $state<any>(null);
	let loading = $state(true);

	onMount(() => {
		supabase.auth.getSession().then(({ data }) => {
			session = data.session;
			loading = false;
		});

		const {
			data: { subscription }
		} = supabase.auth.onAuthStateChange((event, newSession) => {
			session = newSession;

			if (event === 'SIGNED_IN') {
				goto('/dashboard');
			} else if (event === 'SIGNED_OUT') {
				goto('/login'); // Assuming your login page is at /login
			}
		});

		return () => subscription.unsubscribe();
	});
</script>

{#if loading}
	<div class="flex h-screen items-center justify-center bg-gray-50">
		<p class="font-medium text-gray-500">Loading FrontRow...</p>
	</div>
{:else}
	{@render children()}
{/if}
