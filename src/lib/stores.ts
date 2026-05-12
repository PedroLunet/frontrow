import { writable } from 'svelte/store';

export const userRsvpsStore = writable<Record<string, boolean>>({});
