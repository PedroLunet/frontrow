<script lang="ts">
	import { onMount } from 'svelte';
	import { mount } from 'svelte';
	import mapboxgl from 'mapbox-gl';
	import 'mapbox-gl/dist/mapbox-gl.css';
	import { PUBLIC_MAPBOX_TOKEN, PUBLIC_MAPBOX_STYLE_URL } from '$env/static/public';

	import Popup from './popup.svelte';

	let { styleUrl = PUBLIC_MAPBOX_STYLE_URL, concerts = [] } = $props();

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
			zoom: 17.5,
			pitch: 70
		});

		return () => {
			if (map) map.remove();
		};
	});

	$effect(() => {
		if (!map || concerts.length === 0) return;

		markers.forEach((m) => m.remove());
		markers = [];

		const groupedByVenue: Record<string, any> = {};

		concerts.forEach((concert) => {
			const venueId = concert.venues.id;

			if (!groupedByVenue[venueId]) {
				groupedByVenue[venueId] = {
					venue: concert.venues,
					concerts: []
				};
			}
			groupedByVenue[venueId].concerts.push(concert);
		});

		Object.values(groupedByVenue).forEach((group) => {
			const coords = parseWKBPoint(group.venue.coordinates);

			if (coords) {
				let marker;

				if (group.concerts.length === 1) {
					const popupNode = document.createElement('div');

					mount(Popup, {
						target: popupNode,
						props: { concert: group.concerts[0] }
					});

					const popup = new mapboxgl.Popup({ offset: 25, closeButton: false }).setDOMContent(
						popupNode
					);

					marker = new mapboxgl.Marker({ color: 'orange' })
						.setLngLat(coords)
						.setPopup(popup)
						.addTo(map);
				} else {
					const el = document.createElement('div');
					el.className =
						'flex h-8 w-8 cursor-pointer items-center justify-center rounded-full bg-orange-500 text-sm font-bold text-white shadow-lg ring-2 ring-white transition-transform hover:scale-110';
					el.innerText = group.concerts.length.toString();

					marker = new mapboxgl.Marker(el).setLngLat(coords).addTo(map);
				}

				markers.push(marker);
			}
		});
	});
</script>

<div
	bind:this={mapContainer}
	class="h-full w-full rounded-xl border border-gray-200 shadow-inner"
></div>
