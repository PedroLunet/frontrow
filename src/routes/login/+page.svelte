<script lang="ts">
	import { supabase } from '$lib/supabaseclient.js';

	let email = $state('');
	let otp = $state('');
	let step = $state(1);
	let loading = $state(false);
	let message = $state('');

	async function requestOtp(event: Event) {
		if (event) event.preventDefault();

		const cleanEmail = email.toLowerCase().trim();

		loading = true;
		message = '';

		try {
			const { error } = await supabase.auth.signInWithOtp({
				email: cleanEmail,
				options: { shouldCreateUser: true }
			});

			if (error) throw error;

			message = 'Code sent! Grab the 6 digits from Mailpit.';
			step = 2;
		} catch (err: unknown) {
			console.error('Auth Error:', err);
			message = err instanceof Error ? err.message : 'Failed to send code. Please try again.';
		} finally {
			loading = false;
		}
	}

	async function verifyOtp(event: Event) {
		if (event) event.preventDefault();

		const cleanEmail = email.toLowerCase().trim();
		const cleanOtp = otp.trim();

		loading = true;
		message = '';

		try {
			const { error } = await supabase.auth.verifyOtp({
				email: cleanEmail,
				token: cleanOtp,
				type: 'email'
			});

			if (error) throw error;

			message = '🎉 Logged in successfully!';
		} catch (err: unknown) {
			console.error('Verification Error:', err);
			message = err instanceof Error ? err.message : 'Invalid code. Please try again.';
		} finally {
			loading = false;
		}
	}
</script>

<main class="mx-auto my-12 max-w-100 px-4 font-sans text-gray-900">
	<h1 class="mb-8 text-center text-3xl font-bold tracking-tight">Welcome to FrontRow</h1>

	{#if message}
		<p class="mb-6 rounded-lg bg-amber-200 p-3 text-center text-sm font-medium text-amber-900">
			{message}
		</p>
	{/if}

	{#if step === 1}
		<form onsubmit={requestOtp} class="space-y-4">
			<div>
				<label for="email" class="mb-1 block text-sm font-medium text-gray-700"
					>Enter your email</label
				>
				<input
					id="email"
					type="email"
					bind:value={email}
					placeholder="you@example.com"
					required
					class="w-full rounded-lg border border-gray-300 p-3 transition-shadow focus:border-transparent focus:ring-2 focus:ring-black focus:outline-none"
				/>
			</div>

			<button
				type="submit"
				disabled={loading}
				class="w-full rounded-lg bg-black px-4 py-3 font-medium text-white transition-all hover:bg-gray-800 focus:ring-2 focus:ring-black focus:ring-offset-2 focus:outline-none disabled:cursor-not-allowed disabled:opacity-50"
			>
				{loading ? 'Sending...' : 'Send Code'}
			</button>
		</form>
	{:else}
		<form onsubmit={verifyOtp} class="space-y-4">
			<div>
				<label for="otp" class="mb-1 block text-sm font-medium text-gray-700"
					>Enter the 6-digit code</label
				>
				<input
					id="otp"
					type="text"
					bind:value={otp}
					placeholder="123456"
					required
					minlength="6"
					maxlength="6"
					class="w-full rounded-lg border border-gray-300 p-3 text-center font-mono text-lg tracking-[0.5em] transition-shadow focus:border-transparent focus:ring-2 focus:ring-black focus:outline-none"
				/>
			</div>

			<button
				type="submit"
				disabled={loading}
				class="w-full rounded-lg bg-black px-4 py-3 font-medium text-white transition-all hover:bg-gray-800 focus:ring-2 focus:ring-black focus:ring-offset-2 focus:outline-none disabled:cursor-not-allowed disabled:opacity-50"
			>
				{loading ? 'Verifying...' : 'Log In'}
			</button>

			<button
				type="button"
				onclick={() => {
					step = 1;
					otp = '';
					message = '';
				}}
				class="mt-2 w-full py-2 text-sm font-medium text-gray-500 transition-colors hover:text-black hover:underline focus:outline-none"
			>
				Wait, I need to change my email
			</button>
		</form>
	{/if}
</main>
