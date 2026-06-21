package geospatial.statusboard

import grails.core.GrailsApplication
import grails.plugin.springsecurity.annotation.Secured
import groovy.json.JsonOutput

import java.util.Locale

@Secured(['ROLE_USER'])
class AssistantController {

    GrailsApplication grailsApplication

    static allowedMethods = [
        plan : 'POST',
        tools: 'GET'
    ]

    def index() {
        redirect controller: 'map', action: 'index', params: [assistant: 'open']
    }

    def tools() {
        renderJson([
            tools: toolCatalog()
        ])
    }

    def plan() {
        Map payload = request.JSON instanceof Map ? request.JSON as Map : [:]
        String prompt = payload.prompt?.toString()?.trim()
        Map context = asMap(payload.context)

        if (!prompt) {
            response.status = 400
            renderJson([
                message: 'Enter a request for the map assistant.',
                actions: []
            ])
            return
        }

        List<Map> actions = []
        List<String> notes = []
        String normalized = prompt.toLowerCase(Locale.US)
        Map coordinate = parseCoordinate(prompt)
        String mgrs = parseMgrs(prompt)

        if (asksForCapabilities(normalized)) {
            notes << 'I can help with map movement, layer visibility, incident review, response support, Wiki/GeoNames lookup, MGRS coordinates, GeoAI panel setup, and reviewed incident drafts.'
        }

        if (asksForServiceHealth(normalized)) {
            addAction(actions, [
                type  : 'service.healthSummary',
                label : 'Summarize service health',
                params: [healthUrl: createLink(controller: 'geoHealth', action: 'index')],
                writes: false
            ])
        }

        layerActionsForPrompt(normalized).each { Map action ->
            addAction(actions, action)
        }

        if (asksForHighRisk(normalized)) {
            addAction(actions, toggleLayerAction('currentIncidents', 'Current Incidents'))
            addAction(actions, [
                type  : 'incident.zoomHighRisk',
                label : 'Zoom to high-risk incidents',
                params: [limit: 5],
                writes: false
            ])
        }

        if (asksForIncidentSummary(normalized)) {
            addAction(actions, toggleLayerAction('currentIncidents', 'Current Incidents'))
            addAction(actions, [
                type  : 'incident.summarizeVisible',
                label : 'Summarize visible incidents',
                params: [:],
                writes: false
            ])
        }

        if (asksForResponseSupport(normalized)) {
            addAction(actions, [
                type  : 'support.search',
                label : 'Find nearby response support',
                params: supportSearchParams(coordinate, normalized),
                writes: false
            ])
        }

        if (asksForWikiSearch(normalized)) {
            addAction(actions, [
                type  : 'place.wikipediaSearch',
                label : 'Search nearby Wiki/GeoNames',
                params: coordinate ? [longitude: coordinate.longitude, latitude: coordinate.latitude] : [target: 'mapCenter'],
                writes: false
            ])
        }

        if (asksForGeoAi(normalized)) {
            addAction(actions, [
                type  : 'geoai.openPanel',
                label : 'Open GeoAI request panel',
                params: [:],
                writes: false
            ])
        }

        if (asksForNavigation(normalized, 'kanban', 'board')) {
            addAction(actions, navigateAction('Open incident Kanban', createLink(controller: 'currentIncidents', action: 'board')))
        }
        if (asksForNavigation(normalized, 'table', 'list')) {
            addAction(actions, navigateAction('Open current incidents table', createLink(controller: 'currentIncidents', action: 'index')))
        }
        if (asksForNavigation(normalized, 'archive', 'history')) {
            addAction(actions, navigateAction('Open incident archive', createLink(controller: 'archiveIncidents', action: 'index')))
        }
        if (asksForNavigation(normalized, 'dashboard', 'home', 'hub')) {
            addAction(actions, navigateAction('Open status dashboard', createLink(controller: 'home', action: 'index')))
        }

        if (asksForIncidentDraft(normalized)) {
            Map draftParams = incidentDraftParams(prompt, normalized, coordinate, mgrs)
            if (draftParams.latitude != null || draftParams.mgrsCoord) {
                addAction(actions, [
                    type                : 'incident.previewCreate',
                    label               : 'Preview incident draft',
                    params              : draftParams,
                    writes              : true,
                    requiresConfirmation: true
                ])
            } else {
                notes << 'I can draft the incident once the prompt includes latitude/longitude or an MGRS coordinate.'
            }
        } else if (mgrs && asksForMapMove(normalized)) {
            addAction(actions, [
                type  : 'map.flyToMgrs',
                label : 'Fly to MGRS coordinate',
                params: [mgrsCoord: mgrs, zoom: 15],
                writes: false
            ])
        }

        if (coordinate && asksForMapMove(normalized) && !asksForIncidentDraft(normalized)) {
            addAction(actions, [
                type  : 'map.flyTo',
                label : 'Fly to coordinate',
                params: [longitude: coordinate.longitude, latitude: coordinate.latitude, zoom: 14],
                writes: false
            ])
        } else if (!coordinate && !mgrs && asksForSantaFe(normalized)) {
            addAction(actions, [
                type  : 'map.flyTo',
                label : 'Fly to Santa Fe review area',
                params: [longitude: -105.9378G, latitude: 35.6870G, zoom: 9],
                writes: false
            ])
        } else if (!coordinate && !mgrs && normalized.contains('colorado border')) {
            addAction(actions, [
                type  : 'map.flyTo',
                label : 'Fly toward the Colorado border',
                params: [longitude: -105.95G, latitude: 36.96G, zoom: 8],
                writes: false
            ])
        }

        if (!actions && !notes) {
            notes << 'I did not find a safe map action for that yet. Try asking to show incident layers, zoom to high-risk incidents, search response support, search Wiki nearby, open Kanban, or draft an incident from a coordinate.'
        }

        renderJson([
            mode       : 'demo',
            provider   : 'GeoStatusBoard assistant planner',
            openclaw   : openclawStatus(),
            message    : responseMessage(notes, actions),
            prompt     : prompt,
            actions    : actions,
            suggestions: suggestions()
        ])
    }

