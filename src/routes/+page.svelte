<script lang="ts">
	import Map from '$lib/components/map.svelte';
	import Header from '$lib/components/header.svelte';
	import { onMount } from 'svelte';
	import { supabase } from '$lib/supabaseclient.js';

	let venues = $state<any[]>([]);

	onMount(async () => {
		const { data, error } = await supabase.from('venues').select('*');

		if (error) {
			console.error('🚨 Error fetching venues:', error);
		} else {
			venues = data || [];
			console.log('📍 Venues loaded:', venues);
		}
	});
</script>

<main class="flex h-screen w-full flex-col">
	<Header />
	<div class="h-full w-full p-6 pt-2">
		<Map {venues} />
	</div>
</main>
