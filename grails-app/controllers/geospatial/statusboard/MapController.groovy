package geospatial.statusboard

import grails.core.GrailsApplication
import grails.plugin.springsecurity.annotation.Secured
import gsb.incidents.IncidentLookupOption
import groovy.json.JsonOutput

@Secured(['ROLE_USER'])
class MapController {

    GrailsApplication grailsApplication

    def index() {
        Map geoConfig = asMap(grailsApplication.config.geo)
        Map viewerConfig = asMap(geoConfig.viewer)
        Map geoserverConfig = asMap(geoConfig.geoserver)
        Map geoaiConfig = asMap(geoConfig.geoai)
        Map gatewayConfig = asMap(geoConfig.gateway)
        Map placeSearchConfig = asMap(geoConfig.placeSearch)
        Map layers = normalizeLayers(asMap(geoConfig.layers), asInteger(viewerConfig.maxFeatures, 500))
        Map externalLayers = normalizeExternalLayers(asMap(geoConfig.externalLayers))
        Map basemaps = normalizeBasemaps(asMap(viewerConfig.basemaps), viewerConfig)
        Map tools = normalizeTools(asMap(viewerConfig.tools))
        String selectedLayer = params.layer?.toString()
        String selectedBasemap = params.basemap?.toString() ?: viewerConfig.selectedBasemap?.toString()
        List selectedCenter = normalizeCenter(params.centerLng, params.centerLat, viewerConfig.center)
        BigDecimal selectedZoom = asBigDecimal(params.zoom, asBigDecimal(viewerConfig.zoom, new BigDecimal('6')))

        if (!selectedLayer || !layers.containsKey(selectedLayer)) {
            selectedLayer = layers.find { String key, Map layer -> layer.enabled }?.key ?: layers.keySet().find()
        }
        if (!selectedBasemap || !basemaps.containsKey(selectedBasemap)) {
            selectedBasemap = basemaps.keySet().find()
        }

        Map selectedLayerConfig = selectedLayer ? layers[selectedLayer] as Map : [:]
        String selectedField = params.field?.toString() ?: selectedLayerConfig.idField?.toString()
        String selectedValue = params.value?.toString() ?: params.featureId?.toString()
        if (selectedLayer && (params.layer || selectedValue) && layers[selectedLayer] instanceof Map) {
            layers[selectedLayer].enabled = true
        }

        Map mapConfig = [
            wfsUrl          : geoserverConfig.wfsUrl?.toString() ?: '',
            defaultSrs      : geoserverConfig.defaultSrs?.toString() ?: 'EPSG:4326',
            requestTimeoutMs: asInteger(geoserverConfig.requestTimeoutMs, 5000),
            center          : selectedCenter,
            zoom            : selectedZoom,
            zoomLevels      : normalizeZoomLevels(viewerConfig.zoomLevels),
            maxFeatures     : viewerConfig.maxFeatures ?: 500,
            selectedLayer   : selectedLayer,
            selectedBasemap : selectedBasemap,
            filter          : [
                field: selectedField ?: '',
                value: selectedValue ?: ''
            ],
            layers          : layers,
            externalLayers  : externalLayers,
            basemaps        : basemaps,
            geoai           : [
                optionsUrl      : createLink(uri: '/geoAi/options'),
                jobsUrl         : createLink(uri: '/geoAi/jobs'),
                runsUrl         : createLink(uri: '/geoAi/runs'),
                runStatusUrlBase: createLink(uri: '/geoAi/runs') + '/',
                apiUrl          : geoaiConfig.apiUrl?.toString() ?: '',
                requestTimeoutMs: asInteger(geoaiConfig.requestTimeoutMs, 5000)
            ],
            gateway         : [
                enabled         : asBoolean(gatewayConfig.enabled, true),
                hubUrl          : gatewayConfig.hubUrl?.toString() ?: '',
                reconnectDelayMs: asInteger(gatewayConfig.reconnectDelayMs, 5000),
                eventName       : gatewayConfig.eventName?.toString() ?: 'layer.refresh_requested'
            ],
            placeSearch     : [
                geonamesUsername     : placeSearchConfig.geonamesUsername?.toString() ?: System.getenv('GEONAMES_USERNAME') ?: '',
                resultLimit          : asInteger(placeSearchConfig.resultLimit, 5),
                wikipediaRadiusMeters: asInteger(placeSearchConfig.wikipediaRadiusMeters, 10000)
            ],
            tools           : tools,
            coordinateDigits: viewerConfig.coordinateDigits ?: 6,
            mgrsAccuracy    : viewerConfig.mgrsAccuracy ?: 5
        ]

        [
            mapConfigJson : JsonOutput.toJson(mapConfig),
            incidentLookupOptionsJson: JsonOutput.toJson(incidentLookupOptions()),
            layers        : layers,
            externalLayers: externalLayers,
            basemaps      : basemaps,
            selectedLayer : selectedLayer,
            selectedBasemap: selectedBasemap,
            selectedField : selectedField ?: '',
            selectedValue : selectedValue ?: '',
            mapLibreJsUrl : viewerConfig.mapLibreJsUrl?.toString() ?: 'https://unpkg.com/maplibre-gl/dist/maplibre-gl.js',
            mapLibreCssUrl: viewerConfig.mapLibreCssUrl?.toString() ?: 'https://unpkg.com/maplibre-gl/dist/maplibre-gl.css',
            mapDrawJsUrl  : viewerConfig.mapDrawJsUrl?.toString() ?: '',
            mapDrawCssUrl : viewerConfig.mapDrawCssUrl?.toString() ?: '',
            mgrsJsUrl     : viewerConfig.mgrsJsUrl?.toString() ?: '',
            drawEnabled   : tools.drawing,
            mgrsEnabled   : tools.mgrs
        ]
    }

