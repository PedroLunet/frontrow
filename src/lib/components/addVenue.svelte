<script lang="ts">
	import { PUBLIC_MAPBOX_TOKEN } from '$env/static/public';
	import { supabase } from '$lib/supabaseclient.js';
	import { Button } from '$lib/components/ui/button/index.js';

	let query = $state('');
	let suggestions = $state<any[]>([]);
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
			suggestions = [];
			return;
		}

		searchTimeout = setTimeout(async () => {
			isSearching = true;
			try {
				const res = await fetch(
					`https://api.mapbox.com/search/searchbox/v1/suggest?q=${encodeURIComponent(
						val
					)}&language=pt&country=pt&session_token=${sessionToken}&access_token=${PUBLIC_MAPBOX_TOKEN}&types=poi,address&limit=5`
				);
				const data = await res.json();
				suggestions = data.suggestions || [];
			} catch (err) {
				console.error('Failed to fetch suggestions:', err);
			} finally {
				isSearching = false;
			}
		}, 300);
	}

	async function selectAndSaveVenue(suggestion: any) {
		query = suggestion.name;
		suggestions = [];
		isSearching = true;

		try {
			const retrieveRes = await fetch(
				`https://api.mapbox.com/search/searchbox/v1/retrieve/${suggestion.mapbox_id}?session_token=${sessionToken}&access_token=${PUBLIC_MAPBOX_TOKEN}`
			);
			const retrieveData = await retrieveRes.json();

			const feature = retrieveData.features[0];
			const [lng, lat] = feature.geometry.coordinates;

			const wktCoordinates = `POINT(${lng} ${lat})`;

			const { data, error } = await supabase
				.from('venues')
				.insert({
					id: crypto.randomUUID(),
					name: suggestion.name,
					coordinates: wktCoordinates,
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

	{#if suggestions.length > 0}
		<ul>
			{#each suggestions as suggestion (suggestion.mapbox_id)}
				<li>
					<Button onclick={() => selectAndSaveVenue(suggestion)}>
						<strong>{suggestion.name}</strong> - {suggestion.place_formatted}
					</Button>
				</li>
			{/each}
		</ul>
	{/if}

	{#if savedVenue}
		<p>
			Successfully added <strong>{savedVenue.name}</strong>!
		</p>
	{/if}
</div>
