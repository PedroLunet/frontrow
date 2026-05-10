<script lang="ts">
	import Map from '$lib/components/map.svelte';
	import Header from '$lib/components/header.svelte';
	import { onMount } from 'svelte';
	import { supabase } from '$lib/supabaseclient.js';

	let concerts = $state<any[]>([]);

	onMount(async () => {
		const { data, error } = await supabase
			.from('concerts')
			.select('*, venues(id, name, coordinates)');

		if (error) {
			console.error('🚨 Error fetching concerts:', error);
		} else {
			concerts = data || [];
		}
	});
</script>

<main class="flex h-screen w-full flex-col">
	<Header />
	<div class="h-full w-full p-6 pt-2">
		<Map {concerts} />
	</div>
</main>
