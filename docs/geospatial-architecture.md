# Geospatial Architecture

The status app uses a split responsibility model for geospatial data:

- Grails and GORM continue to read and write status attributes in the operational tables.
- PostGIS stores geometry in `geom` columns on those same operational tables.
- GeoServer publishes those tables as WFS layers with GeoJSON output.
- MapLibre GL JS 5.24.0 renders the GeoJSON layers in the browser at `/GeoStatusBoard/map`.

This keeps the existing Grails domains stable while allowing open source GIS services to own spatial querying and map delivery.

## Repository Map

The geospatial architecture sits in the status-board repo because the Grails app owns
the user-facing map, GeoServer layer configuration, and health indicators. The
companion GeoAI repo owns the workflow API, COG processing, model inference, and
PostGIS output loading used by that map.

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

The in-app map view is:

```text
/GeoStatusBoard/map
```

Existing GSP links can open a filtered layer by passing:

```text
/GeoStatusBoard/map?layer=airportStatus&field=site_name&value=Kirtland%20AFB
```

The map page builds a WFS request to GeoServer, loads GeoJSON into MapLibre, adds point, line, and polygon layers, fits to returned features, and displays feature attributes in a popup. Coordinate copy mode can leave multiple temporary coordinate markers on the map; each marker popup shows MGRS, Lat/Lon, DMS, timestamp, copy, Google Maps, and clear actions.

The map also creates a basemap-only minimap using a second lightweight MapLibre
instance. The minimap follows the selected basemap, draws a red outline around
the current main-map view, and lets the user click or drag the overview to move
the main map without duplicating operational WFS layers.

## Configuration

Geospatial configuration lives under `geo` in:

```text
grails-app/conf/application.yml
```

Important keys:

- `geo.geoserver.wfsUrl` - GeoServer WFS endpoint.
- `geo.geoai.apiUrl` and `geo.geoai.healthUrl` - GeoAI workflow API endpoint and health endpoint.
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

The map page shows compact health boxes for GeoServer, PostGIS, and the GeoAI API.
The browser calls the same-origin Grails health endpoint, and the server checks the
configured dependencies. If GeoAI is unavailable, the map still loads normally and
only the GeoAI indicator is marked down.

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
