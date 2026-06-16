package gsb.incidents

import org.springframework.security.access.annotation.Secured
import static org.springframework.http.HttpStatus.*
import grails.gorm.transactions.Transactional
@Secured(['ROLE_USER'])
@Transactional(readOnly = true, connection = 'geodbthree')
class IncidentsController {
    def filterPaneService

    static allowedMethods = [save: "POST", update: "PUT", delete: "DELETE"]


    def index(Integer max) {
        params.max = Math.min(max ?: 300, 300)
        if (params.incidentId) {
            respond Incidents.findAllByIncidentIdIlike(params.incidentId).asList().sort{
                it.createdDate
            }, model: [incidentsCount: Incidents.countByIncidentIdIlike(params.incidentId)]
        }
        else if (params.eventType) {
            respond Incidents.findAllByEventTypeIlike(params.eventType).asList().sort {
                it.createdDate
            }, model: [incidentsCount: Incidents.countByEventTypeIlike(params.eventType)]
        }
       else if (params.createdBy) {
            respond Incidents.findAllByCreatedByIlike(params.createdBy).asList().sort {
                it.createdDate
            }, model: [incidentsCount: Incidents.countByCreatedByIlike(params.createdBy)]
        }
        else if (params.eventSourceHan) {
            respond Incidents.findAllByEventSourceHanIlike(params.eventSourceHan).asList().sort {
                it.createdDate
            }, model: [incidentsCount: Incidents.countByEventSourceHanIlike(params.eventSourceHan)]
        }
        else if (params.eventCat) {
            respond Incidents.findAllByEventCatIlike(params.eventCat).asList().sort {
                it.createdDate
            }, model: [incidentsCount: Incidents.countByEventCatIlike(params.eventCat)]
        }
        else {
            respond Incidents.list(params), model: [incidentsCount: Incidents.count()]
        }
    }
  /*  def searchcate(Integer max) {
        params.max = Math.min(max ?: 100, 500)
        if(params.incidentId) {
            respond Incidents.findAllByIncidentIdLike(params.incidentId).asList().sort {
                it.eventDate
            }, model: [incidentIdCount: Incidents.count()]
        }
        if(params.eventType) {
            respond Incidents.findAllByEventTypeLike(params.eventType).asList().sort {
                it.eventDate
            }, model: [eventTypeCount: Incidents.count()]
        }
        if(params.createdBy) {
            respond Incidents.findAllByCreatedByLike(params.createdBy).asList().sort {
                it.eventDate
            }, model: [createdByCount: Incidents.count()]
        }
        if(params.eventSourceHan) {
            respond Incidents.findAllByEventSourceHanLike(params.eventSourceHan).asList().sort {
                it.eventDate
            }, model: [eventSourceHanCount: Incidents.count()]
        }
        if(params.eventCat) {
            respond Incidents.findAllByEventCatLike(params.eventCat).asList().sort {
                it.eventDate
            }, model: [eventCatCount: Incidents.count()]
        }
        else {
            respond Incidents.list(params), model: [incidentIdCount: Incidents.count()]
        }
    }
*/

    def filter = {
        params.max = Math.min(params.max ? params.int('max') : 300, 300)
        render( view: "filterlist",
                model:[	incidentsList: filterPaneService.filter( params, gsb.incidents.Incidents ),
                           incidentsCount: filterPaneService.count( params, gsb.incidents.Incidents ),
                           filterParams: org.grails.plugin.filterpane.FilterPaneUtils.extractFilterParams(params),
                           params:params ] )
    }



    def show(Incidents incidents) {
        respond incidents
    }

    def create() {
        respond new Incidents(params)
    }

    @Transactional(connection = 'geodbthree')
    def save(Incidents incidents) {
        if (incidents == null) {
            notFound()
            return
        }

        if (incidents.hasErrors()) {
            respond incidents.errors, view: 'create'
            return
        }

        incidents.save flush: true

        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.created.message', args: [message(code: 'incidents.label', default: 'Incidents'), incidents.id])
                redirect incidents
            }
            '*' { respond incidents, [status: CREATED] }
        }
    }

    def edit(Incidents incidents) {
        respond incidents
    }

    @Transactional(connection = 'geodbthree')
    def update(Incidents incidents) {
        if (incidents == null) {
            notFound()
            return
        }

        if (incidents.hasErrors()) {
            respond incidents.errors, view: 'edit'
            return
        }

        incidents.save flush: true

        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.updated.message', args: [message(code: 'Incidents.label', default: 'Incidents'), incidents.id])
                redirect incidents
            }
            '*' { respond incidents, [status: OK] }
        }
    }

    @Transactional(connection = 'geodbthree')
    def delete(Incidents incidents) {
        request.withFormat {
            form multipartForm {
                flash.message = 'Incident archive entries cannot be deleted.'
                redirect action: "index", method: "GET"
            }
            '*' { render status: METHOD_NOT_ALLOWED }
        }
    }

    protected void notFound() {
        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.not.found.message', args: [message(code: 'incidents.label', default: 'Incidents'), params.id])
                redirect action: "index", method: "GET"
            }
            '*' { render status: NOT_FOUND }
        }
    }
}
