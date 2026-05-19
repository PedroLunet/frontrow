<script lang="ts">
	import { goto } from '$app/navigation';
	import { MapPin, X, Ticket, CircleCheck, Loader } from 'lucide-svelte';
	import { supabase } from '$lib/supabaseclient.js';
	import { userRsvpsStore } from '$lib/stores.js';

	let { concert, closePopup, user = null } = $props();

	let isGoing = $state(false);
	let showCancel = $state(false);
	let isLoading = $state(false);

	let descriptionModal: HTMLDialogElement;

	$effect(() => {
		const unsubscribe = userRsvpsStore.subscribe((rsvps) => {
			isGoing = !!rsvps[concert.id];
		});
		return unsubscribe;
	});

	$effect(() => {
		if (isGoing) {
			showCancel = true;
		} else {
			showCancel = false;
		}
	});

	async function handleGoing() {
		if (!user) {
			goto('/login');
			return;
		}

		isLoading = true;

		const { error } = await supabase.from('user_concerts').insert({
			id: crypto.randomUUID(),
			concert_id: concert.id,
			user_id: user.id,
			created_at: new Date().toISOString()
		});

		isLoading = false;

		if (error) {
			console.error('Failed to RSVP:', error);
			return;
		}

		userRsvpsStore.update((rsvps) => ({ ...rsvps, [concert.id]: true }));
	}

	async function handleCancel() {
		if (!user) return;

		isLoading = true;

		const { error } = await supabase
			.from('user_concerts')
			.delete()
			.eq('concert_id', concert.id)
			.eq('user_id', user.id);

		isLoading = false;

		if (error) {
			console.error('Failed to cancel RSVP:', error);
			return;
		}

		userRsvpsStore.update((rsvps) => {
			const next = { ...rsvps };
			delete next[concert.id];
			return next;
		});
	}

	const formattedDate = new Date(concert.date).toLocaleDateString('en-US', {
		month: 'short',
		day: 'numeric',
		year: 'numeric'
	});

	let isDescriptionOpen = $state(false);

	function openDescription() {
		descriptionModal.showModal();
		requestAnimationFrame(() => {
			isDescriptionOpen = true;
		});
	}

	function closeDescription() {
		isDescriptionOpen = false;
		setTimeout(() => {
			descriptionModal.close();
		}, 300);
	}
</script>

<div
	class="text-text flex w-64 flex-col overflow-hidden rounded-4xl border border-accent bg-white font-sans"
