package geospatial.statusboard

import grails.core.GrailsApplication
import grails.plugin.springsecurity.annotation.Secured

import java.net.URLEncoder

@Secured(['ROLE_USER'])
class HomeController {

    GrailsApplication grailsApplication
    def springSecurityService

    def index() {
        def authentication = springSecurityService.authentication
        Map geoConfig = asMap(grailsApplication.config.geo)
        Map geoserverConfig = asMap(geoConfig.geoserver)
        Map geoaiConfig = asMap(geoConfig.geoai)
        Map gatewayConfig = asMap(geoConfig.gateway)
        Map openclawConfig = asMap(geoConfig.openclaw)
        Map incidentAnalystConfig = asMap(geoConfig.incidentAnalyst)

        [
            username        : authentication?.name,
            roles           : authentication?.authorities*.authority?.sort() ?: [],
            appLinks        : appLinks(),
            apiLinks        : apiLinks(geoConfig, geoserverConfig, geoaiConfig, gatewayConfig, openclawConfig, incidentAnalystConfig),
            integrationLinks: integrationLinks(geoserverConfig, geoaiConfig, gatewayConfig, openclawConfig, incidentAnalystConfig)
        ]
    }

    private List<Map> appLinks() {
        [
            [label: 'Home Dashboard', controller: 'home', action: 'index', description: 'Main launch hub for application pages, APIs, and service consoles.'],
            [label: 'Map View', controller: 'map', action: 'index', description: 'Shared operational map with layers, plotting, Wiki/GeoNames, LLM, response support, and MGRS tools.'],
            [label: 'Map Assistant Demo', controller: 'assistant', action: 'index', description: 'OpenClaw-ready map command assistant for safe map actions and reviewed incident drafts.'],
            [label: 'Incident Analyst', uri: '/incident-analyst', description: 'Focused incident review map using the same map tools with risk and support review.'],
            [label: 'Current Incidents Table', controller: 'currentIncidents', action: 'index', description: 'Table review and filtering for active incident records.'],
            [label: 'Incident Kanban', controller: 'currentIncidents', action: 'board', description: 'Workflow board for moving incidents through review states.'],
            [label: 'Create Current Incident', controller: 'currentIncidents', action: 'create', description: 'Manual form for creating a new incident record.'],
            [label: 'Archive Incidents', controller: 'archiveIncidents', action: 'index', description: 'Append-only history of created, updated, moved, and deleted incidents.'],
            [label: 'Airport Status', controller: 'airportStatus', action: 'index', description: 'Airfield status records with map handoff links.'],
            [label: 'Create Airport Status', controller: 'airportStatus', action: 'create', description: 'Manual airport status entry form.'],
            [label: 'Current Airfield Status', controller: 'currentSIT', action: 'index', description: 'Current situation table for airfield posture.'],
            [label: 'Airfield Surface Status', controller: 'airfieldSurfaceStatus', action: 'index', description: 'Runway, taxiway, and surface condition records.'],
            [label: 'Create Surface Status', controller: 'airfieldSurfaceStatus', action: 'create', description: 'Manual surface status entry form.'],
            [label: 'NAVAIDs', controller: 'navaid', action: 'index', description: 'Navigation aid status records.'],
            [label: 'Engineer Assets', controller: 'engineerAssets', action: 'index', description: 'Engineer support asset inventory.'],
            [label: 'Create Engineer Asset', controller: 'engineerAssets', action: 'create', description: 'Manual engineer asset entry form.'],
            [label: 'Fire Fighting Assets', controller: 'fireFightingAssets', action: 'index', description: 'Fire and emergency response asset inventory.'],
            [label: 'Create Fire Fighting Asset', controller: 'fireFightingAssets', action: 'create', description: 'Manual fire fighting asset entry form.'],
            [label: 'Airport Lookup Options', controller: 'airportLookupOption', action: 'index', description: 'Editable airport dropdown and lookup values.'],
            [label: 'Create Airport Lookup', controller: 'airportLookupOption', action: 'create', description: 'Manual airport lookup option entry form.'],
            [label: 'Incident Lookup Options', controller: 'incidentLookupOption', action: 'index', description: 'Editable incident dropdown and lookup values.'],
            [label: 'Create Incident Lookup', controller: 'incidentLookupOption', action: 'create', description: 'Manual incident lookup option entry form.'],
            [label: 'App Admin', controller: 'appAdmin', action: 'index', description: 'Admin-managed banner text and quick links.']
        ]
    }

