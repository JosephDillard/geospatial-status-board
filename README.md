# Status App

This repository contains a status app linkable to geospatial data for dashboard and geospatial view of airport and airfield status. The app brings airport status, airfield condition, support asset, utility, and incident data into one Grails application that can be built and deployed as a single WAR file.

## Features

- Airport and airfield status dashboards.
- Geospatial links from status records into the map view.
- MapLibre map view backed by GeoServer WFS/GeoJSON layers, including optional GeoAI detection outputs.
- Configurable basemaps, layer selection, feature filtering, fit-to-layer, fullscreen, distance measurement, drawing, and coordinate readout with MGRS support.
- Editable lookup tables for dropdown text used by airport and incident workflows.
- Development bootstrap data for New Mexico airports and airfields, current status, runway surface condition, support assets, utilities, current incidents, and archived incidents.
- Single deployable WAR with the application served from `/GeoStatusBoard`.
- Optional Docker Compose GIS stack for local PostGIS, GeoServer, and GeoAI development.

## Screenshots

![Status app map with incidents, weather, feature popup, and layers panel](docs/images/map-view-incidents-weather-popup-layers.png)

The screenshot above shows the geospatial status map with feature popups, readable status details, weather overlays, incident layers, and the layers panel.

## Technology

- Grails 5.3.3
- Groovy 3.0.11
- GORM 7.3.3
- Gradle 7.6.6 wrapper
- Java 18 runtime
- Spring Security
- H2 development and test databases
- PostGIS and GeoServer for open source GIS deployment
- MapLibre GL JS for the browser map
- Docker Compose for optional local GIS and GeoAI infrastructure

## Project Layout

- `grails-app/` - Root status app configuration, security, home page, map view, and shared application setup.
- `gsb-airport/` - Airport, airfield, utility, and support asset status module.
- `gsb-incidents/` - Incident, current incident, archived incident, and facility damage module.
- `docs/` - Geospatial architecture notes, PostGIS spatialization SQL, and README images.
- `docker/` - Local PostGIS initialization and GeoServer bootstrap scripts.
- `docker-compose.yml` - Optional local PostGIS, GeoServer, and GeoAI services.
- `.env.example` - Local Docker and GIS configuration defaults.
- `dev.ps1` - Convenience commands for the local Docker GIS stack.
- `build.gradle` - Root build, WAR packaging, Java compatibility, and module dependencies.
- `settings.gradle` - Includes the airport and incident modules under the `geospatial-status-board` Gradle root project.

## Repository Map

This repo provides the Grails status-board application, MapLibre map viewer,
GeoServer/PostGIS local stack, and geospatial architecture notes. The companion GeoAI
repo provides the workflow API and asset-detection pipeline used by the map viewer.

