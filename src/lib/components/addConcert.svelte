<script lang="ts">
	import { PUBLIC_MAPBOX_TOKEN } from '$env/static/public';
	import { supabase } from '$lib/supabaseclient.js';
	import { Button } from '$lib/components/ui/button/index.js';
	import { Input } from '$lib/components/ui/input/index.js';
	import * as Form from '$lib/components/ui/form/index.js';
	import { concertFormSchema, type ConcertFormSchema } from '$lib/schemas/concertSchema';
	import { defaults, superForm } from 'sveltekit-superforms';
	import { zod4 } from 'sveltekit-superforms/adapters';
	import { toast } from 'svelte-sonner';
  import { Dialog } from 'bits-ui';

	interface Props {
		onSuccess?: () => void;
	}

	let { onSuccess }: Props = $props();

	// --- VENUE SEARCH STATE ---
	let venueQuery = $state('');
	let dbSuggestions = $state<any[]>([]);
	let mapboxSuggestions = $state<any[]>([]);
	let isSearching = $state(false);
	let selectedVenueId = $state<string | null>(null);
	let selectedVenueName = $state('');

	let sessionToken = $state(crypto.randomUUID());
	let searchTimeout: ReturnType<typeof setTimeout>;

	const form = superForm(defaults(zod4(concertFormSchema)), {
		validators: zod4(concertFormSchema),
		SPA: true,
		onUpdate: async ({ form: f }) => {
			if (!f.valid) {
				toast.error('Please fix the errors in the form.');
				return;
			}

			if (!selectedVenueId) {
				toast.error('Please select a valid venue from the list.');
				return;
			}

			try {
				const datetimeStr = `${f.data.date}T${f.data.time}:00`;
				const concertTimestamp = new Date(datetimeStr).toISOString();
				const now = new Date().toISOString();

				const { error } = await supabase.from('concerts').insert({
					id: crypto.randomUUID(),
					artist: f.data.artist,
					name: f.data.concertName,
					venue: selectedVenueId,
					date: concertTimestamp,
					description: f.data.description,
					image_url: f.data.imageUrl,
					created_at: now,
					updated_at: now
				});

				if (error) throw error;

				toast.success('Concert successfully added!');
				form.reset();
				selectedVenueId = null;
				selectedVenueName = '';
				venueQuery = '';
				onSuccess?.();
			} catch (err) {
				console.error('Failed to save concert:', err);
				toast.error('Error saving concert.');
			}
		}
	});

	const { form: formData, enhance, submitting } = form;

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
				toast.error('Could not save venue.');
			} finally {
				isSearching = false;
			}
		}
	}
</script>

<form method="POST" use:enhance class="space-y-6">
	<Form.Field {form} name="artist">
		<Form.Control>
			{#snippet children({ props })}
				<Form.Label>Artist (Required)</Form.Label>
				<Input
					{...props}
					type="text"
					bind:value={$formData.artist}
					placeholder="Enter artist name"
				/>
			{/snippet}
		</Form.Control>
		<Form.Description>The name of the artist performing</Form.Description>
		<Form.FieldErrors />
	</Form.Field>

	<Form.Field {form} name="concertName">
		<Form.Control>
			{#snippet children({ props })}
				<Form.Label>Tour / Event Name (Optional)</Form.Label>
				<Input
					{...props}
					type="text"
					bind:value={$formData.concertName}
					placeholder="Enter tour or event name"
				/>
			{/snippet}
		</Form.Control>
		<Form.Description>Give the concert a specific tour or event name</Form.Description>
		<Form.FieldErrors />
	</Form.Field>

	<Form.Field {form} name="date">
		<Form.Control>
			{#snippet children({ props })}
				<Form.Label>Date (Required)</Form.Label>
				<Input {...props} type="date" bind:value={$formData.date} />
			{/snippet}
		</Form.Control>
		<Form.FieldErrors />
	</Form.Field>

	<Form.Field {form} name="time">
		<Form.Control>
			{#snippet children({ props })}
				<Form.Label>Time (Required)</Form.Label>
				<Input {...props} type="time" bind:value={$formData.time} />
			{/snippet}
		</Form.Control>
		<Form.FieldErrors />
	</Form.Field>

	<Form.Field {form} name="imageUrl">
		<Form.Control>
			{#snippet children({ props })}
				<Form.Label>Image URL (Required)</Form.Label>
				<Input
					{...props}
					type="url"
					bind:value={$formData.imageUrl}
					placeholder="https://example.com/image.jpg"
				/>
			{/snippet}
		</Form.Control>
		<Form.Description>Concert poster or artist image</Form.Description>
		<Form.FieldErrors />
	</Form.Field>

	<Form.Field {form} name="description">
		<Form.Control>
			{#snippet children({ props })}
				<Form.Label>Description (Optional)</Form.Label>
				<textarea
					{...props}
					bind:value={$formData.description}
					placeholder="Enter concert details and description"
					rows="4"
					class="flex min-h-[80px] w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 focus-visible:outline-none disabled:cursor-not-allowed disabled:opacity-50"
				></textarea>
			{/snippet}
		</Form.Control>
		<Form.FieldErrors />
	</Form.Field>

	<!-- Venue Selection Field -->
	<div class="space-y-2">
		<label
			for="venue"
			class="text-sm leading-none font-medium peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
		>
			Venue (Required)
		</label>
		<div class="relative">
			<Input
				id="venue"
				type="text"
				value={venueQuery}
				onchange={handleVenueInput}
				oninput={handleVenueInput}
				placeholder="Search for a venue..."
				class="w-full"
			/>
			{#if isSearching}
				<div class="absolute top-1/2 right-3 -translate-y-1/2">
					<div
						class="h-4 w-4 animate-spin rounded-full border-2 border-primary border-t-transparent"
					></div>
				</div>
			{/if}
		</div>

		<!-- Venue Suggestions -->
		{#if dbSuggestions.length > 0 || mapboxSuggestions.length > 0}
			<div class="absolute z-10 mt-1 w-full rounded-md border border-input bg-white shadow-md">
				{#each dbSuggestions as venue}
					<button
						type="button"
						onclick={() => selectVenue('db', venue)}
						class="w-full px-3 py-2 text-left text-sm hover:bg-accent focus:bg-accent focus:outline-none"
					>
						<span class="font-medium">{venue.name}</span>
						<span class="ml-2 text-xs text-muted-foreground">(In Database)</span>
					</button>
				{/each}

				{#each mapboxSuggestions as suggestion}
					<button
						type="button"
						onclick={() => selectVenue('mapbox', suggestion)}
						class="w-full px-3 py-2 text-left text-sm hover:bg-accent focus:bg-accent focus:outline-none"
					>
						<span class="font-medium">{suggestion.name}</span>
						<span class="ml-2 text-xs text-muted-foreground">(Adding new venue...)</span>
					</button>
				{/each}
			</div>
		{/if}

		<!-- Selected Venue Display -->
		{#if selectedVenueName}
			<div class="mt-2 rounded-md bg-accent/20 p-2">
				<p class="text-sm font-medium">
					Selected: <span class="text-primary">{selectedVenueName}</span>
				</p>
			</div>
		{/if}
	</div>

	<Form.Button disabled={$submitting} type="submit" class="w-full">
		{$submitting ? 'Saving...' : 'Add Concert'}
	</Form.Button>
</form>