    private List<Map> layerActionsForPrompt(String normalized) {
        List<Map> actions = []
        if (containsAny(normalized, 'all key layers', 'operational layers')) {
            actions << toggleLayerAction('airportStatus', 'Airport Status')
            actions << toggleLayerAction('currentIncidents', 'Current Incidents')
            actions << toggleLayerAction('detectedRoads', 'GeoAI Detections')
            return actions
        }
        if (containsAny(normalized, 'airport', 'airfield')) {
            actions << toggleLayerAction('airportStatus', 'Airport Status')
        }
        if (containsAny(normalized, 'current incident', 'incidents', 'incident layer')) {
            actions << toggleLayerAction('currentIncidents', 'Current Incidents')
        }
        if (containsAny(normalized, 'archive incident', 'archive layer')) {
            actions << toggleLayerAction('archiveIncidents', 'Archive Incidents')
        }
        if (containsAny(normalized, 'geoai', 'detection', 'detected road', 'roads')) {
            actions << toggleLayerAction('detectedRoads', 'GeoAI Detections')
            actions << toggleLayerAction('cogFootprints', 'COG Footprints')
        }
        if (containsAny(normalized, 'fire fighting', 'fire asset')) {
            actions << toggleLayerAction('fireFightingAssets', 'Fire Fighting Assets')
        }
        if (containsAny(normalized, 'utility', 'power')) {
            actions << toggleLayerAction('utilityStatus', 'Utility Status')
        }
        actions
    }

    private Map toggleLayerAction(String layerKey, String label) {
        [
            type  : 'map.toggleLayer',
            label : "Show ${label}",
            params: [kind: 'internal', layerKey: layerKey, enabled: true],
            writes: false
        ]
    }

    private Map navigateAction(String label, String url) {
        [
            type  : 'navigate',
            label : label,
            params: [url: url],
            writes: false
        ]
    }

    private Map supportSearchParams(Map coordinate, String normalized) {
        if (coordinate) {
            return [longitude: coordinate.longitude, latitude: coordinate.latitude]
        }
        if (asksForHighRisk(normalized) || normalized.contains('selected incident') || normalized.contains('incident')) {
            return [target: 'highestRiskIncident']
        }
        [target: 'mapCenter']
    }

    private Map incidentDraftParams(String prompt, String normalized, Map coordinate, String mgrs) {
        Map params = [
            eventName     : titleFromPrompt(prompt) ?: 'Assistant drafted incident',
            eventType     : eventTypeFromPrompt(normalized),
            eventCat      : eventCategoryFromPrompt(normalized),
            eventDesc     : prompt,
            source        : 'Map Assistant',
            sigEvent      : asksForHighRisk(normalized) || containsAny(normalized, 'significant', 'major') ? 'Yes' : 'No',
            airOpsAffected: containsAny(normalized, 'air ops', 'runway', 'airfield', 'airport') ? 'Yes' : 'No'
        ]
        if (coordinate) {
            params.longitude = coordinate.longitude
            params.latitude = coordinate.latitude
        }
        if (mgrs) {
            params.mgrsCoord = mgrs
        }
        params
    }

