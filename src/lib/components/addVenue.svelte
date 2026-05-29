<script lang="ts">
	import { PUBLIC_MAPBOX_TOKEN } from '$env/static/public';
	import { supabase } from '$lib/supabaseclient.js';
	import { Button } from '$lib/components/ui/button/index.js';

	interface Props {
		venueSelect?: (venue: { id: string; name: string }) => void;
	}

	let { venueSelect }: Props = $props();

	let query = $state('');
	let dbSuggestions = $state<any[]>([]);
	let mapboxSuggestions = $state<any[]>([]);
	let isSearching = $state(false);
	let savedVenue = $state<any>(null);

	let sessionToken = $state(crypto.randomUUID());
	let searchTimeout: ReturnType<typeof setTimeout>;

	function handleInput(e: Event) {
		const val = (e.target as HTMLInputElement).value;
		query = val;
		savedVenue = null;

		clearTimeout(searchTimeout);

		if (val.length < 3) {
			dbSuggestions = [];
			mapboxSuggestions = [];
			return;
		}

		searchTimeout = setTimeout(async () => {
			isSearching = true;

			try {
				const [dbRes, mapboxRes] = await Promise.all([
					supabase.from('venues').select('*').ilike('name', `%${val}%`).limit(3),
					fetch(
						`https://api.mapbox.com/search/searchbox/v1/suggest?q=${encodeURIComponent(
							val
						)}&language=pt&country=pt&session_token=${sessionToken}&access_token=${PUBLIC_MAPBOX_TOKEN}&types=poi,address&limit=5`
					).then((r) => r.json())
				]);

				dbSuggestions = dbRes.data || [];
				const dbMapboxIds = dbSuggestions.map((v) => v.mapbox_id);
				mapboxSuggestions = (mapboxRes.suggestions || []).filter(
					(mb: any) => !dbMapboxIds.includes(mb.mapbox_id)
				);
			} catch (err) {
				console.error('Search failed:', err);
			} finally {
				isSearching = false;
			}
		}, 300);
	}

	function selectExistingVenue(venue: any) {
		query = venue.name;
		dbSuggestions = [];
		mapboxSuggestions = [];
		savedVenue = venue;
		venueSelect?.({ id: venue.id, name: venue.name });
	}

	async function selectAndSaveVenue(suggestion: any) {
		query = suggestion.name;
		dbSuggestions = [];
		mapboxSuggestions = [];
		isSearching = true;

		try {
			const retrieveRes = await fetch(
				`https://api.mapbox.com/search/searchbox/v1/retrieve/${suggestion.mapbox_id}?session_token=${sessionToken}&access_token=${PUBLIC_MAPBOX_TOKEN}`
			);
			const retrieveData = await retrieveRes.json();
			const feature = retrieveData.features[0];
			const [lng, lat] = feature.geometry.coordinates;

			const { data, error } = await supabase
				.from('venues')
				.insert({
					id: crypto.randomUUID(),
					name: suggestion.name,
					coordinates: `POINT(${lng} ${lat})`,
					mapbox_id: suggestion.mapbox_id,
					created_at: new Date().toISOString()
				})
				.select()
				.single();

			if (error) {
				console.error('Supabase error:', error);
				alert('Failed to save venue. Check console.');
			} else {
				savedVenue = data;
				sessionToken = crypto.randomUUID();
				venueSelect?.({ id: data.id, name: data.name });
			}
		} catch (err) {
			console.error('Failed to retrieve or save venue:', err);
		} finally {
			isSearching = false;
		}
	}
</script>

<div>
	<div>
		{#if isSearching}
			<span>(Searching...)</span>
		{/if}
		<input
			type="text"
			bind:value={query}
			oninput={handleInput}
			placeholder="Search for a venue..."
		/>
	</div>

	{#if dbSuggestions.length > 0}
		<ul>
			{#each dbSuggestions as venue (venue.id)}
				<li>
					<Button onclick={() => selectExistingVenue(venue)}>
						<strong>{venue.name}</strong> (saved)
					</Button>
				</li>
			{/each}
		</ul>
	{/if}

	{#if mapboxSuggestions.length > 0}
		<ul>
			{#each mapboxSuggestions as suggestion (suggestion.mapbox_id)}
				<li>
					<Button onclick={() => selectAndSaveVenue(suggestion)}>
						<strong>{suggestion.name}</strong> - {suggestion.place_formatted}
					</Button>
				</li>
			{/each}
		</ul>
	{/if}

	{#if savedVenue && !venueSelect}
		<p>Successfully added <strong>{savedVenue.name}</strong>!</p>
	{/if}
</div>