    private List<Map> apiLinks(
        Map geoConfig,
        Map geoserverConfig,
        Map geoaiConfig,
        Map gatewayConfig,
        Map openclawConfig,
        Map incidentAnalystConfig
    ) {
        String geoaiUrl = trimTrailingSlash(geoaiConfig.apiUrl?.toString())
        String geoserverWfsUrl = geoserverConfig.wfsUrl?.toString()
        String gatewayHealthUrl = gatewayHealthUrl(gatewayConfig)
        String openclawHealthUrl = openclawHealthUrl(openclawConfig)
        String openclawReadyUrl = openclawReadyUrl(openclawConfig)
        Map currentIncidentsLayer = asMap(asMap(geoConfig.layers).currentIncidents)
        String currentIncidentsTypeName = currentIncidentsLayer.typeName?.toString() ?: 'gsb:current_incidents'

        [
            [label: 'Service Health API', method: 'GET', uri: '/geoHealth/index', description: 'JSON status for GeoServer, PostGIS, GeoAI, Data Gateway, and OpenClaw.'],
            [label: 'Assistant Tool Catalog', method: 'GET', uri: '/assistant/tools', description: 'Allow-listed map assistant tool/action catalog.'],
            [label: 'Assistant Plan API', method: 'POST', uri: '/assistant/plan', description: 'Turns a prompt and map context into reviewed map actions.'],
            [label: 'GeoAI Options Proxy', method: 'GET', uri: '/geoAi/options', description: 'Status-board proxy for available GeoAI models and workflows.'],
            [label: 'GeoAI Jobs Proxy', method: 'GET', uri: '/geoAi/jobs', description: 'Status-board proxy for known GeoAI detection jobs.'],
            [label: 'Incident Analysis Proxy', method: 'GET', uri: '/incident-analyst/api/analyze?latitude=35.687&longitude=-105.938&radius_km=220', description: 'Status-board proxy into the Incident Analyst MCP bridge analysis workflow.'],
            [label: 'Response Support Proxy', method: 'GET', uri: '/incident-analyst/api/osm/support?latitude=35.687&longitude=-105.938&radius_m=20000', description: 'OpenStreetMap/local fallback support lookup used by the response support map tool.'],
            [label: 'GeoAI API Health', method: 'GET', url: appendPath(geoaiUrl, '/health'), description: 'Direct GeoAI workflow service health response.'],
            [label: 'GeoAI Run Options', method: 'GET', url: appendPath(geoaiUrl, '/run-options'), description: 'Direct GeoAI model and workflow options.'],
            [label: 'GeoAI Workflows', method: 'GET', url: appendPath(geoaiUrl, '/workflows'), description: 'Direct GeoAI workflow catalog.'],
            [label: 'GeoAI Runs', method: 'GET', url: appendPath(geoaiUrl, '/runs'), description: 'Direct GeoAI run history.'],
            [label: 'GeoAI OpenAPI JSON', method: 'GET', url: appendPath(geoaiUrl, '/openapi.json'), description: 'Machine-readable GeoAI API schema.'],
            [label: 'GeoAI Label Package Download', method: 'GET', url: appendPath(geoaiUrl, '/training/export/package'), description: 'Download the QGIS label package from the GeoAI training workflow.'],
            [label: 'GeoAI Imagery Download', method: 'GET', url: appendPath(geoaiUrl, '/training/export/imagery'), description: 'Download the configured training COG imagery.'],
            [label: 'GeoAI OSM Buildings Download', method: 'GET', url: appendPath(geoaiUrl, '/training/export/osm-buildings'), description: 'Download OpenStreetMap building footprints as a GeoPackage.'],
            [label: 'GeoAI Training Chips Download', method: 'GET', url: appendPath(geoaiUrl, '/training/export/chips.zip'), description: 'Download generated training chips when they have been exported.'],
            [label: 'GeoServer WFS Capabilities', method: 'GET', url: withQuery(geoserverWfsUrl, [
                service: 'WFS',
                version: '1.0.0',
                request: 'GetCapabilities'
            ]), description: 'GeoServer WFS service capabilities document.'],
            [label: 'GeoServer Current Incidents GeoJSON', method: 'GET', url: withQuery(geoserverWfsUrl, [
                service     : 'WFS',
                version     : '1.0.0',
                request     : 'GetFeature',
                typeName    : currentIncidentsTypeName,
                outputFormat: 'application/json',
                maxFeatures : 25
            ]), description: 'Sample GeoJSON WFS request for current incident features.'],
            [label: 'Data Gateway Health API', method: 'GET', url: gatewayHealthUrl, description: 'Direct Data Gateway health response.'],
            [label: 'OpenClaw Health API', method: 'GET', url: openclawHealthUrl, description: 'Direct OpenClaw gateway liveness response.'],
            [label: 'OpenClaw Readiness API', method: 'GET', url: openclawReadyUrl, description: 'Direct OpenClaw gateway readiness response.']
        ].findAll { Map link ->
            link.uri || link.url
        }
    }

