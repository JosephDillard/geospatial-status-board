package geospatial.statusboard

class UrlMappings {

    static mappings = {
        "/geoAi/options"(controller: 'geoAi', action: 'options', method: 'GET')
        "/geoAi/jobs"(controller: 'geoAi', action: 'jobs', method: 'GET')
        "/geoAi/runs"(controller: 'geoAi', action: 'createRun', method: 'POST')
        "/geoAi/runs/$id"(controller: 'geoAi', action: 'runStatus', method: 'GET')
        "/incident-analyst"(controller: 'incidentAnalyst', action: 'index', method: 'GET')
        "/incident-analyst/api/analyze"(controller: 'incidentAnalyst', action: 'analyze', method: 'GET')
        "/incident-analyst/api/osm/support"(controller: 'incidentAnalyst', action: 'osmSupport', method: 'GET')

        "/$controller/$action?/$id?(.$format)?"{
            constraints {
                // apply constraints here
            }
        }

        "/"(controller: 'home', action: 'index')
        "500"(view:'/error')
        "404"(view:'/notFound')
    }
}
