package gsb.incidents

import org.springframework.security.access.annotation.Secured
import static org.springframework.http.HttpStatus.*
import grails.gorm.transactions.Transactional

@Secured(['ROLE_USER'])
@Transactional(readOnly = true, connection = 'geodbthree')
class ArchiveIncidentsController {
    def filterPaneService

    static allowedMethods = [delete: "DELETE"]


    def index(Integer max) {
        params.max = Math.min(max ?: 300, 300)
        if (params.incidentId) {
            respond ArchiveIncidents.findAllByIncidentIdIlike(params.incidentId).asList().sort{
                it.createdDate
            }, model: [archiveIncidentsCount: ArchiveIncidents.countByIncidentIdIlike(params.incidentId)]
        }
        else if (params.eventType) {
            respond ArchiveIncidents.findAllByEventTypeIlike(params.eventType).asList().sort {
                it.createdDate
            }, model: [archiveIncidentsCount: ArchiveIncidents.countByEventTypeIlike(params.eventType)]
        }
       else if (params.createdBy) {
            respond ArchiveIncidents.findAllByCreatedByIlike(params.createdBy).asList().sort {
                it.createdDate
            }, model: [archiveIncidentsCount: ArchiveIncidents.countByCreatedByIlike(params.createdBy)]
        }
        else if (params.eventSourceHan) {
            respond ArchiveIncidents.findAllByEventSourceHanIlike(params.eventSourceHan).asList().sort {
                it.createdDate
            }, model: [archiveIncidentsCount: ArchiveIncidents.countByEventSourceHanIlike(params.eventSourceHan)]
        }
        else if (params.eventCat) {
            respond ArchiveIncidents.findAllByEventCatIlike(params.eventCat).asList().sort {
                it.createdDate
            }, model: [archiveIncidentsCount: ArchiveIncidents.countByEventCatIlike(params.eventCat)]
        }
        else {
            respond ArchiveIncidents.list(params), model: [archiveIncidentsCount: ArchiveIncidents.count()]
        }
    }

    def filter = {
        params.max = Math.min(params.max ? params.int('max') : 100, 300)
        render( view: "filterlist",
                model:[	archiveIncidentsList: filterPaneService.filter( params, gsb.incidents.ArchiveIncidents ),
                           archiveIncidentsCount: filterPaneService.count( params, gsb.incidents.ArchiveIncidents ),
                           filterParams: org.grails.plugin.filterpane.FilterPaneUtils.extractFilterParams(params),
                           params:params ] )
    }

    def show(ArchiveIncidents archiveIncidents) {
        respond archiveIncidents
    }

    def create() {
        archiveWriteNotAllowed()
    }

    def save(ArchiveIncidents archiveIncidents) {
        archiveWriteNotAllowed()
    }

    def edit(ArchiveIncidents archiveIncidents) {
        archiveWriteNotAllowed()
    }

    def update(ArchiveIncidents archiveIncidents) {
        archiveWriteNotAllowed()
    }

    @Transactional(connection = 'geodbthree')
    def delete(ArchiveIncidents archiveIncidents) {
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
                flash.message = message(code: 'default.not.found.message', args: [message(code: 'archiveIncidents.label', default: 'Archive Incidents'), params.id])
                redirect action: "index", method: "GET"
            }
            '*' { render status: NOT_FOUND }
        }
    }

    protected void archiveWriteNotAllowed() {
        request.withFormat {
            form multipartForm {
                flash.message = 'Archive incident entries are read-only.'
                redirect action: "index", method: "GET"
            }
            '*' { render status: METHOD_NOT_ALLOWED }
        }
    }
}
