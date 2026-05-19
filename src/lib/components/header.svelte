<script lang="ts">
	import { onMount } from 'svelte';
	import { supabase } from '$lib/supabaseclient.js';
	import { Dialog } from 'bits-ui';
	import { X } from 'lucide-svelte';
	import AddConcert from './addConcert.svelte';

	let userEmail = $state<string | null>(null);

	onMount(async () => {
		const { data } = await supabase.auth.getUser();
		if (data.user) {
			userEmail = data.user.email || null;
		}
	});

	async function handleLogout() {
		await supabase.auth.signOut();
		userEmail = null;
	}
</script>

<nav class="relative z-10 flex items-center justify-between px-6 py-4">
	<h1 class="text-xl font-bold tracking-tight text-black">FrontRow</h1>

	<div>
		{#if userEmail}
			<div class="flex items-center gap-4">
				<span class="hidden text-sm text-gray-600 sm:inline">{userEmail}</span>
				<Dialog.Root>
					<Dialog.Trigger
						class="inline-flex items-center justify-center rounded-lg bg-black px-4 py-2 text-sm font-medium text-white transition-colors hover:bg-gray-800 focus-visible:ring-2 focus-visible:ring-offset-2 focus-visible:outline-none"
					>
						Add Concert
					</Dialog.Trigger>
					<Dialog.Portal>
						<Dialog.Overlay
							class="fixed inset-0 z-50 bg-black/80 data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:animate-in data-[state=open]:fade-in-0"
						/>
						<Dialog.Content
							class="fixed top-[50%] left-[50%] z-50 w-full max-w-[calc(100%-2rem)] translate-x-[-50%] translate-y-[-50%] rounded-lg border border-gray-200 bg-white p-6 shadow-lg data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=closed]:zoom-out-95 data-[state=open]:animate-in data-[state=open]:fade-in-0 data-[state=open]:zoom-in-95 sm:max-w-[500px]"
						>
							<div class="flex items-center justify-between">
								<Dialog.Title class="text-lg font-semibold text-black">
									Add a New Concert
								</Dialog.Title>
								<Dialog.Close
									class="inline-flex items-center justify-center rounded-md hover:bg-gray-100 focus-visible:ring-2 focus-visible:ring-offset-2 focus-visible:outline-none active:scale-[0.98]"
								>
									<X class="size-5 text-gray-500" />
									<span class="sr-only">Close</span>
								</Dialog.Close>
							</div>
							<div class="mt-6 max-h-[70vh] overflow-y-auto">
								<AddConcert
									onSuccess={() => {
										const trigger = document.querySelector('[data-state="open"]');
										const closeBtn = trigger
											?.closest('[role="dialog"]')
											?.querySelector('[data-dialog-close]');
										if (closeBtn) closeBtn.click();
									}}
								/>
							</div>
						</Dialog.Content>
					</Dialog.Portal>
				</Dialog.Root>
				<button
					onclick={handleLogout}
					class="text-sm font-medium text-red-600 transition-colors hover:text-red-800"
				>
					Log Out
				</button>
			</div>
		{:else}
			<a
				href="/login"
				class="rounded-lg bg-black px-4 py-2 text-sm font-medium text-white transition-all hover:bg-gray-800"
			>
				Log In
			</a>
		{/if}
	</div>
</nav>