    private Map normalizeLayers(Map rawLayers, Integer defaultMaxFeatures = 500) {
        rawLayers.collectEntries { Object key, Object value ->
            String layerKey = key.toString()
            Map layer = asMap(value)
            [
                layerKey,
                [
                    title       : layer.title?.toString() ?: layerKey,
                    typeName    : layer.typeName?.toString() ?: layerKey,
                    idField     : layer.idField?.toString() ?: 'id',
                    labelField  : layer.labelField?.toString() ?: layer.idField?.toString() ?: 'id',
                    geometryType: layer.geometryType?.toString() ?: 'Geometry',
                    color       : layer.color?.toString() ?: '#2563eb',
                    iconSet     : layer.iconSet?.toString() ?: '',
                    iconField   : layer.iconField?.toString() ?: '',
                    filterField : layer.filterField?.toString() ?: '',
                    filterLabel : layer.filterLabel?.toString() ?: '',
                    filterAllLabel: layer.filterAllLabel?.toString() ?: '',
                    filterFields: normalizeStringList(layer.filterFields),
                    popupFields : normalizeStringList(layer.popupFields),
                    maxFeatures : layer.maxFeatures ?: defaultMaxFeatures,
                    category    : layer.category?.toString() ?: 'Internal',
                    enabled     : asBoolean(layer.enabled, false)
                ]
            ]
        }
    }

    private Map normalizeExternalLayers(Map rawLayers) {
        rawLayers.collectEntries { Object key, Object value ->
            String layerKey = key.toString()
            Map layer = asMap(value)
            [
                layerKey,
                [
                    title      : layer.title?.toString() ?: layerKey,
                    category   : layer.category?.toString() ?: 'External',
                    kind       : layer.kind?.toString() ?: 'raster',
                    tilesUrl   : layer.tilesUrl?.toString() ?: '',
                    endpoint   : layer.endpoint?.toString() ?: '',
                    attribution: layer.attribution?.toString() ?: '',
                    idField    : layer.idField?.toString() ?: 'id',
                    labelField : layer.labelField?.toString() ?: layer.idField?.toString() ?: 'id',
                    geometryType: layer.geometryType?.toString() ?: 'Geometry',
                    opacity    : layer.opacity ?: 0.7,
                    color      : layer.color?.toString() ?: '#facc15',
                    fillOpacity: layer.fillOpacity ?: 0.24,
                    lineWidth  : layer.lineWidth ?: 2,
                    circleRadius: layer.circleRadius ?: 5,
                    enabled    : asBoolean(layer.enabled, false),
                    maxFeatures: layer.maxFeatures ?: 500,
                    note       : layer.note?.toString() ?: ''
                ]
            ]
        }
    }

