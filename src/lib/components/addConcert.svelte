<script lang="ts">
	import { supabase } from '$lib/supabaseclient.js';
	import { Button, buttonVariants } from '$lib/components/ui/button/index.js';
	import { Input } from '$lib/components/ui/input/index.js';
	import * as Form from '$lib/components/ui/form/index.js';
	import { concertFormSchema, type ConcertFormSchema } from '$lib/schemas/concertSchema';
	import { defaults, superForm } from 'sveltekit-superforms';
	import { zod4 } from 'sveltekit-superforms/adapters';
	import { toast } from 'svelte-sonner';
	import * as Dialog from '$lib/components/ui/dialog/index.js';
	import Textarea from './ui/textarea/textarea.svelte';
	import AddVenue from './addVenue.svelte';

	interface Props {
		onSuccess?: () => void;
	}

	let { onSuccess }: Props = $props();

	let selectedVenueId = $state<string | null>(null);
	let selectedVenueName = $state('');

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
				onSuccess?.();
			} catch (err) {
				console.error('Failed to save concert:', err);
				toast.error('Error saving concert.');
			}
		}
	});

	const { form: formData, enhance, submitting } = form;

	function onVenueSelect(venue: { id: string; name: string }) {
		selectedVenueId = venue.id;
		selectedVenueName = venue.name;
	}
</script>

<Dialog.Root>
	<form method="POST" use:enhance>
		<Dialog.Trigger type="button"><Button variant="outline">Open Dialog</Button></Dialog.Trigger>
		<Dialog.Content class="flex max-h-[90vh] flex-col">
			<Dialog.Header>
				<Dialog.Title class="text-lg font-semibold">Add Concert</Dialog.Title>
				<Dialog.Description>
					Can't find the concert you're looking for on the map? Add it here and help grow the
					FrontRow community!
				</Dialog.Description>
			</Dialog.Header>
			<div class="flex-1 space-y-4 overflow-auto px-2">
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
							<Textarea
								{...props}
								bind:value={$formData.description}
								placeholder="Enter concert details and description"
							></Textarea>
						{/snippet}
					</Form.Control>
					<Form.FieldErrors />
				</Form.Field>

				<div class="space-y-2">
					<span class="text-sm font-medium">Venue (Required)</span>
					<AddVenue venueSelect={onVenueSelect} />
				</div>
			</div>
			<Dialog.Footer>
				<Dialog.Close type="button" class={buttonVariants({ variant: 'outline' })}>
					Cancel
				</Dialog.Close>
				<Form.Button disabled={$submitting} type="submit">
					{$submitting ? 'Saving...' : 'Add Concert'}
				</Form.Button>
			</Dialog.Footer>
		</Dialog.Content>
	</form>
</Dialog.Root>