    private String responseMessage(List<String> notes, List<Map> actions) {
        if (notes) {
            return notes.join(' ')
        }
        int writeCount = actions.count { Map action -> action.writes }
        writeCount
            ? "I built ${actions.size()} action${actions.size() == 1 ? '' : 's'}, including ${writeCount} reviewed draft action${writeCount == 1 ? '' : 's'}."
            : "I built ${actions.size()} safe map action${actions.size() == 1 ? '' : 's'}."
    }

    private Map openclawStatus() {
        Map geoConfig = asMap(grailsApplication.config.geo)
        Map openclawConfig = asMap(geoConfig.openclaw)
        if (!asBoolean(openclawConfig.enabled, true)) {
            return [enabled: false, status: 'disabled']
        }

        String gatewayUrl = trimTrailingSlash(openclawConfig.gatewayUrl?.toString() ?: 'http://localhost:18789')
        String healthUrl = openclawConfig.healthUrl?.toString() ?: "${gatewayUrl}/healthz"
        HttpURLConnection connection = null
        try {
            connection = new URL(healthUrl).openConnection() as HttpURLConnection
            connection.connectTimeout = 700
            connection.readTimeout = 700
            connection.requestMethod = 'GET'
            int code = connection.responseCode
            [
                enabled   : true,
                status    : code >= 200 && code < 400 ? 'up' : 'down',
                gatewayUrl: gatewayUrl,
                healthUrl : healthUrl,
                message   : "HTTP ${code}"
            ]
        } catch (Exception ex) {
            [
                enabled   : true,
                status    : 'down',
                gatewayUrl: gatewayUrl,
                healthUrl : healthUrl,
                message   : ex.message ?: ex.class.simpleName
            ]
        } finally {
            connection?.disconnect()
        }
    }

    private List<Map> toolCatalog() {
        [
            [type: 'map.flyTo', label: 'Fly to latitude/longitude'],
            [type: 'map.flyToMgrs', label: 'Fly to MGRS coordinate'],
            [type: 'map.toggleLayer', label: 'Show or hide a map layer'],
            [type: 'incident.zoomHighRisk', label: 'Zoom to high-risk incidents'],
            [type: 'incident.summarizeVisible', label: 'Summarize visible incidents'],
            [type: 'incident.previewCreate', label: 'Preview an incident draft'],
            [type: 'place.wikipediaSearch', label: 'Run Wiki/GeoNames nearby search'],
            [type: 'support.search', label: 'Run response support lookup'],
            [type: 'geoai.openPanel', label: 'Open GeoAI request panel'],
            [type: 'service.healthSummary', label: 'Summarize system health'],
            [type: 'navigate', label: 'Open app pages']
        ]
    }

    private List<String> suggestions() {
        [
            'Show current incidents and zoom to high-risk incidents north of Santa Fe.',
            'Find response support near the highest-risk incident.',
            'Search Wiki nearby the center of the map.',
            'Plot a wildfire incident at 35.6870, -105.9378 called Santa Fe demo incident.',
            'Open the incident Kanban board.'
        ]
    }

    private boolean asksForCapabilities(String normalized) {
        containsAny(normalized, 'what can you do', 'help me', 'help', 'capabilities')
    }

    private boolean asksForServiceHealth(String normalized) {
        containsAny(normalized, 'service health', 'system health', 'app health', 'status of the system', 'what is running', 'openclaw status')
    }

    private boolean asksForIncidentSummary(String normalized) {
        containsAny(normalized, 'summarize incidents', 'incident summary', 'what incidents', 'status of incidents')
    }

    private boolean asksForHighRisk(String normalized) {
        containsAny(normalized, 'high risk', 'high-risk', 'highest risk', 'highest-risk')
    }

    private boolean asksForResponseSupport(String normalized) {
        containsAny(normalized, 'response support', 'support nearby', 'nearby support', 'police', 'fire station', 'medical support', 'hospital nearby')
    }

