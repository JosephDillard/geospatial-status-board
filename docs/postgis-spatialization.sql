-- PostGIS spatialization for the status app.
--
-- Grails continues to read and write business/status fields through GORM.
-- GeoServer reads the same tables and publishes the geom column to the map API.
--
-- Run this against the PostgreSQL database that backs the operational tables.
-- The table names match the suggested GeoServer layer names in application.yml.

CREATE EXTENSION IF NOT EXISTS postgis;

DO $$
BEGIN
    IF to_regclass('public.index_airfields') IS NOT NULL THEN
        ALTER TABLE public.index_airfields
            ADD COLUMN IF NOT EXISTS geom geometry(Geometry, 4326);
        CREATE INDEX IF NOT EXISTS index_airfields_geom_gix
            ON public.index_airfields USING GIST (geom);
    END IF;

    IF to_regclass('public.runwaydamagepolys') IS NOT NULL THEN
        ALTER TABLE public.runwaydamagepolys
            ADD COLUMN IF NOT EXISTS geom geometry(Geometry, 4326);
        CREATE INDEX IF NOT EXISTS runwaydamagepolys_geom_gix
            ON public.runwaydamagepolys USING GIST (geom);
    END IF;

    IF to_regclass('public.navigationalaid') IS NOT NULL THEN
        ALTER TABLE public.navigationalaid
            ADD COLUMN IF NOT EXISTS geom geometry(Geometry, 4326);
        CREATE INDEX IF NOT EXISTS navigationalaid_geom_gix
            ON public.navigationalaid USING GIST (geom);
    END IF;

    IF to_regclass('public.engineer_assets') IS NOT NULL THEN
        ALTER TABLE public.engineer_assets
            ADD COLUMN IF NOT EXISTS geom geometry(Geometry, 4326);
        CREATE INDEX IF NOT EXISTS engineer_assets_geom_gix
            ON public.engineer_assets USING GIST (geom);
    END IF;

    IF to_regclass('public.fire_fighting_assets') IS NOT NULL THEN
        ALTER TABLE public.fire_fighting_assets
            ADD COLUMN IF NOT EXISTS geom geometry(Geometry, 4326);
        CREATE INDEX IF NOT EXISTS fire_fighting_assets_geom_gix
            ON public.fire_fighting_assets USING GIST (geom);
    END IF;

    IF to_regclass('public.utility_status') IS NOT NULL THEN
        ALTER TABLE public.utility_status
            ADD COLUMN IF NOT EXISTS geom geometry(Geometry, 4326);
        CREATE INDEX IF NOT EXISTS utility_status_geom_gix
            ON public.utility_status USING GIST (geom);
    END IF;

    IF to_regclass('public.afim_event_point_bm0914') IS NOT NULL THEN
        ALTER TABLE public.afim_event_point_bm0914
            ADD COLUMN IF NOT EXISTS geom geometry(Geometry, 4326),
            ADD COLUMN IF NOT EXISTS workflow_status varchar(64);
        CREATE INDEX IF NOT EXISTS afim_event_point_bm0914_geom_gix
            ON public.afim_event_point_bm0914 USING GIST (geom);
    END IF;

    IF to_regclass('public.afim_event_archive') IS NOT NULL THEN
        ALTER TABLE public.afim_event_archive
            ADD COLUMN IF NOT EXISTS geom geometry(Geometry, 4326),
            ADD COLUMN IF NOT EXISTS workflow_status varchar(64),
            ADD COLUMN IF NOT EXISTS archive_action varchar(32),
            ADD COLUMN IF NOT EXISTS archived_at timestamp,
            ADD COLUMN IF NOT EXISTS archived_by varchar(255),
            ADD COLUMN IF NOT EXISTS source_current_id bigint;
        CREATE INDEX IF NOT EXISTS afim_event_archive_geom_gix
            ON public.afim_event_archive USING GIST (geom);
        CREATE INDEX IF NOT EXISTS afim_event_archive_source_current_id_idx
            ON public.afim_event_archive (source_current_id);
        CREATE INDEX IF NOT EXISTS afim_event_archive_archived_at_idx
            ON public.afim_event_archive (archived_at);
    END IF;
