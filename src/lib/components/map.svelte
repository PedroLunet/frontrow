<script lang="ts">
	import { onMount } from 'svelte';
	import { mount } from 'svelte';
	import mapboxgl from 'mapbox-gl';
	import 'mapbox-gl/dist/mapbox-gl.css';
	import { PUBLIC_MAPBOX_TOKEN, PUBLIC_MAPBOX_STYLE_URL } from '$env/static/public';

	import Popup from './popup.svelte';
	import MultiConcertPopup from './multiConcertPopup.svelte';

	let { styleUrl = PUBLIC_MAPBOX_STYLE_URL, concerts = [], user = null } = $props();

	let mapContainer: HTMLElement;
	let map: mapboxgl.Map;
	let markers: mapboxgl.Marker[] = [];
	let lastConcertIds: string | null = null;

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
		const currentIds = concerts.map((c) => c.id).join(',');
		if (!map || concerts.length === 0 || currentIds === lastConcertIds) return;

		lastConcertIds = currentIds;

		markers.forEach((m) => m.remove());
		markers = [];

		if (!map.loaded()) {
			map.once('load', () => createMarkers());
			return;
		}

		createMarkers();
	});

	function createMarkers() {
		const groupedByVenue: Record<string, any> = {};

		concerts.forEach((concert) => {
			const venueId = concert.venues.id;
			if (!groupedByVenue[venueId]) {
				groupedByVenue[venueId] = { venue: concert.venues, concerts: [] };
			}
			groupedByVenue[venueId].concerts.push(concert);
		});

		Object.values(groupedByVenue).forEach((group) => {
			const coords = parseWKBPoint(group.venue.coordinates);

			if (coords) {
				let marker;

				if (group.concerts.length === 1) {
					const popupNode = document.createElement('div');

					const popup = new mapboxgl.Popup({
						offset: 40,
						closeButton: false,
						anchor: 'bottom',
						focusAfterOpen: false
					});

					popup.on('open', () => {
						const markerPos = map.project(coords);
						const container = map.getContainer();

						const targetX = container.offsetWidth / 2;
						const targetY = container.offsetHeight / 2 + 150;

						const distance = Math.sqrt(
							Math.pow(markerPos.x - targetX, 2) + Math.pow(markerPos.y - targetY, 2)
						);

						if (distance < 10) return;

						map.easeTo({
							center: coords,
							offset: [0, 150],
							duration: 800,
							essential: true,
							easing: (t) => 1 - Math.pow(1 - t, 4)
						});
					});

					mount(Popup, {
						target: popupNode,
						props: {
							concert: group.concerts[0],
							closePopup: () => popup.remove(),
							user
						}
					});

					popup.setDOMContent(popupNode);

					marker = new mapboxgl.Marker({ color: 'orange' })
						.setLngLat(coords)
						.setPopup(popup)
						.addTo(map);
				} else {
					const popupNode = document.createElement('div');

					const popup = new mapboxgl.Popup({
						offset: 30,
						closeButton: false,
						anchor: 'bottom',
						focusAfterOpen: false
					});

					popup.on('open', () => {
						const markerPos = map.project(coords);
						const container = map.getContainer();

						const targetX = container.offsetWidth / 2;
						const targetY = container.offsetHeight / 2 + 150;

						const distance = Math.sqrt(
							Math.pow(markerPos.x - targetX, 2) + Math.pow(markerPos.y - targetY, 2)
						);

						if (distance < 10) return;

						map.easeTo({
							center: coords,
							offset: [0, 150],
							duration: 800,
							essential: true,
							easing: (t) => 1 - Math.pow(1 - t, 4)
						});
					});

					mount(MultiConcertPopup, {
						target: popupNode,
						props: {
							concerts: group.concerts,
							closePopup: () => popup.remove(),
							user
						}
					});

					popup.setDOMContent(popupNode);

					const el = document.createElement('div');
					el.className =
						'flex h-7 aspect-square cursor-pointer items-center justify-center rounded-full bg-orange-400 text-sm font-bold text-text-white shadow-lg ring-2 ring-white';
					el.innerText = group.concerts.length.toString();

					marker = new mapboxgl.Marker(el).setLngLat(coords).setPopup(popup).addTo(map);
				}

				markers.push(marker);
			}
		});
	}
</script>

<div
	bind:this={mapContainer}
	class="h-full w-full rounded-2xl border border-gray-200 shadow-inner"
></div>
