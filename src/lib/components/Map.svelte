<script lang="ts">
	import { onMount } from 'svelte';
	import mapboxgl from 'mapbox-gl';
	import 'mapbox-gl/dist/mapbox-gl.css';
	import { PUBLIC_MAPBOX_TOKEN, PUBLIC_MAPBOX_STYLE_URL } from '$env/static/public';

	let { styleUrl = PUBLIC_MAPBOX_STYLE_URL } = $props();

	let mapContainer: HTMLElement;
	let map: mapboxgl.Map;

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
</script>

<div bind:this={mapContainer} class="h-full w-full rounded-xl shadow-inner"></div>