END $$;

-- Development/test geometries for the bootstrapped New Mexico sample records.
-- Replace these with authoritative source geometries for production data.
DROP TABLE IF EXISTS pg_temp.gsb_dev_airfield_locations;
CREATE TEMP TABLE gsb_dev_airfield_locations (
    site_name text PRIMARY KEY,
    lon double precision NOT NULL,
    lat double precision NOT NULL
);

INSERT INTO gsb_dev_airfield_locations (site_name, lon, lat) VALUES
    ('Albuquerque International Sunport', -106.6172, 35.0402),
    ('Kirtland AFB', -106.5580, 35.0400),
    ('Holloman AFB', -106.1086, 32.8525),
    ('Cannon AFB', -103.3221, 34.3828),
    ('Santa Fe Regional Airport', -106.0881, 35.6171),
    ('Roswell Air Center', -104.5306, 33.3016),
    ('Las Cruces International Airport', -106.9219, 32.2894),
    ('Lea County Regional Airport', -103.2173, 32.6875),
    ('Four Corners Regional Airport', -108.2299, 36.7412),
    ('Grant County Airport', -108.1560, 32.6365),
    ('Spaceport America', -106.9707, 32.9903),
    ('Double Eagle II Airport', -106.7952, 35.1452),
    ('Alamogordo-White Sands Regional', -105.9906, 32.8399),
    ('Ruidoso Sierra Blanca Regional', -105.5353, 33.4628),
    ('Truth or Consequences Municipal', -107.2717, 33.2369);

UPDATE public.index_airfields target
SET geom = ST_SetSRID(ST_MakePoint(source.lon, source.lat), 4326)
FROM pg_temp.gsb_dev_airfield_locations source
WHERE target.site_name = source.site_name
  AND target.geom IS NULL;

UPDATE public.runwaydamagepolys target
SET geom = ST_Buffer(ST_SetSRID(ST_MakePoint(source.lon, source.lat), 4326)::geography, 750)::geometry
FROM pg_temp.gsb_dev_airfield_locations source
WHERE target.site_name = source.site_name
  AND target.geom IS NULL;

UPDATE public.engineer_assets target
SET geom = ST_SetSRID(ST_MakePoint(source.lon + 0.0100, source.lat + 0.0060), 4326)
FROM pg_temp.gsb_dev_airfield_locations source
WHERE target.airfield_name = source.site_name
  AND target.geom IS NULL;

UPDATE public.fire_fighting_assets target
SET geom = ST_SetSRID(ST_MakePoint(source.lon - 0.0080, source.lat + 0.0040), 4326)
FROM pg_temp.gsb_dev_airfield_locations source
WHERE target.airfield_name = source.site_name
  AND target.geom IS NULL;

UPDATE public.utility_status target
SET geom = ST_SetSRID(ST_MakePoint(source.lon, source.lat - 0.0070), 4326)
FROM pg_temp.gsb_dev_airfield_locations source
WHERE target.airfield_name = source.site_name
  AND target.geom IS NULL;

UPDATE public.afim_event_point_bm0914 target
SET geom = ST_SetSRID(ST_MakePoint(source.lon + 0.0150, source.lat - 0.0100), 4326)
FROM pg_temp.gsb_dev_airfield_locations source
WHERE target.base = source.site_name
  AND target.geom IS NULL;

UPDATE public.afim_event_archive target
SET geom = ST_SetSRID(ST_MakePoint(source.lon - 0.0140, source.lat - 0.0100), 4326)
FROM pg_temp.gsb_dev_airfield_locations source
WHERE target.base = source.site_name
  AND target.geom IS NULL;

DROP TABLE IF EXISTS pg_temp.gsb_dev_airfield_locations;

-- After geometry is populated, publish these tables in GeoServer under the
-- configured workspace, then verify WFS returns GeoJSON:
--
-- /geoserver/gsb/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=gsb:index_airfields&outputFormat=application/json
--
-- If GeoServer advertises different attribute names, update geo.layers.*.idField
-- and geo.layers.*.labelField in grails-app/conf/application.yml.
