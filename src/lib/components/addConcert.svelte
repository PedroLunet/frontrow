<script lang="ts">
	import { PUBLIC_MAPBOX_TOKEN } from '$env/static/public';
	import { supabase } from '$lib/supabaseclient.js';
	import { Button } from '$lib/components/ui/button/index.js';

	interface Props {
		onSuccess?: () => void;
	}

	let { onSuccess }: Props = $props();

	// --- CONCERT FORM STATE ---
	let artist = $state('');
	let concertName = $state(''); // Maps to 'name' in DB
	let date = $state(''); // YYYY-MM-DD
	let time = $state(''); // HH:MM
	let description = $state('');
	let imageUrl = $state('');

	// --- VENUE SEARCH STATE ---
	let venueQuery = $state('');
	let dbSuggestions = $state<any[]>([]);
	let mapboxSuggestions = $state<any[]>([]);
	let isSearching = $state(false);
	let selectedVenueId = $state<string | null>(null);
	let selectedVenueName = $state('');

	let sessionToken = $state(crypto.randomUUID());
	let searchTimeout: ReturnType<typeof setTimeout>;
	let isSubmitting = $state(false);

	function handleVenueInput(e: Event) {
		const val = (e.target as HTMLInputElement).value;
		venueQuery = val;
		selectedVenueId = null;

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
					).then((res) => res.json())
				]);

				dbSuggestions = dbRes.data || [];

				const dbMapboxIds = dbSuggestions.map((dbVenue) => dbVenue.mapbox_id);
				const rawMapboxSuggestions = mapboxRes.suggestions || [];

				mapboxSuggestions = rawMapboxSuggestions.filter(
					(mb) => !dbMapboxIds.includes(mb.mapbox_id)
				);
			} catch (err) {
				console.error('Search failed:', err);
			} finally {
				isSearching = false;
			}
		}, 300);
	}

	async function selectVenue(type: 'db' | 'mapbox', suggestion: any) {
		if (type === 'db') {
			selectedVenueId = suggestion.id;
			selectedVenueName = suggestion.name;
			venueQuery = suggestion.name;
			dbSuggestions = [];
			mapboxSuggestions = [];
		} else {
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

				if (error) throw error;

				selectedVenueId = data.id;
				selectedVenueName = data.name;
				venueQuery = data.name;
				sessionToken = crypto.randomUUID();
				dbSuggestions = [];
				mapboxSuggestions = [];
			} catch (err) {
				console.error('Failed to create new venue:', err);
				alert('Could not save venue.');
			} finally {
				isSearching = false;
			}
		}
	}

	async function handleSubmit(e: Event) {
		e.preventDefault();
		if (!selectedVenueId) {
			alert('Please select a valid venue from the list.');
			return;
		}

		isSubmitting = true;

		const datetimeStr = `${date}T${time}:00`;
		const concertTimestamp = new Date(datetimeStr).toISOString();
		const now = new Date().toISOString();

		const { error } = await supabase.from('concerts').insert({
			id: crypto.randomUUID(),
			artist: artist,
			name: concertName,
			venue: selectedVenueId,
			date: concertTimestamp,
			description: description,
			image_url: imageUrl,
			created_at: now,
			updated_at: now
		});

		isSubmitting = false;

		if (error) {
			console.error('Failed to save concert:', error);
			alert('Error saving concert.');
		} else {
			alert('Concert successfully added!');
			onSuccess?.();
		}
	}
</script>

<form onsubmit={handleSubmit}>
	<fieldset disabled={isSubmitting}>
		<br />

		<div>
			<label for="artist">Artist (Required)</label>
			<input id="artist" type="text" bind:value={artist} required />
		</div>

		<div>
			<label for="name">Tour / Event Name (Optional)</label>
			<input id="name" type="text" bind:value={concertName} />
		</div>

		<div>
			<label for="date">Date</label>
			<input id="date" type="date" bind:value={date} required />
		</div>

		<div>
			<label for="time">Time</label>
			<input id="time" type="time" bind:value={time} required />
		</div>

		<div>
			<label for="imageUrl">Image URL</label>
			<input id="imageUrl" type="url" bind:value={imageUrl} required />
		</div>

		<div>
			<label for="description">Description</label>
			<textarea id="description" bind:value={description} rows="4"></textarea>
		</div>

		<br />

		<Button type="submit">
			{isSubmitting ? 'Saving...' : 'Add Concert'}
		</Button>
	</fieldset>
</form>