- [Geospatial Status Board repo](https://github.com/JosephDillard/geospatial-status-board)
- [Geospatial Status Board README](https://github.com/JosephDillard/geospatial-status-board/blob/master/README.md)
- [Geospatial Status Board Architecture](docs/geospatial-architecture.md)
- [GeoAI Asset Detection Platform repo](https://github.com/JosephDillard/geoai-asset-detection-platform)
- [GeoAI Asset Detection Platform README](https://github.com/JosephDillard/geoai-asset-detection-platform/blob/main/README.md)

## Run Locally

Docker is not required for the normal development path. If no PostGIS profile is enabled, the app uses H2 for the root datasource and the named airport/incident datasources.

Use the Gradle wrapper from the repository root:

```powershell
.\gradlew.bat :bootRun
```

The default local URL is:

```text
http://localhost:8080/GeoStatusBoard
```

To run on the development port used in recent local testing:

```powershell
.\gradlew.bat :bootRun --args="--server.port=18088"
```

Then open:

```text
http://localhost:18088/GeoStatusBoard
```

The default seeded admin account is:

```text
username: admin
password: admin123
```

## Optional Docker GIS Stack

Use Docker when you want local PostGIS and GeoServer for map/WFS integration testing. The Grails app can still run from IntelliJ or `bootRun`.

Start the infrastructure:

```powershell
.\dev.ps1 up
```

Equivalent raw Docker command:

```powershell
docker compose up -d postgis geoserver
```

Start the full dev infrastructure, including the GeoAI API container with
TensorFlow/Keras:

```powershell
.\dev.ps1 up-geoai
```

Default local endpoints:

```text
PostGIS:   localhost:5432/geostatusboard
GeoServer: http://localhost:8081/geoserver
WFS:       http://localhost:8081/geoserver/gsb/ows
GeoAI:     http://localhost:8000
```

Default local credentials:

```text
PostGIS user/password: gsb / gsb
GeoServer user/password: admin / geoserver
```

To customize ports, image tags, credentials, or the WFS URL:

```powershell
Copy-Item .env.example .env
```

Then edit `.env`. The `.env` file is intentionally ignored by Git.

`GEOSERVER_WFS_MAX_FEATURES` controls the GeoServer WFS service cap used by the
bootstrap container. The default is `5000`, while the map viewer requests at least
`geo.viewer.maxFeatures` (`500` by default) for internal WFS layers.

The `geoai` Compose profile builds the sibling GeoAI repo from
`GEOAI_CONTEXT=../geoai-asset-detection-platform`. It bind-mounts that repo's
`src/`, `config/`, `scripts/`, and `sql/` folders for a faster dev loop, plus the
ignored `data/`, `models/`, `outputs/`, and `logs/` folders so downloaded models,
sample COGs, masks, vectors, and API logs remain local developer artifacts.

On first start, the GeoAI container downloads the open-source HF U-Net/Keras road
model, the WHU building segmentation model, and the Taos NAIP sample COG if they
are missing. Set `GEOAI_DOWNLOAD_HF_MODEL=false`,
`GEOAI_DOWNLOAD_HF_BUILDING_MODEL=false`, or `GEOAI_FETCH_SAMPLE_COG=false` in
`.env` to disable any automatic download.

### Keep Grails on H2

Run the app normally:

```powershell
.\gradlew.bat :bootRun
```

This path uses H2. If GeoServer is not running, the map page remains usable for basemaps and tools and reports GeoServer layer failures in the map status panel.

### Run Grails Against PostGIS

Start the Docker infrastructure, then run the app with the `postgis` Spring profile:

```powershell
.\dev.ps1 up
$env:SPRING_PROFILES_ACTIVE = 'postgis'
.\gradlew.bat :bootRun
Remove-Item Env:SPRING_PROFILES_ACTIVE
```

For IntelliJ, set either the VM option:

```text
-Dspring.profiles.active=postgis
```

or the environment variable:

```text
SPRING_PROFILES_ACTIVE=postgis
```

After the app has created the tables in PostGIS, apply the spatial columns/indexes and rerun the GeoServer bootstrap:

```powershell
.\dev.ps1 spatialize
```

The spatialization script adds `geom geometry(Geometry, 4326)` columns and GiST indexes. For the built-in development sample data, it also seeds approximate New Mexico point and polygon geometries so the map draws immediately. Replace those sample geometries with authoritative source geometry for production data.

Useful Docker helper commands:

```powershell
.\dev.ps1 logs
.\dev.ps1 logs-geoai
.\dev.ps1 build-geoai
.\dev.ps1 geoserver-init
.\dev.ps1 down
.\dev.ps1 reset
```

`reset` removes the local Docker volumes and recreates empty PostGIS and GeoServer state.

## Build

Build the full project:

```powershell
.\gradlew.bat clean build
```

The deployable WAR is created at:

```text
build/libs/GeoStatusBoard.war
```

## Deployment Context

The app is configured to run under:

```text
/GeoStatusBoard
```

For example:

```text
http://localhost:8080/GeoStatusBoard
```

## Lookup Data

Dropdown values are managed through editable lookup tables so an administrator can update display text without changing domain constraints or GSP files.

Useful admin routes include:

```text
/GeoStatusBoard/airportLookupOption
/GeoStatusBoard/incidentLookupOption
```

Airport and incident lookup bootstrapping seeds New Mexico airports, airfields, event types, event categories, sources, status values, and agency-style service-owner values for development and test data. Service-owner options focus on FEMA, federal land/fire agencies, New Mexico state agencies, local fire departments, airport authorities, and emergency management organizations.

## Bootstrap Test Data

Bootstrap test data is enabled by default outside production. It adds missing sample rows to development/test tables without duplicating rows on every restart, so existing dev databases can pick up newly added seed data after the app restarts. Synthetic status and incident records only seed outside production. Current seed coverage includes:

- Airport status and current SIT rows for 15 New Mexico locations.
- Runway and airfield surface condition records.
- Engineer and fire fighting support asset records.
- Utility status records.
- Current FACDAM-style incident records.
- Archived incident records.

Bootstrapped locations include Kirtland AFB, Holloman AFB, Cannon AFB, Albuquerque International Sunport, Roswell Air Center, Spaceport America, Las Cruces International Airport, and other New Mexico airfields.

## Geospatial View

The app includes a MapLibre-based geospatial view at:

```text
/GeoStatusBoard/map
```

GSP links can open the map with a selected layer and feature filter, for example:

```text
/GeoStatusBoard/map?layer=airportStatus&field=site_name&value=Kirtland%20AFB
```

The map configuration lives under `geo.viewer`, `geo.geoserver`, and `geo.layers` in `grails-app/conf/application.yml`. The current default basemaps are CARTO Dark Blue and OpenStreetMap, and configured layers include airport status, current airfield status, airfield surface status, NAVAIDs, engineer assets, fire fighting assets, utility status, GeoAI COG footprints, GeoAI detections, current incidents, and incident archive.

The map also includes a compact GeoAI request panel. It loads model choices from the
GeoAI API through same-origin Grails proxy routes, submits the selected model,
workflow, current MapLibre extent, and optional drawn AOI, then polls the returned run
id:

- `GET /GeoStatusBoard/geoAi/options`
- `POST /GeoStatusBoard/geoAi/runs`
- `GET /GeoStatusBoard/geoAi/runs/{run_id}`

Configure the target API with `geo.geoai.apiUrl` or the `GEOAI_API_URL` environment
variable. If GeoAI is unavailable, the map remains usable and the panel shows the
request failure instead of blocking map tools.

When the selected workflow loads PostGIS features, the map refreshes `GeoAI Detections`
and selects the returned API run id in the layer's job filter. Zero-feature runs leave
the existing detection layer intact.

When a GeoAI workflow writes to `public.detected_roads` in the local PostGIS
database, rerun `.\dev.ps1 geoserver-init` to publish `gsb:detected_roads`.
The map exposes it as the `GeoAI Detections` layer under the `GeoAI` category and
adds a job filter under that layer when `job_id` values are present. The COG
inventory footprint table is `public.geoai_cog_footprints` and is exposed as
`COG Footprints`.

The recommended open source GIS stack is:

- PostGIS for geospatial columns and spatial indexes in the operational database.
- GeoServer for publishing database tables as WFS GeoJSON layers.
- MapLibre GL JS for the browser map view.

The Grails domains continue to read and write regular status fields through GORM. GeoServer reads geometry from PostGIS and supplies the map API. Weather, imagery, flight, road, or other external feeds can be added as additional GeoServer-published layers or direct map tile/vector services when the provider terms allow it.

See:

- `docs/postgis-spatialization.sql`
- `docs/geospatial-architecture.md`

## Recent Local Changes

- Added an optional Docker Compose GIS stack for local PostGIS and GeoServer testing.
- Added a GeoAI Docker Compose profile for TensorFlow/Keras road segmentation while Grails runs locally.
- Added an open-source WHU building segmentation workflow for visible Taos NAIP GeoAI detections.
- Added a `postgis` Spring profile while keeping H2 as the default development and test database.
- Added GeoServer WFS timeout handling so missing local GeoServer services fail gracefully in the map status panel.
- Added PostgreSQL-safe table/formula mappings for the local PostGIS development profile.
- Added development sample geometries for the bootstrapped New Mexico records.
- Added editable lookup tables, richer New Mexico bootstrap data, and MapLibre map tools for basemaps, layers, feature filtering, measurement, drawing, fullscreen, MGRS, and coordinate readout.
- Added top-nav health indicators and a MapLibre GeoAI request panel for submitting map-context jobs to the GeoAI workflow API.

## Data Sources

The root app configures the default datasource plus named datasources used by the included modules:

- `dataSource` - Root app data.
- `geodbfour` - Airport, airfield, utility, and support asset data.
- `geodbthree` - Incident data.

Development and test environments use H2 databases by default.

The optional `postgis` Spring profile points all three datasources at the same local PostGIS database so GeoServer can publish airport, asset, utility, and incident tables from one datastore.

The PostGIS profile override lives in:

```text
grails-app/conf/application-postgis.yml
```
