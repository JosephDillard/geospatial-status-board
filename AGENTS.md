# Agent Guide

This repo is the operational map and dashboard layer in the companion
geospatial stack. It is a Grails application with a MapLibre map view, optional
PostGIS/GeoServer infrastructure, and local integration with GeoAI and gateway
services.

## Stack Context

Related sibling repos:

- `geoai-asset-detection-platform` creates GeoAI vector detections that can be
  loaded into PostGIS and published through GeoServer.
- `geospatial-data-gateway` loads geospatial source files into PostGIS and sends
  local SignalR refresh events to the map.
- `geospatial-mcp-services` provides map-click assistant tools such as
  GeoNames/Wikipedia lookup.

When changing cross-repo docs, prefer full GitHub URLs for links that point
outside this repo.

## What This Repo Owns

- Root Grails app: `grails-app/`
- Airport and airfield module: `gsb-airport/`
- Incident module: `gsb-incidents/`
- Map view: `grails-app/views/map/index.gsp`
- App config: `grails-app/conf/application.yml`
- PostGIS profile config: `grails-app/conf/application-postgis.yml`
- Local GIS stack: `docker-compose.yml`, `docker/`, and `dev.ps1`
- Architecture and spatial notes: `docs/`

The app is served under `/GeoStatusBoard`.

## Development Notes

- The default app path uses H2. Enable the `postgis` Spring profile only when
  testing against the Docker PostGIS stack.
- The map currently pins MapLibre GL JS/CSS to `maplibre-gl@5.24.0` in
  `geo.viewer.mapLibreJsUrl` and `geo.viewer.mapLibreCssUrl`. Keep the
  fallback URLs in `MapController.groovy` aligned with those config values.
- Keep the map usable when GeoServer, GeoAI, or the data gateway are offline.
  Failure states should be visible without breaking base map interaction.
- Coordinate copy mode supports multiple temporary coordinate markers. Marker
  popups own the copy, timestamp, Google Maps, and clear actions.
- The minimap is a second lightweight MapLibre instance using the selected
  basemap only. Do not load operational WFS or GeoAI layers into the overview.
- GeoAI map requests should include normalized drawn AOIs in
  `map_context.aoi_geojson` when polygons are present; only fall back to the map
  bbox when no valid drawn AOI exists.
- The map's local SignalR refresh integration is configured under
  `geo.gateway` and currently targets the data gateway hub.
- The local GeoAI Docker profile assumes the sibling repo path
  `../geoai-asset-detection-platform`.
- Avoid committing local logs, generated screenshots, database dumps, or `.env`
  files.

## Useful Commands

```powershell
.\gradlew.bat :bootRun
.\gradlew.bat :bootRun --args="--server.port=18088"
.\gradlew.bat clean build
```

Optional local GIS infrastructure:

```powershell
.\dev.ps1 up
.\dev.ps1 up-geoai
.\dev.ps1 spatialize
.\dev.ps1 geoserver-init
.\dev.ps1 down
```

Run against PostGIS:

```powershell
.\dev.ps1 up
$env:SPRING_PROFILES_ACTIVE = 'postgis'
.\gradlew.bat :bootRun
Remove-Item Env:SPRING_PROFILES_ACTIVE
```

## Before Finishing Changes

- Run `.\gradlew.bat clean build` for backend or config changes.
- For map-view changes, start the app and verify
  `http://localhost:18088/GeoStatusBoard` when practical.
- Update `README.md` or `docs/geospatial-architecture.md` when layer contracts,
  local ports, Docker services, or repo relationships change.
