# Geospatial Architecture

The status app uses a split responsibility model for geospatial data:

- Grails and GORM continue to read and write status attributes in the operational tables.
- PostGIS stores geometry in `geom` columns on those same operational tables.
- GeoServer publishes those tables as WFS layers with GeoJSON output.
- MapLibre GL JS 5.24.0 renders the GeoJSON layers in the browser at `/GeoStatusBoard/map` and the shared Incident Analyst route at `/GeoStatusBoard/incident-analyst`.

This keeps the existing Grails domains stable while allowing open source GIS services to own spatial querying and map delivery.

## Repository Map

The geospatial architecture sits in the status-board repo because the Grails app owns
the user-facing map, Incident Analyst route, GeoServer layer configuration, and
health indicators. The companion GeoAI repo owns the workflow API, COG
processing, model inference, and PostGIS output loading used by that map.

- [Emergency Management repo](https://github.com/JosephDillard/geospatial-status-board)
- [Emergency Management README](../README.md)
- [Emergency Management Architecture](https://github.com/JosephDillard/geospatial-status-board/blob/master/docs/geospatial-architecture.md)
- [GeoAI Asset Detection Platform repo](https://github.com/JosephDillard/geoai-asset-detection-platform)
- [GeoAI Asset Detection Platform README](https://github.com/JosephDillard/geoai-asset-detection-platform/blob/main/README.md)

## Recommended Stack

- PostgreSQL with PostGIS for spatial storage.
- GeoServer for OGC services, especially WFS GeoJSON.
- MapLibre GL JS 5.24.0 for the in-app 2D map viewer.

CesiumJS can be added later for 3D terrain, 3D Tiles, or globe-focused workflows. For the current dashboard and airport/airfield status use case, MapLibre is the lighter first map surface.

## Database Setup

Run the SQL guide after the operational tables exist:

```powershell
psql -d GeoStatusBoard -f docs/postgis-spatialization.sql
```

The SQL adds a `geom geometry(Geometry, 4326)` column and a GiST spatial index to the operational airport, airfield, asset, utility, and incident tables when those tables exist.

For the bundled development sample records, the SQL also fills approximate New Mexico point and polygon geometries so GeoServer and the map view work immediately in local Docker-based testing. Replace those sample locations with authoritative geometry before using production data.

Geometry population is data-source specific. Examples:

```sql
UPDATE public.navigationalaid
SET geom = ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)
WHERE geom IS NULL
  AND longitude IS NOT NULL
  AND latitude IS NOT NULL;
```

```sql
UPDATE public.index_airfields target
SET geom = source.geom
FROM public.airfield_boundaries source
WHERE target.site_name = source.site_name
  AND target.geom IS NULL;
```

## GeoServer Setup

1. Create a GeoServer workspace named `gsb`.
2. Create a PostGIS store pointed at the status app database.
3. Publish the operational tables listed in `docs/postgis-spatialization.sql`.
   GeoAI output can also be published from `public.detected_roads`, and current
   test imagery footprints can be published from `public.geoai_cog_footprints`,
   after the GeoAI pipeline loads vectors into the local PostGIS database.
4. Confirm WFS GeoJSON works. Example:

```text
http://localhost:8081/geoserver/gsb/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=gsb:index_airfields&outputFormat=application/json
```

5. If GeoServer exposes different layer or attribute names, update `geo.layers` in `grails-app/conf/application.yml`.

## Application Map View

The primary in-app map view is:

```text
/GeoStatusBoard/map
```

The focused Incident Analyst entry point is:

```text
/GeoStatusBoard/incident-analyst
```

The Incident Analyst route forwards into the same `map/index.gsp` implementation
with analyst mode enabled. It defaults to the Current Incidents layer, centers on
northern New Mexico, filters the review area toward Santa Fe and the Colorado
border, and adds the right-side incident review panel.

Existing GSP links can open a filtered layer by passing:

```text
/GeoStatusBoard/map?layer=airportStatus&field=site_name&value=Kirtland%20AFB
```

The map page builds a WFS request to GeoServer, loads GeoJSON into MapLibre, adds point, line, and polygon layers, fits to returned features, and displays feature attributes in a popup. The same layer drawer, basemap selector, incident plotting, LLM request panel, Wiki/GeoNames place search, response-support lookup, measurement tools, MGRS conversion, and incident popups are available from both routes.

Coordinate copy mode can leave multiple temporary coordinate markers on the map;
each marker popup shows MGRS, Lat/Lon, DMS, timestamp, copy, Google Maps, and
clear actions. Airport and airfield point layers use the airport symbol set,
current and archived incident layers use the FEMA-style incident symbol set, and
the Wiki/GeoNames and response-support tools draw their own temporary result
markers above the operational layers.

The map also creates a basemap-only minimap using a second lightweight MapLibre
instance. The minimap follows the selected basemap, draws a red outline around
the current main-map view, opens with the main map, can be minimized, and lets
the user click or drag the overview to move the main map without duplicating
operational WFS layers.

## Configuration

Geospatial configuration lives under `geo` in:

```text
grails-app/conf/application.yml
```

Important keys:

- `geo.geoserver.wfsUrl` - GeoServer WFS endpoint.
- `geo.geoai.apiUrl` and `geo.geoai.healthUrl` - GeoAI workflow API endpoint and health endpoint.
- `geo.gateway.*` - companion Geospatial Data Gateway health and SignalR refresh configuration.
- `geo.incidentAnalyst.*` - analyst route center, filter radius, support lookup bridge, timeout, and result radius.
- `geo.placeSearch.*` - Wiki/GeoNames lookup settings, including optional GeoNames username and result limits.
- `geo.health.requestTimeoutMs` - timeout for map service health checks.
- `geo.geoserver.defaultSrs` - Target spatial reference, default `EPSG:4326`.
- `geo.viewer.mapLibreJsUrl` and `geo.viewer.mapLibreCssUrl` - MapLibre assets, currently pinned to `maplibre-gl@5.24.0`.
- `geo.viewer.osmTilesUrl` - Raster basemap tile URL.
- `geo.layers` - App layer key to GeoServer feature type and filter fields.

The `detectedRoads` layer points at `gsb:detected_roads`, which is produced by
the sibling GeoAI asset-detection platform when its PostGIS load stage is run.
The `cogFootprints` layer points at `gsb:geoai_cog_footprints`, which is built
from the local COG inventory in the GeoAI repo.

## Map Service Health

The map page shows compact health boxes for GeoServer, PostGIS, GeoAI, and the
Geospatial Data Gateway.
The browser calls the same-origin Grails health endpoint, and the server checks the
configured dependencies. If GeoAI or the gateway is unavailable, the map still
loads normally and only the affected indicator is marked down.

## Incident Analyst and Response Support

The Incident Analyst route is intentionally a route-level mode on the shared map,
not a second map implementation. The browser still receives the same layer
configuration, basemaps, map tools, incident popups, and incident plotting logic.
Analyst mode adds a right-side review panel that summarizes current incidents,
shows severity and asset-criticality scoring, and links back to the table and
Kanban review views.

Response-support lookup uses same-origin Grails proxy routes:

- `GET /GeoStatusBoard/incident-analyst/api/analyze` forwards incident analysis requests to the bridge.
- `GET /GeoStatusBoard/incident-analyst/api/osm/support` forwards response-support lookup requests to the bridge.

The bridge target is configured with:

```text
INCIDENT_ANALYST_BRIDGE_URL=http://127.0.0.1:8775/incident-analyst
INCIDENT_ANALYST_REQUEST_TIMEOUT_MS=8000
```

The support tool is user-facing as response support. Internally, some DOM ids and
config keys still use `supportPoi`; treat that as an implementation detail when
working in the map code. When OpenStreetMap is slow or unreachable, the map
shows local response-support fallback records where available instead of leaving
the user with a blank result.

## Wiki/GeoNames Place Search

The Wiki/GeoNames tool lets an analyst click the map and inspect nearby named
places and Wikipedia context. Configure `GEONAMES_USERNAME` or
`geo.placeSearch.geonamesUsername` to prefer GeoNames nearby Wikipedia results.
Without a GeoNames username, the browser falls back to Wikipedia GeoSearch.

## GeoAI Map Requests

The map submits GeoAI jobs through same-origin proxy routes so the browser does not
need to call the GeoAI API host directly:

- `GET /GeoStatusBoard/geoAi/options` forwards to `GET /run-options`.
- `POST /GeoStatusBoard/geoAi/runs` forwards to `POST /runs`.
- `GET /GeoStatusBoard/geoAi/runs/{run_id}` forwards to `GET /runs/{run_id}`.

Each map-submitted job includes `request_source: external_app`, `submitted_by:
geospatial-status-board`, the selected `model_id`, the current bounding box, map
center, zoom, selected layer, and any drawn AOI GeoJSON. Drawn AOI polygons are
normalized before submission, including selected or active draw features and
closed polygon rings, so valid polygons are sent as `map_context.aoi_geojson`
instead of the workflow relying only on the current map-view bbox.

## Data Gateway Refresh

The companion Geospatial Data Gateway can publish local SignalR-style layer
refresh events to the map. Enable or tune it with:

```text
GEOSPATIAL_GATEWAY_SIGNALR_ENABLED=true
GEOSPATIAL_GATEWAY_HUB_URL=http://localhost:7070/hubs/geospatial-updates
GEOSPATIAL_GATEWAY_HEALTH_URL=http://localhost:7070/health
GEOSPATIAL_GATEWAY_LAYER_REFRESH_EVENT=layer.refresh_requested
```

The hub page also links to the configured gateway hub and health endpoint so the
dashboard can act as a review surface for the app, APIs, GeoServer, GeoAI, the
gateway, and the Incident Analyst bridge.