    private List<Map> integrationLinks(Map geoserverConfig, Map geoaiConfig, Map gatewayConfig, Map openclawConfig, Map incidentAnalystConfig) {
        String geoserverRootUrl = geoserverRootUrl(geoserverConfig)
        String geoaiUrl = trimTrailingSlash(geoaiConfig.apiUrl?.toString())
        String openclawUrl = openclawGatewayUrl(openclawConfig)

        [
            [label: 'GeoServer Admin Console', url: appendPath(geoserverRootUrl, '/web'), description: 'GeoServer GUI login and administration console.'],
            [label: 'GeoServer Layer Preview', url: appendPath(geoserverRootUrl, '/web/?wicket:bookmarkablePage=:org.geoserver.web.demo.MapPreviewPage'), description: 'GeoServer browser page for previewing published layers.'],
            [label: 'GeoServer WFS Endpoint', url: geoserverConfig.wfsUrl?.toString(), description: 'Internal map layers and GeoJSON/WFS feature data.'],
            [label: 'GeoAI API Home', url: geoaiUrl, description: 'Direct GeoAI workflow API landing page.'],
            [label: 'GeoAI API Docs', url: appendPath(geoaiUrl, '/docs'), description: 'Interactive Swagger UI for GeoAI workflow API calls.'],
            [label: 'GeoAI Training Home', url: appendPath(geoaiUrl, '/training'), description: 'Building model training workflow page.'],
            [label: 'GeoAI Training Export', url: appendPath(geoaiUrl, '/training/export'), description: 'Download labels, imagery, OSM buildings, and generated chips.'],
            [label: 'GeoAI Training Import', url: appendPath(geoaiUrl, '/training/import'), description: 'Upload corrected QGIS labels back into the GeoAI training workflow.'],
            [label: 'Data Gateway Hub', url: gatewayConfig.hubUrl?.toString(), description: 'SignalR-style layer refresh/event gateway.'],
            [label: 'Data Gateway Health', url: gatewayHealthUrl(gatewayConfig), description: 'Gateway health endpoint shown in the top status strip.'],
            [label: 'OpenClaw Control UI', url: openclawUrl, description: 'Containerized assistant gateway UI for future map command workflows.'],
            [label: 'OpenClaw Health', url: openclawHealthUrl(openclawConfig), description: 'OpenClaw liveness endpoint shown in the top status strip.'],
            [label: 'OpenClaw Readiness', url: openclawReadyUrl(openclawConfig), description: 'OpenClaw readiness endpoint for startup checks.'],
            [label: 'Incident Analyst MCP Bridge', url: incidentAnalystConfig.bridgeUrl?.toString(), description: 'Standalone MCP/demo bridge used by incident analysis and response support lookup.']
        ].findAll { Map link -> link.url }
    }

    private String geoserverRootUrl(Map geoserverConfig) {
        String wfsUrl = geoserverConfig.wfsUrl?.toString()
        if (!wfsUrl) {
            return ''
        }

        int marker = wfsUrl.indexOf('/geoserver')
        if (marker >= 0) {
            return wfsUrl.substring(0, marker + '/geoserver'.length())
        }

        trimTrailingSlash(wfsUrl)
    }

    private String gatewayHealthUrl(Map gatewayConfig) {
        String explicitUrl = gatewayConfig.healthUrl?.toString()
        if (explicitUrl) {
            return explicitUrl
        }

        String hubUrl = trimTrailingSlash(gatewayConfig.hubUrl?.toString())
        if (!hubUrl) {
            return ''
        }

        int hubIndex = hubUrl.indexOf('/hubs/')
        String baseUrl = hubIndex > 0 ? hubUrl.substring(0, hubIndex) : hubUrl
        appendPath(baseUrl, '/health')
    }

    private String openclawGatewayUrl(Map openclawConfig) {
        if (!asBoolean(openclawConfig.enabled, true)) {
            return ''
        }

        trimTrailingSlash(openclawConfig.gatewayUrl?.toString())
    }

    private String openclawHealthUrl(Map openclawConfig) {
        if (!asBoolean(openclawConfig.enabled, true)) {
            return ''
        }

        String explicitUrl = openclawConfig.healthUrl?.toString()
        if (explicitUrl) {
            return explicitUrl
        }

        appendPath(openclawGatewayUrl(openclawConfig), '/healthz')
    }

    private String openclawReadyUrl(Map openclawConfig) {
        if (!asBoolean(openclawConfig.enabled, true)) {
            return ''
        }

        String explicitUrl = openclawConfig.readyUrl?.toString()
        if (explicitUrl) {
            return explicitUrl
        }

        appendPath(openclawGatewayUrl(openclawConfig), '/readyz')
    }

    private String appendPath(String baseUrl, String path) {
        if (!baseUrl) {
            return ''
        }

        String normalizedBase = trimTrailingSlash(baseUrl)
        if (!path) {
            return normalizedBase
        }

        if (path.startsWith('/?') || path.startsWith('?')) {
            return normalizedBase + path.replaceFirst('^/', '')
        }

        String normalizedPath = path.startsWith('/') ? path : "/${path}"
        "${normalizedBase}${normalizedPath}"
    }

    private String withQuery(String baseUrl, Map queryParams) {
        if (!baseUrl) {
            return ''
        }

        String query = queryParams.collect { Object key, Object value ->
            "${encodeQueryParam(key)}=${encodeQueryParam(value)}"
        }.join('&')
        "${baseUrl}${baseUrl.contains('?') ? '&' : '?'}${query}"
    }

    private String encodeQueryParam(Object value) {
        URLEncoder.encode(value?.toString() ?: '', 'UTF-8').replace('+', '%20')
    }

    private String trimTrailingSlash(String value) {
        value ? value.replaceAll('/+$', '') : ''
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
}