>
	{#if concert.image_url}
		<div class="relative overflow-hidden p-1.5">
			<img
				src={concert.image_url}
				alt={concert.name}
				class="h-32 w-full rounded-3xl object-cover"
			/>

			<button
				onclick={closePopup}
				aria-label="Close"
				class="bg-text/60 hover:bg-text/80 absolute top-4 right-4 flex h-7 w-7 cursor-pointer items-center justify-center overflow-hidden rounded-xl border-[0.5px] border-white/20 backdrop-blur-md transition-all hover:scale-105 active:scale-95"
			>
				<div
					class="pointer-events-none absolute inset-0 bg-linear-to-tr from-white/5 to-white/20"
				></div>
				<X size={14} strokeWidth={3} class="text-text-white relative z-10" />
			</button>

			<div
				class="bg-text/60 absolute right-4 bottom-4 overflow-hidden rounded-2xl border-[0.5px] border-white/20 px-2.5 py-1.5 backdrop-blur-md"
			>
				<div
					class="pointer-events-none absolute inset-0 bg-linear-to-tr from-white/5 to-white/20"
				></div>
				<p class="text-text-white relative z-10 text-xs">
					{formattedDate}
				</p>
			</div>
		</div>
	{/if}

	<div class="p-4 pt-1">
		<h3 class="mb-1 text-base leading-tight font-bold tracking-tight text-primary uppercase">
			{concert.artist}
		</h3>
		<div class="mb-2 flex flex-row items-center gap-1 font-extralight">
			<MapPin size={16} class="text-primary" />
			<p class="text-text text-sm">{concert.venues?.name}</p>
		</div>

		<button
			type="button"
			onclick={openDescription}
			class="group mb-4 w-full text-left focus:outline-none"
		>
			<p
				class="text-text line-clamp-3 text-sm leading-tight font-extralight tracking-tight transition-opacity group-hover:opacity-70"
			>
				{concert.description}
			</p>
			<span class="text-xs font-extralight text-primary group-hover:underline"> Read more </span>
		</button>

		<div class="mt-2 flex h-10 w-full">
			<div
				class="flex shrink-0 overflow-hidden transition-all duration-400 ease-[cubic-bezier(0.87,0,0.13,1)]
        {showCancel ? 'pointer-events-auto w-12 opacity-100' : 'pointer-events-none w-0 opacity-0'}"
			>
				<button
					onclick={handleCancel}
					aria-label="Cancel Going"
					class="flex h-10 w-10 shrink-0 cursor-pointer items-center justify-center rounded-2xl border border-primary bg-transparent text-primary transition-colors hover:bg-primary/10 focus:outline-none disabled:opacity-50"
					disabled={isLoading}
				>
					{#if isLoading}
						<Loader size={18} strokeWidth={3} class="animate-spin" />
					{:else}
						<X size={18} strokeWidth={3} />
					{/if}
				</button>
			</div>

			<button
				onclick={!isGoing ? handleGoing : undefined}
				class="group relative flex flex-1 overflow-hidden rounded-2xl border transition-all duration-400 ease-[cubic-bezier(0.87,0,0.13,1)] focus:outline-none
          {isGoing
					? 'cursor-default border-primary bg-primary text-white'
					: 'cursor-pointer border-primary bg-transparent text-primary hover:bg-primary/5'}"
				disabled={isLoading}
			>
				<div
					class="absolute inset-0 flex items-center justify-center gap-2 transition-all duration-400 ease-[cubic-bezier(0.87,0,0.13,1)]
          {isGoing ? 'scale-90 opacity-0' : 'scale-100 opacity-100'}"
				>
					{#if isLoading}
						<Loader size={18} strokeWidth={2.5} class="animate-spin" />
					{:else}
						<Ticket
							size={18}
							strokeWidth={2.5}
							class="transition-transform duration-400 group-hover:-rotate-12"
						/>
					{/if}
					<span class="text-sm font-bold tracking-tight">Mark as Going</span>
				</div>

				<div
					class="absolute inset-0 flex items-center justify-center gap-2 transition-all duration-400 ease-[cubic-bezier(0.87,0,0.13,1)]
          {isGoing ? 'scale-100 opacity-100' : 'pointer-events-none scale-110 opacity-0'}"
				>
					<CircleCheck size={18} strokeWidth={2.5} />
					<span class="text-sm font-bold tracking-tight">You're Going!</span>
				</div>
			</button>
		</div>
	</div>
</div>

<dialog
	bind:this={descriptionModal}
	oncancel={(e) => {
		// Intercepts the ESC key so it animates out smoothly
		e.preventDefault();
		closeDescription();
	}}
	onclick={(e) => {
		// Clicking the dimmed backdrop closes the modal
		if (e.target === descriptionModal) closeDescription();
	}}
	class="m-auto w-[90vw] max-w-lg rounded-4xl border-2 border-accent bg-white p-0 shadow-sm transition-all
         duration-300 ease-[cubic-bezier(0.2,0.8,0.2,1)] backdrop:transition-all
         backdrop:duration-300 backdrop:ease-[cubic-bezier(0.2,0.8,0.2,1)] focus:outline-none
         {isDescriptionOpen
		? 'backdrop:bg-text/40 scale-100 opacity-100 backdrop:backdrop-blur-sm'
		: 'scale-95 opacity-0 backdrop:bg-transparent backdrop:backdrop-blur-none'}"
>
	<div class="text-text relative flex max-h-[80vh] flex-col p-6 pt-8 font-sans">
		<button
			onclick={closeDescription}
			aria-label="Close modal"
			class="text-text absolute top-4 right-4 flex h-8 w-8 cursor-pointer items-center justify-center rounded-xl bg-accent/20 transition-colors hover:bg-accent/40 active:scale-95"
		>
			<X size={16} strokeWidth={3} />
		</button>

		<h3 class="mb-4 pr-6 text-xl font-bold tracking-tight text-primary uppercase">Description</h3>

		<div class="overflow-y-auto pr-2">
			<p
				class="text-text text-sm leading-relaxed font-extralight tracking-tight whitespace-pre-wrap"
			>
				{concert.description}
			</p>
		</div>
	</div>
</dialog>