    private List<String> normalizeStringList(Object rawValues) {
        if (!(rawValues instanceof Collection)) {
            return []
        }

        rawValues.collect { Object value -> value?.toString()?.trim() }.findAll { String value -> value }
    }

    private Map normalizeBasemaps(Map rawBasemaps, Map viewerConfig) {
        Map basemaps = rawBasemaps.collectEntries { Object key, Object value ->
            String basemapKey = key.toString()
            Map basemap = asMap(value)
            [
                basemapKey,
                [
                    title      : basemap.title?.toString() ?: basemapKey,
                    buttonLabel: basemap.buttonLabel?.toString() ?: basemap.title?.toString() ?: basemapKey,
                    tilesUrl   : basemap.tilesUrl?.toString() ?: '',
                    attribution: basemap.attribution?.toString() ?: '',
                    background : basemap.background?.toString() ?: '#06162f',
                    opacity    : basemap.opacity ?: 1,
                    preview    : basemap.preview?.toString() ?: basemap.background?.toString() ?: '#06162f',
                    previewImage: basemap.previewImage?.toString() ?: ''
                ]
            ]
        }

        if (basemaps) {
            return basemaps
        }

        [
            osmLight: [
                title      : 'OpenStreetMap',
                buttonLabel: 'OSM',
                tilesUrl   : viewerConfig.osmTilesUrl?.toString() ?: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                attribution: '(c) OpenStreetMap contributors',
                background : '#dce7f3',
                opacity    : 1,
                preview    : 'linear-gradient(135deg, #e8f1f5 0%, #cddfb8 50%, #8fb7d3 100%)',
                previewImage: ''
            ]
        ]
    }

    private Map normalizeTools(Map rawTools) {
        [
            basemapSelector: asBoolean(rawTools.basemapSelector, true),
            layerList      : asBoolean(rawTools.layerList, true),
            coordinates    : asBoolean(rawTools.coordinates, true),
            mgrs           : asBoolean(rawTools.mgrs, true),
            dms            : asBoolean(rawTools.dms, true),
            measureDistance: asBoolean(rawTools.measureDistance, true),
            drawing        : asBoolean(rawTools.drawing, true),
            drawArea       : asBoolean(rawTools.drawArea, true),
            fullscreen     : asBoolean(rawTools.fullscreen, true),
            fitLayer       : asBoolean(rawTools.fitLayer, true),
            createIncidents: asBoolean(rawTools.createIncidents, true),
            geoaiRequests  : asBoolean(rawTools.geoaiRequests, true),
            placeSearch    : asBoolean(rawTools.placeSearch, true)
        ]
    }

    private Map incidentLookupOptions() {
        [
            eventTypes     : IncidentLookupOption.valuesFor('incident.eventType'),
            eventCategories: IncidentLookupOption.valuesFor('incident.eventCategory'),
            bases          : IncidentLookupOption.valuesFor('incident.base'),
            yesNoNa        : IncidentLookupOption.valuesFor('incident.yesNoNa'),
            sources        : IncidentLookupOption.valuesFor('incident.source')
        ]
    }

    private List<BigDecimal> normalizeZoomLevels(Object rawLevels) {
        List levels = rawLevels instanceof Collection ? rawLevels as List : (3..18).toList()

        levels.collect { Object value ->
            value instanceof Number ? value as BigDecimal : value?.toString()?.isNumber() ? value.toString() as BigDecimal : null
        }.findAll { BigDecimal value ->
            value != null
        }.unique().sort()
    }

    private List<BigDecimal> normalizeCenter(Object lngValue, Object latValue, Object rawDefaultCenter) {
        List fallback = rawDefaultCenter instanceof Collection && rawDefaultCenter.size() >= 2
            ? rawDefaultCenter as List
            : [-106.0, 34.5]
        BigDecimal defaultLng = asBigDecimal(fallback[0], new BigDecimal('-106.0'))
        BigDecimal defaultLat = asBigDecimal(fallback[1], new BigDecimal('34.5'))
        BigDecimal lng = asBigDecimal(lngValue, defaultLng)
        BigDecimal lat = asBigDecimal(latValue, defaultLat)

        [lng, lat]
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
