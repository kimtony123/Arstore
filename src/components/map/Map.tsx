import React, { useEffect } from 'react';

import 'leaflet/dist/leaflet.css';
import L from 'leaflet';
import { MapContainer, TileLayer, useMapEvents, Marker, Popup, useMap } from 'react-leaflet';
import { GeoSearchControl, OpenStreetMapProvider } from 'leaflet-geosearch';
import 'leaflet-geosearch/dist/geosearch.css';

// Import images for marker
import markerIcon2x from 'leaflet/dist/images/marker-icon-2x.png';
import markerIcon from 'leaflet/dist/images/marker-icon.png';
import markerShadow from 'leaflet/dist/images/marker-shadow.png';

// Set up the marker icon
const defaultIcon = L.icon({
    iconUrl: markerIcon,
    iconRetinaUrl: markerIcon2x,
    shadowUrl: markerShadow,
    iconSize: [25, 41],
    iconAnchor: [12, 41],
    popupAnchor: [1, -34],
    shadowSize: [41, 41],
});

const SearchField: React.FC<{
    provider: OpenStreetMapProvider,
    setLat: (num: number) => void,
    setLng: (num: number) => void
}> = ({ provider, setLat, setLng }) => {
    const searchControl = GeoSearchControl({
        provider,
        style: 'bar',
        marker: L.Marker,
        showMarker: true,
        retainZoomLevel: false,
        animateZoom: true,
        autoClose: true,
        searchLabel: 'Search for a city...',
        keepResult: false,
    });

    const map = useMap();

    useEffect(() => {
        map.addControl(searchControl);

        map.on('geosearch/showlocation', (result: any) => {
            const { x, y } = result.location;
            setLat(Number(y));
            setLng(Number(x));

            console.log('lon', x, 'lat', y)

            // Update the local storage
            localStorage.setItem('lat', Number(y).toString());
            localStorage.setItem('lng', Number(x).toString());
            // localStorage.setItem('location', `Lat: ${e.latlng.lat}, Lng: ${e.latlng.lng}`);
            map.flyTo([y, x], 10, { animate: true, duration: 1 }); // Adjust the zoom level as needed
        });

        return () => {
            map.removeControl(searchControl);
            map.off('geosearch/showlocation');
        };
    }, []);

    return null;
}

const Map: React.FC<{
    lat: number, lng: number,
    setLat: (num: number) => void,
    setLng: (num: number) => void
}> = ({ lat, lng, setLat, setLng }) => {
    const provider = new OpenStreetMapProvider();

    // Custom map handler to get clicked position
    const MapClickHandler: React.FC = () => {
        useMapEvents({
            click(e: L.LeafletMouseEvent) {
                setLat(e.latlng.lat);
                setLng(e.latlng.lng);
                // setMapLocation(`Lat: ${e.latlng.lat}, Lng: ${e.latlng.lng}`);

                // Update the local storage
                localStorage.setItem('lat', e.latlng.lat.toString());
                localStorage.setItem('lng', e.latlng.lng.toString());
                localStorage.setItem('location', `Lat: ${e.latlng.lat}, Lng: ${e.latlng.lng}`);

                // Fly to the clicked coordinates
                e.target.flyTo([e.latlng.lat, e.latlng.lng], 10, {
                    animate: true,
                    duration: 1 // duration in seconds
                });
            },
        });
        return null;
    };

    return (
        <>
            {/* Leaflet Map */}
            <MapContainer
                style={{ height: '50vh', width: '100%' }}
                center={[lat, lng]}
                zoom={5}
                scrollWheelZoom={true}>
                <TileLayer
                    url="https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png"//url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                    attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a>'//attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
                />
                <Marker position={[lat, lng]} icon={defaultIcon}>
                    <Popup>
                        Lat: {lat}, Lng: {lng}
                    </Popup>
                </Marker>

                <SearchField provider={provider} setLat={setLat} setLng={setLng} />

                <MapClickHandler />
            </MapContainer>
        </>
    )
}

export default Map