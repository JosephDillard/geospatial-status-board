#!/bin/sh
set -eu

REST_URL="${GEOSERVER_REST_URL:-http://geoserver:8080/geoserver/rest}"
ADMIN_USER="${GEOSERVER_ADMIN_USER:-admin}"
ADMIN_PASSWORD="${GEOSERVER_ADMIN_PASSWORD:-geoserver}"
WORKSPACE="${GEOSERVER_WORKSPACE:-gsb}"
STORE="${GEOSERVER_STORE:-postgis}"
POSTGIS_HOST="${POSTGIS_HOST:-postgis}"
POSTGIS_PORT="${POSTGIS_PORT:-5432}"
POSTGIS_DB="${POSTGIS_DB:-geostatusboard}"
POSTGIS_USER="${POSTGIS_USER:-gsb}"
POSTGIS_PASSWORD="${POSTGIS_PASSWORD:-gsb}"
POSTGIS_SCHEMA="${POSTGIS_SCHEMA:-public}"
GEOSERVER_WFS_MAX_FEATURES="${GEOSERVER_WFS_MAX_FEATURES:-5000}"

auth() {
  curl -sS -u "${ADMIN_USER}:${ADMIN_PASSWORD}" "$@"
}

xml_escape() {
  printf '%s' "$1" | sed \
    -e 's/&/\&amp;/g' \
    -e 's/</\&lt;/g' \
    -e 's/>/\&gt;/g' \
    -e "s/'/\&apos;/g" \
    -e 's/"/\&quot;/g'
}

wait_for_geoserver() {
  i=1
  while [ "$i" -le 60 ]; do
    if auth -f "${REST_URL}/about/version.xml" >/dev/null 2>&1; then
      return 0
    fi

    echo "Waiting for GeoServer REST API (${i}/60)..."
    i=$((i + 1))
    sleep 2
  done

  echo "GeoServer REST API did not become available. Start GeoServer and rerun this tool service."
  exit 0
}

ensure_workspace() {
  if auth -f "${REST_URL}/workspaces/${WORKSPACE}.xml" >/dev/null 2>&1; then
    echo "GeoServer workspace '${WORKSPACE}' already exists."
    return 0
  fi

  workspace_xml="<workspace><name>$(xml_escape "$WORKSPACE")</name></workspace>"
  auth -f -XPOST -H "Content-Type: text/xml" --data "$workspace_xml" "${REST_URL}/workspaces" >/dev/null
  echo "Created GeoServer workspace '${WORKSPACE}'."
}

ensure_datastore() {
  datastore_xml=$(cat <<EOF
<dataStore>
  <name>$(xml_escape "$STORE")</name>
  <enabled>true</enabled>
  <connectionParameters>
    <entry key="dbtype">postgis</entry>
    <entry key="host">$(xml_escape "$POSTGIS_HOST")</entry>
    <entry key="port">$(xml_escape "$POSTGIS_PORT")</entry>
    <entry key="database">$(xml_escape "$POSTGIS_DB")</entry>
    <entry key="schema">$(xml_escape "$POSTGIS_SCHEMA")</entry>
    <entry key="user">$(xml_escape "$POSTGIS_USER")</entry>
    <entry key="passwd">$(xml_escape "$POSTGIS_PASSWORD")</entry>
    <entry key="Expose primary keys">true</entry>
    <entry key="validate connections">true</entry>
  </connectionParameters>
</dataStore>
EOF
)

  if auth -f "${REST_URL}/workspaces/${WORKSPACE}/datastores/${STORE}.xml" >/dev/null 2>&1; then
    auth -f -XPUT -H "Content-Type: text/xml" --data "$datastore_xml" \
      "${REST_URL}/workspaces/${WORKSPACE}/datastores/${STORE}.xml" >/dev/null
    echo "Updated GeoServer PostGIS store '${STORE}'."
  else
    auth -f -XPOST -H "Content-Type: text/xml" --data "$datastore_xml" \
      "${REST_URL}/workspaces/${WORKSPACE}/datastores" >/dev/null
    echo "Created GeoServer PostGIS store '${STORE}'."
  fi
}

configure_wfs_service() {
  current_xml="$(auth -f "${REST_URL}/services/wfs/settings.xml" 2>/dev/null || true)"
  if [ -n "$current_xml" ]; then
    if printf '%s' "$current_xml" | grep -q '<maxFeatures>'; then
      wfs_xml="$(printf '%s' "$current_xml" | sed "s|<maxFeatures>[^<]*</maxFeatures>|<maxFeatures>$(xml_escape "$GEOSERVER_WFS_MAX_FEATURES")</maxFeatures>|")"
    else
      wfs_xml="$(printf '%s' "$current_xml" | sed "s|</wfs>|<maxFeatures>$(xml_escape "$GEOSERVER_WFS_MAX_FEATURES")</maxFeatures></wfs>|")"
    fi
  else
    wfs_xml=$(cat <<EOF
<wfs>
  <enabled>true</enabled>
  <name>WFS</name>
  <serviceLevel>COMPLETE</serviceLevel>
  <maxFeatures>$(xml_escape "$GEOSERVER_WFS_MAX_FEATURES")</maxFeatures>
  <featureBounding>true</featureBounding>
</wfs>
EOF
)
  fi

  auth -f -XPUT -H "Content-Type: text/xml" --data "$wfs_xml" \
    "${REST_URL}/services/wfs/settings.xml" >/dev/null
  echo "Configured GeoServer WFS maxFeatures=${GEOSERVER_WFS_MAX_FEATURES}."
}

publish_feature_type() {
  table_name="$1"
  title="$2"

  if auth -f "${REST_URL}/workspaces/${WORKSPACE}/datastores/${STORE}/featuretypes/${table_name}.xml" >/dev/null 2>&1; then
    echo "GeoServer feature type '${WORKSPACE}:${table_name}' already exists."
    return 0
  fi

  feature_xml=$(cat <<EOF
<featureType>
  <name>$(xml_escape "$table_name")</name>
  <nativeName>$(xml_escape "$table_name")</nativeName>
  <title>$(xml_escape "$title")</title>
  <srs>EPSG:4326</srs>
  <enabled>true</enabled>
</featureType>
EOF
)

  if auth -f -XPOST -H "Content-Type: text/xml" --data "$feature_xml" \
    "${REST_URL}/workspaces/${WORKSPACE}/datastores/${STORE}/featuretypes" >/dev/null 2>&1; then
    echo "Published GeoServer feature type '${WORKSPACE}:${table_name}'."
  else
    echo "Skipped '${table_name}'. Run the Grails app with the postgis profile, spatialize the database, then rerun geoserver-init."
  fi
}

wait_for_geoserver
ensure_workspace
ensure_datastore
configure_wfs_service

publish_feature_type "index_airfields" "Airport Status"
publish_feature_type "runwaydamagepolys" "Airfield Surface Status"
publish_feature_type "navigationalaid" "NAVAIDs"
publish_feature_type "engineer_assets" "Engineer Assets"
publish_feature_type "fire_fighting_assets" "Fire Fighting Assets"
publish_feature_type "utility_status" "Utility Status"
publish_feature_type "geoai_cog_footprints" "GeoAI COG Footprints"
publish_feature_type "detected_roads" "GeoAI Detections"
publish_feature_type "current_incidents" "Current Incidents"
publish_feature_type "archive_incidents" "Archive Incidents"

echo "GeoServer bootstrap complete."
