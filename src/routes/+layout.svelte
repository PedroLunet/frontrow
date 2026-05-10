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

			const currentPath = window.location.pathname;

			if (event === 'SIGNED_IN' && currentPath === '/login') {
				goto('/');
			} else if (event === 'SIGNED_OUT') {
				if (currentPath !== '/' && currentPath !== '/login') {
					goto('/');
				}
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