    private boolean asksForWikiSearch(String normalized) {
        containsAny(normalized, 'wiki', 'wikipedia', 'geonames', 'nearby places', 'what is near')
    }

    private boolean asksForGeoAi(String normalized) {
        containsAny(normalized, 'geoai', 'geo ai', 'road detection', 'aoi', 'model run', 'submit run')
    }

    private boolean asksForIncidentDraft(String normalized) {
        (normalized.contains('incident') && containsAny(normalized, 'plot', 'create', 'add', 'draft', 'stage', 'map')) ||
            containsAny(normalized, 'new incident')
    }

    private boolean asksForMapMove(String normalized) {
        containsAny(normalized, 'zoom', 'go to', 'fly to', 'center on', 'show me', 'find')
    }

    private boolean asksForSantaFe(String normalized) {
        containsAny(normalized, 'santa fe', 'review area')
    }

    private boolean asksForNavigation(String normalized, String... terms) {
        containsAny(normalized, terms)
    }

    private boolean containsAny(String value, String... terms) {
        terms.any { String term -> value.contains(term) }
    }

    private void addAction(List<Map> actions, Map action) {
        String fingerprint = JsonOutput.toJson([action.type, action.params])
        boolean exists = actions.any { Map existing ->
            JsonOutput.toJson([existing.type, existing.params]) == fingerprint
        }
        if (!exists) {
            action.id = "assistant-action-${actions.size() + 1}"
            actions << action
        }
    }

    private Map parseCoordinate(String prompt) {
        def matcher = prompt =~ /(-?\d{1,2}\.\d+)\s*,\s*(-?\d{1,3}\.\d+)/
        if (!matcher.find()) {
            return null
        }

        BigDecimal first = new BigDecimal(matcher.group(1))
        BigDecimal second = new BigDecimal(matcher.group(2))
        if (first.abs() <= 90G && second.abs() <= 180G) {
            return [latitude: first, longitude: second]
        }
        if (first.abs() <= 180G && second.abs() <= 90G) {
            return [longitude: first, latitude: second]
        }
        null
    }

    private String parseMgrs(String prompt) {
        def matcher = prompt.toUpperCase(Locale.US) =~ /\b\d{1,2}[C-HJ-NP-X]\s*[A-HJ-NP-Z]{2}\s*\d{2,5}\s*\d{2,5}\b/
        matcher.find() ? matcher.group(0).replaceAll(/\s+/, ' ').trim() : ''
    }

    private String titleFromPrompt(String prompt) {
        List patterns = [
            /(?i)(?:called|named|titled)\s+"([^"]+)"/,
            /(?i)(?:called|named|titled)\s+([^.,;]+)/
        ]
        for (Object pattern : patterns) {
            def matcher = prompt =~ pattern
            if (matcher.find()) {
                return matcher.group(1)?.toString()?.trim()
            }
        }
        ''
    }

    private String eventTypeFromPrompt(String normalized) {
        if (containsAny(normalized, 'wildfire', 'fire', 'smoke')) {
            return 'Fire/Smoke'
        }
        if (containsAny(normalized, 'medical', 'ems', 'injury', 'hospital')) {
            return 'Medical Emergency'
        }
        if (containsAny(normalized, 'force protection', 'security', 'police', 'threat')) {
            return 'Security'
        }
        if (containsAny(normalized, 'road', 'bridge', 'access', 'washout')) {
            return 'Road/Access Issue'
        }
        if (containsAny(normalized, 'utility', 'power', 'water')) {
            return 'Utility Outage'
        }
        if (containsAny(normalized, 'weather', 'storm', 'snow', 'flood')) {
            return 'Severe Weather'
        }
        'Facility Damage'
    }

    private String eventCategoryFromPrompt(String normalized) {
        if (containsAny(normalized, 'medical', 'ems', 'hospital')) {
            return 'Medical'
        }
        if (containsAny(normalized, 'force protection', 'security', 'police', 'threat')) {
            return 'Force Protection'
        }
        if (containsAny(normalized, 'road', 'access', 'bridge')) {
            return 'Transportation'
        }
        if (containsAny(normalized, 'weather', 'wildfire', 'fire', 'flood')) {
            return 'Emergency Response'
        }
        'Operational'
    }

    private void renderJson(Map payload) {
        render(contentType: 'application/json', text: JsonOutput.toJson(payload))
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

    private String trimTrailingSlash(String value) {
        value ? value.replaceAll('/+$', '') : ''
    }
}
