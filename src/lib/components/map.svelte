<script lang="ts">
	import { onMount } from 'svelte';
	import mapboxgl from 'mapbox-gl';
	import 'mapbox-gl/dist/mapbox-gl.css';
	import { PUBLIC_MAPBOX_TOKEN, PUBLIC_MAPBOX_STYLE_URL } from '$env/static/public';

	let { styleUrl = PUBLIC_MAPBOX_STYLE_URL, venues = [] } = $props();

	let mapContainer: HTMLElement;
	let map: mapboxgl.Map;
	let markers: mapboxgl.Marker[] = [];

	function parseWKBPoint(hexString: string) {
		try {
			const hexBytes = hexString.match(/.{1,2}/g);
			if (!hexBytes) return null;

			const bytes = new Uint8Array(hexBytes.map((byte) => parseInt(byte, 16)));
			const view = new DataView(bytes.buffer);

			const littleEndian = view.getUint8(0) === 1;

			const lng = view.getFloat64(9, littleEndian);
			const lat = view.getFloat64(17, littleEndian);

			return [lng, lat] as [number, number];
		} catch (err) {
			console.error('Failed to parse coordinates:', hexString);
			return null;
		}
	}

	onMount(() => {
		mapboxgl.accessToken = PUBLIC_MAPBOX_TOKEN;

		map = new mapboxgl.Map({
			container: mapContainer,
			style: styleUrl,
			center: [-8.6109, 41.1496],
			zoom: 17,
			pitch: 70
		});

		return () => {
			if (map) map.remove();
		};
	});

	$effect(() => {
		if (!map || venues.length === 0) return;

		markers.forEach((m) => m.remove());
		markers = [];

		venues.forEach((venue) => {
			const coords = parseWKBPoint(venue.coordinates);

			if (coords) {
				const marker = new mapboxgl.Marker({ color: 'orange' }).setLngLat(coords).addTo(map);

				markers.push(marker);
			}
		});
	});
</script>

<div
	bind:this={mapContainer}
	class="h-full w-full rounded-xl border border-gray-200 shadow-inner"
></div>
