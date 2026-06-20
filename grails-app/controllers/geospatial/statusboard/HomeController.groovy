package geospatial.statusboard

import grails.core.GrailsApplication
import grails.plugin.springsecurity.annotation.Secured

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
        Map incidentAnalystConfig = asMap(geoConfig.incidentAnalyst)

        [
            username        : authentication?.name,
            roles           : authentication?.authorities*.authority?.sort() ?: [],
            appLinks        : appLinks(),
            apiLinks        : apiLinks(),
            integrationLinks: integrationLinks(geoserverConfig, geoaiConfig, gatewayConfig, incidentAnalystConfig)
        ]
    }

    private List<Map> appLinks() {
        [
            [label: 'Map View', controller: 'map', action: 'index', description: 'Shared operational map with layers, plotting, Wiki, LLM, POI, and MGRS tools.'],
            [label: 'Incident Analyst', uri: '/incident-analyst', description: 'Focused incident review map using the same map tools with risk and support review.'],
            [label: 'Current Incidents Table', controller: 'currentIncidents', action: 'index', description: 'Table review and filtering for active incident records.'],
            [label: 'Incident Kanban', controller: 'currentIncidents', action: 'board', description: 'Workflow board for moving incidents through review states.'],
            [label: 'Archive Incidents', controller: 'archiveIncidents', action: 'index', description: 'Append-only history of created, updated, moved, and deleted incidents.'],
            [label: 'Airport Status', controller: 'airportStatus', action: 'index', description: 'Airfield status records with map handoff links.'],
            [label: 'Current Airfield Status', controller: 'currentSIT', action: 'index', description: 'Current situation table for airfield posture.'],
            [label: 'App Admin', controller: 'appAdmin', action: 'index', description: 'Admin-managed banner text and quick links.']
        ]
    }

    private List<Map> apiLinks() {
        [
            [label: 'Service Health API', uri: '/geoHealth/index', description: 'JSON status for GeoServer, PostGIS, GeoAI, and Data Gateway.'],
            [label: 'GeoAI Options API', uri: '/geoAi/options', description: 'Available GeoAI models and workflows for the LLM/map request panel.'],
            [label: 'GeoAI Jobs API', uri: '/geoAi/jobs', description: 'Known GeoAI detection jobs for map layer filtering.'],
            [label: 'Incident Analysis API', uri: '/incident-analyst/api/analyze?latitude=35.687&longitude=-105.938&radius_km=220', description: 'Proxy into the incident analyst bridge analysis workflow.'],
            [label: 'Support POI API', uri: '/incident-analyst/api/osm/support?latitude=35.687&longitude=-105.938&radius_m=20000', description: 'OpenStreetMap/local fallback support lookup used by the POI map tool.']
        ]
    }

    private List<Map> integrationLinks(Map geoserverConfig, Map geoaiConfig, Map gatewayConfig, Map incidentAnalystConfig) {
        [
            [label: 'GeoServer WFS', url: geoserverConfig.wfsUrl?.toString(), description: 'Internal map layers and GeoJSON/WFS feature data.'],
            [label: 'GeoAI API', url: geoaiConfig.apiUrl?.toString(), description: 'Road/asset detection workflows consumed by the map.'],
            [label: 'Data Gateway Hub', url: gatewayConfig.hubUrl?.toString(), description: 'SignalR-style layer refresh/event gateway.'],
            [label: 'Data Gateway Health', url: gatewayConfig.healthUrl?.toString(), description: 'Gateway health endpoint shown in the top status strip.'],
            [label: 'Incident Analyst MCP Bridge', url: incidentAnalystConfig.bridgeUrl?.toString(), description: 'Standalone MCP/demo bridge used by incident analysis and POI support lookup.']
        ].findAll { Map link -> link.url }
    }

    private Map asMap(Object value) {
        if (value instanceof Map) {
            return value.collectEntries { Object key, Object entryValue ->
                [key.toString(), entryValue]
            }
        }

        [:]
    }
}
