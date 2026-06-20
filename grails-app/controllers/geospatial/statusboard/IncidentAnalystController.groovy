package geospatial.statusboard

import grails.core.GrailsApplication
import grails.plugin.springsecurity.annotation.Secured
import groovy.json.JsonOutput

@Secured(['ROLE_USER'])
class IncidentAnalystController {

    GrailsApplication grailsApplication

    def index() {
        Map geoConfig = asMap(grailsApplication.config.geo)
        Map viewerConfig = asMap(geoConfig.viewer)
        Map incidentConfig = asMap(geoConfig.incidentAnalyst)

        if (!asBoolean(incidentConfig.enabled, true)) {
            response.status = 404
            render view: '/notFound'
            return
        }

        Map featureConfig = [
            basePath      : createLink(uri: '/incident-analyst'),
            analyzeUrl    : createLink(uri: '/incident-analyst/api/analyze'),
            supportUrl    : createLink(uri: '/incident-analyst/api/osm/support'),
            initialPoint  : [
                latitude : asBigDecimal(incidentConfig.latitude, new BigDecimal('35.6870')),
                longitude: asBigDecimal(incidentConfig.longitude, new BigDecimal('-105.9378'))
            ],
            corridorBounds: [[-107.15, 35.45], [-104.1, 37.08]],
            defaultZoom   : asBigDecimal(incidentConfig.zoom, new BigDecimal('7.25')),
            minZoom       : asInteger(incidentConfig.minZoom, 6),
            maxZoom       : asInteger(incidentConfig.maxZoom, 14),
            radiusKm      : asInteger(incidentConfig.radiusKm, 220),
            supportRadiusM: asInteger(incidentConfig.supportRadiusM, 20000),
            maxIncidents  : asInteger(incidentConfig.maxIncidents, 20),
            selectedBasemap: viewerConfig.selectedBasemap?.toString() ?: 'osmLight',
            basemaps      : normalizeBasemaps(asMap(viewerConfig.basemaps), viewerConfig),
            tools         : [
                coordinates    : true,
                mgrs           : asBoolean(asMap(viewerConfig.tools).mgrs, true),
                dms            : asBoolean(asMap(viewerConfig.tools).dms, true),
                measureDistance: true,
                layerList      : true,
                basemapSelector: true,
                fitLayer       : true
            ]
        ]

        [
            incidentAnalystConfigJson: JsonOutput.toJson(featureConfig),
            basemaps                 : featureConfig.basemaps,
            selectedBasemap          : featureConfig.selectedBasemap,
            mapLibreJsUrl            : viewerConfig.mapLibreJsUrl?.toString() ?: 'https://unpkg.com/maplibre-gl@5.24.0/dist/maplibre-gl.js',
            mapLibreCssUrl           : viewerConfig.mapLibreCssUrl?.toString() ?: 'https://unpkg.com/maplibre-gl@5.24.0/dist/maplibre-gl.css',
            mgrsJsUrl                : viewerConfig.mgrsJsUrl?.toString() ?: ''
        ]
    }

    def analyze() {
        proxyBridgeGet('/api/analyze')
    }

    def osmSupport() {
        proxyBridgeGet('/api/osm/support')
    }

    private void proxyBridgeGet(String path) {
        Map incidentConfig = asMap(asMap(grailsApplication.config.geo).incidentAnalyst)
        if (!asBoolean(incidentConfig.enabled, true)) {
            response.status = 404
            renderJson([status: 'error', message: 'Incident Analyst is disabled'])
            return
        }

        String bridgeUrl = incidentConfig.bridgeUrl?.toString()?.replaceAll('/+$', '') ?: 'http://127.0.0.1:8775/incident-analyst'
        int timeoutMs = asInteger(incidentConfig.requestTimeoutMs, 8000)
        String query = request.queryString ? "?${request.queryString}" : ''
        HttpURLConnection connection = null

        try {
            connection = new URL("${bridgeUrl}${path}${query}").openConnection() as HttpURLConnection
            connection.connectTimeout = timeoutMs
            connection.readTimeout = timeoutMs
            connection.requestMethod = 'GET'
            connection.setRequestProperty('Accept', 'application/json')

            int code = connection.responseCode
            String text = readResponse(connection, code)
            response.status = code
            render(contentType: 'application/json', text: text ?: '{}')
        } catch (Exception ex) {
            response.status = 503
            renderJson([
                status : 'error',
                message: ex.message ?: ex.class.simpleName,
                service: 'Incident Analyst bridge'
            ])
        } finally {
            connection?.disconnect()
        }
    }

    private String readResponse(HttpURLConnection connection, int code) {
        InputStream stream = code >= 400 ? connection.errorStream : connection.inputStream
        stream ? stream.getText('UTF-8') : ''
    }

    private void renderJson(Map payload) {
        render(contentType: 'application/json', text: JsonOutput.toJson(payload))
    }

    private Map normalizeBasemaps(Map rawBasemaps, Map viewerConfig) {
        Map basemaps = rawBasemaps.collectEntries { Object key, Object value ->
            String basemapKey = key.toString()
            Map basemap = asMap(value)
            [
                basemapKey,
                [
                    title       : basemap.title?.toString() ?: basemapKey,
                    buttonLabel : basemap.buttonLabel?.toString() ?: basemap.title?.toString() ?: basemapKey,
                    tilesUrl    : basemap.tilesUrl?.toString() ?: '',
                    attribution : basemap.attribution?.toString() ?: '',
                    background  : basemap.background?.toString() ?: '#06162f',
                    opacity     : basemap.opacity ?: 1,
                    preview     : basemap.preview?.toString() ?: basemap.background?.toString() ?: '#06162f',
                    previewImage: basemap.previewImage?.toString() ?: ''
                ]
            ]
        }

        if (basemaps) {
            return basemaps
        }

        [
            osmLight: [
                title       : 'OpenStreetMap',
                buttonLabel : 'OSM',
                tilesUrl    : viewerConfig.osmTilesUrl?.toString() ?: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                attribution : '(c) OpenStreetMap contributors',
                background  : '#dce7f3',
                opacity     : 1,
                preview     : 'linear-gradient(135deg, #e8f1f5 0%, #cddfb8 50%, #8fb7d3 100%)',
                previewImage: ''
            ]
        ]
    }

    private Map asMap(Object value) {
        if (value instanceof Map) {
            return value.collectEntries { Object key, Object entryValue ->
                [key.toString(), entryValue]
            }
        }

        [:]
    }

    private boolean asBoolean(Object value, boolean defaultValue) {
        if (value == null) {
            return defaultValue
        }

        value instanceof Boolean ? value : value.toString().toBoolean()
    }

    private int asInteger(Object value, int defaultValue) {
        if (value == null) {
            return defaultValue
        }

        if (value instanceof Number) {
            return value as int
        }

        value.toString().isInteger() ? value.toString() as int : defaultValue
    }

    private BigDecimal asBigDecimal(Object value, BigDecimal defaultValue) {
        if (value == null) {
            return defaultValue
        }

        if (value instanceof Number) {
            return value as BigDecimal
        }

        try {
            return new BigDecimal(value.toString())
        } catch (ignored) {
            return defaultValue
        }
    }
}
