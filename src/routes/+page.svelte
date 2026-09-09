<script lang="ts">
	import Map from '$lib/components/map.svelte';
	import Header from '$lib/components/header.svelte';
	import { onMount } from 'svelte';
	import { supabase } from '$lib/supabaseclient.js';
	import { userRsvpsStore } from '$lib/stores.js';

	let concerts = $state<any[]>([]);
	let user = $state<any>(null);

	onMount(async () => {
		const {
			data: { user: currentUser }
		} = await supabase.auth.getUser();
		user = currentUser;

		const { data, error } = await supabase
			.from('concerts')
			.select('*, venues(id, name, coordinates)');

		if (error) {
			console.error('Error fetching concerts:', error);
		} else {
			concerts = data || [];
		}

		if (user) {
			const { data: rsvps } = await supabase
				.from('user_concerts')
				.select('concert_id')
				.eq('user_id', user.id);

			if (rsvps) {
				const map: Record<string, boolean> = {};
				for (const r of rsvps) {
					map[r.concert_id] = true;
				}
				userRsvpsStore.set(map);
			}
		}
	});
</script>

<main class="flex h-screen w-full flex-col">
	<Header />
	<div class="h-full w-full p-6 pt-2">
		<Map {concerts} {user} />
	</div>
</main>
