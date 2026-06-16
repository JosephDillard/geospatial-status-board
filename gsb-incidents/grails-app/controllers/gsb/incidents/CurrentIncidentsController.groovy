package gsb.incidents

import grails.plugin.springsecurity.annotation.Secured
import static org.springframework.http.HttpStatus.*
import grails.gorm.transactions.NotTransactional
import grails.gorm.transactions.Transactional
import groovy.json.JsonOutput
import groovy.sql.Sql
import java.text.SimpleDateFormat
import java.sql.Connection
import java.sql.Timestamp

@Secured(['ROLE_USER'])
@Transactional(readOnly = true, connection = 'geodbthree')
class CurrentIncidentsController {
    private static final String CURRENT_INCIDENTS_TABLE = 'current_incidents'

    def filterPaneService
    def springSecurityService
    def dataSource_geodbthree
    IncidentArchiveService incidentArchiveService

    static allowedMethods = [save: "POST", update: "PUT", delete: "DELETE", mapCreate: "POST", updateWorkflowStatus: "POST"]

    def index(Integer max) {
        params.max = Math.min(max ?: 50, 300)
        if (params.id) {
            respond CurrentIncidents.findAllByIdIlike(params.id).asList().sort{
                it.createdDate
            }, model: [currentIncidentsCount: CurrentIncidents.countByIncidentIdIlike(params.id)]
        }
        else if (params.eventType) {
            respond CurrentIncidents.findAllByEventTypeIlike(params.eventType).asList().sort {
                it.createdDate
            }, model: [currentIncidentsCount: CurrentIncidents.countByEventTypeIlike(params.eventType)]
        }
        else if (params.createdBy) {
            respond CurrentIncidents.findAllByCreatedByIlike(params.createdBy).asList().sort {
                it.createdDate
            }, model: [currentIncidentsCount: CurrentIncidents.countByCreatedByIlike(params.createdBy)]
        }
        else if (params.eventSourceHan) {
            respond CurrentIncidents.findAllByEventSourceHanIlike(params.eventSourceHan).asList().sort {
                it.createdDate
            }, model: [currentIncidentsCount: CurrentIncidents.countByEventSourceHanIlike(params.eventSourceHan)]
        }
        else if (params.eventCat) {
            respond CurrentIncidents.findAllByEventCatIlike(params.eventCat).asList().sort {
                it.createdDate
            }, model: [currentIncidentsCount: CurrentIncidents.countByEventCatIlike(params.eventCat)]
        }
        else {
            respond CurrentIncidents.list(params), model: [currentIncidentsCount: CurrentIncidents.count()]
        }
    }

    def edit(CurrentIncidents currentIncidents) {
        respond currentIncidents, model: [workflowStatuses: incidentArchiveService.workflowStatuses]
    }

    def board() {
        List<String> statuses = incidentArchiveService.workflowStatuses
        Map<String, List<CurrentIncidents>> columns = statuses.collectEntries { String status ->
            [status, []]
        }

        CurrentIncidents.list(sort: 'updatedDate', order: 'desc').each { CurrentIncidents incident ->
            String status = incidentArchiveService.normalizeWorkflowStatus(incident.workflowStatus)
            columns[status] << incident
        }

        [
            workflowStatuses     : statuses,
            workflowColumns      : columns,
            currentIncidentsCount: CurrentIncidents.count()
        ]
    }

    def filter = {
        params.max = Math.min(params.max ? params.int('max') : 50, 300)
        render( view: "filterlist",
                model:[	currentIncidentsList: filterPaneService.filter( params, gsb.incidents.CurrentIncidents ),
                           currentIncidentsCount: filterPaneService.count( params, gsb.incidents.CurrentIncidents ),
                           filterParams: org.grails.plugin.filterpane.FilterPaneUtils.extractFilterParams(params),
                           params:params ] )
    }

    def show(CurrentIncidents currentIncidents) {
        respond currentIncidents
    }

    def showArchive(CurrentIncidents currentIncidents) {
        def id = currentIncidents.id
        def list = ArchiveIncidents.findAllBySourceCurrentId(id, [sort: 'archivedAt', order: 'desc'])
        if (!list && currentIncidents.incidentId) {
            list = ArchiveIncidents.findAllByIncidentId(currentIncidents.incidentId, [sort: 'archivedAt', order: 'desc'])
        }
        [archiveList: list, currentIncidents: currentIncidents]
        //respond currentIncidents
    }

//    def setHidden(long id) {
//        def test = id
//    }

    def create() {
        CurrentIncidents currentIncidents = new CurrentIncidents(params)
        currentIncidents.workflowStatus = incidentArchiveService.normalizeWorkflowStatus(currentIncidents.workflowStatus)
        respond currentIncidents, model: [workflowStatuses: incidentArchiveService.workflowStatuses]
    }

    @Secured(['ROLE_USER'])
    @NotTransactional
    def mapCreate() {
        Object payload = request.JSON ?: params
        BigDecimal longitude = decimalValue(payload, 'longitude')
        BigDecimal latitude = decimalValue(payload, 'latitude')

        if (longitude == null || latitude == null) {
            render status: BAD_REQUEST, contentType: 'application/json', text: JsonOutput.toJson([
                error: 'A longitude and latitude are required.'
            ])
            return
        }

        Date now = new Date()
        String eventName = stringValue(payload, 'eventName')
        String eventType = stringValue(payload, 'eventType')
        if (!eventName || !eventType) {
            render status: BAD_REQUEST, contentType: 'application/json', text: JsonOutput.toJson([
                error: 'An event name and event type are required.'
            ])
            return
        }

        String username = currentUsername()
        Map currentIncidents = [
            incidentId     : stringValue(payload, 'incidentId') ?: generatedIncidentId(now),
            eventType      : eventType,
            eventCat       : stringValue(payload, 'eventCat'),
            eventName      : eventName,
            eventDesc      : stringValue(payload, 'eventDesc'),
            eventDescHan   : '',
            mgrsCoord      : stringValue(payload, 'mgrsCoord'),
            base           : stringValue(payload, 'base'),
            sigEvent       : stringValue(payload, 'sigEvent') ?: 'No',
            airOpsAffected : stringValue(payload, 'airOpsAffected') ?: 'No',
            source         : stringValue(payload, 'source') ?: 'Map',
            entered        : now,
            updatedBy      : username,
            hiddenBy       : '',
            hidden         : 'No',
            updatedDate    : now,
            createdBy      : username,
            createdDate    : now,
            eventSourceHan : 'Status App Map',
            workflowStatus : IncidentWorkflowStatus.NEW
        ]

        incidentArchiveService.ensureIncidentAuditColumns()
        Map geometryResult = insertIncidentRecord(currentIncidents, longitude, latitude)
        if (!geometryResult.inserted) {
            render status: INTERNAL_SERVER_ERROR, contentType: 'application/json', text: JsonOutput.toJson([
                error : 'Incident could not be created.',
                reason: geometryResult.reason
            ])
            return
        }
        incidentArchiveService.archiveCurrentIncidentById(currentIncidents.id as Long, 'CREATED', username)

        render status: CREATED, contentType: 'application/json', text: JsonOutput.toJson([
            incident: incidentPayload(currentIncidents, longitude, latitude),
            feature : incidentFeature(currentIncidents, longitude, latitude),
            geometry: geometryResult
        ])
    }

    @NotTransactional
    def save() {
        Map result = incidentArchiveService.createCurrentIncidentFromParams(params, currentUsername())

        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.created.message', args: [message(code: 'currentIncidents.label', default: 'CurrentIncidents'), result.id])
                redirect action: 'show', id: result.id
            }
            '*' { render status: CREATED, contentType: 'application/json', text: JsonOutput.toJson(result) }
        }
    }
    
    @NotTransactional
    def update() {
        Long currentIncidentId = params.long('id')
        Map result = incidentArchiveService.updateCurrentIncidentFromParams(currentIncidentId, params, currentUsername())
        if (!result.found) {
            notFound()
            return
        }

        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.updated.message', args: [message(code: 'CurrentIncidents.label', default: 'CurrentIncidents'), result.id])
                redirect action: 'show', id: result.id
            }
            '*'{ render status: OK, contentType: 'application/json', text: JsonOutput.toJson(result) }
        }
    }

    @NotTransactional
    def delete() {
        Long currentIncidentId = params.long('id')
        Map result = incidentArchiveService.deleteCurrentIncident(currentIncidentId, currentUsername())
        if (!result.found) {
            notFound()
            return
        }

        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.deleted.message', args: [message(code: 'CurrentIncidents.label', default: 'CurrentIncidents'), currentIncidentId])
                redirect action:"index", method:"GET"
            }
            '*'{ render status: NO_CONTENT }
        }
    }

    @NotTransactional
    def updateWorkflowStatus() {
        Map result = incidentArchiveService.updateCurrentIncidentWorkflowStatus(params.long('id'), params.workflowStatus?.toString(), currentUsername())

        if (!result.found) {
            notFound()
            return
        }

        flash.message = "Incident ${result.label} moved to ${result.status}."
        String returnTo = params.returnTo?.toString()
        if (returnTo == 'index') {
            redirect action: 'index', method: 'GET'
        } else {
            redirect action: 'board', method: 'GET'
        }
    }

    protected void notFound() {
        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.not.found.message', args: [message(code: 'currentIncidents.label', default: 'CurrentIncidents'), params.id])
                redirect action: "index", method: "GET"
            }
            '*'{ render status: NOT_FOUND }
        }
    }

    private Map incidentPayload(def incident, BigDecimal longitude, BigDecimal latitude) {
        [
            id            : incident.id,
            incidentId    : incident.incidentId,
            eventType     : incident.eventType,
            eventCat      : incident.eventCat,
            eventName     : incident.eventName,
            eventDesc     : incident.eventDesc,
            mgrsCoord     : incident.mgrsCoord,
            base          : incident.base,
            sigEvent      : incident.sigEvent,
            airOpsAffected: incident.airOpsAffected,
            source        : incident.source,
            workflowStatus: incident.workflowStatus,
            createdBy     : incident.createdBy,
            createdDate   : formatUtc(incident.createdDate, "yyyy-MM-dd'T'HH:mm:ss'Z'"),
            longitude     : longitude,
            latitude      : latitude
        ]
    }

    private Map incidentFeature(def incident, BigDecimal longitude, BigDecimal latitude) {
        [
            type      : 'Feature',
            geometry  : [
                type       : 'Point',
                coordinates: [longitude, latitude]
            ],
            properties: [
                __layerKey      : 'currentIncidents',
                id              : incident.id,
                incident_id     : incident.incidentId,
                event_type      : incident.eventType,
                event_cat       : incident.eventCat,
                event_name      : incident.eventName,
                event_desc      : incident.eventDesc,
                mgrs_coord      : incident.mgrsCoord,
                base            : incident.base,
                sig_event       : incident.sigEvent,
                air_ops_affected: incident.airOpsAffected,
                source          : incident.source,
                workflow_status : incident.workflowStatus,
                created_by      : incident.createdBy,
                created_date    : formatUtc(incident.createdDate, "yyyy-MM-dd'T'HH:mm:ss'Z'")
            ]
        ]
    }

    private Map insertIncidentRecord(Map incident, BigDecimal longitude, BigDecimal latitude) {
        Map result = [inserted: false, updated: false, skipped: true]
        Connection connection = null
        Sql sql = null
        try {
            connection = dataSource_geodbthree.connection
            sql = new Sql(connection)
            String productName = connection.metaData.databaseProductName ?: ''
            boolean postgres = productName.toLowerCase().contains('postgresql')
            Long objectId = sql.firstRow("SELECT COALESCE(MAX(OBJECTID_1), 0) + 1 AS next_id FROM ${CURRENT_INCIDENTS_TABLE}".toString()).next_id as Long
            incident.id = objectId

            String geometryColumn = postgres ? ', GEOM' : ''
            String geometryValue = postgres ? ', ST_SetSRID(ST_MakePoint(?, ?), 4326)' : ''
            List values = [
                objectId,
                incident.incidentId,
                incident.eventType,
                incident.eventCat,
                incident.eventName,
                incident.eventDesc,
                incident.eventDescHan,
                incident.mgrsCoord,
                incident.base,
                incident.sigEvent,
                incident.airOpsAffected,
                incident.source,
                timestampValue(incident.entered),
                incident.updatedBy,
                incident.hiddenBy,
                incident.hidden,
                timestampValue(incident.updatedDate),
                incident.createdBy,
                timestampValue(incident.createdDate),
                incident.eventSourceHan,
                incident.workflowStatus
            ]
            if (postgres) {
                values.add(longitude)
                values.add(latitude)
            }

            int inserted = sql.executeUpdate(
                """INSERT INTO ${CURRENT_INCIDENTS_TABLE} (
                    OBJECTID_1, INCIDENT_ID, EVENT_TYPE, EVENT_CAT, EVENT_NAME, EVENT_DESC, EVENT_DESC_HAN,
                    MGRS_COORD, BASE, SIG_EVENT, AIR_OPS_AFFECTED, SOURCE, ENTERED, UPDATED_BY,
                    HIDDEN_BY, HIDDEN, UPDATED_DATE, CREATED_BY, CREATED_DATE, EVENT_SOURCE_HAN,
                    WORKFLOW_STATUS${geometryColumn}
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?${geometryValue})""".toString(),
                values
            )
            result.inserted = inserted > 0
            result.updated = postgres && inserted > 0
            result.skipped = !postgres
            if (!postgres) {
                result.reason = 'non-postgresql-datasource'
            }
        } catch (Exception ignored) {
            log.warn('Map incident insert failed', ignored)
            incident.id = null
            result.inserted = false
            result.updated = false
            result.skipped = true
            result.reason = 'incident-insert-failed'
        } finally {
            sql?.close()
            if (connection && !connection.closed) {
                connection.close()
            }
        }
        result
    }

    private Timestamp timestampValue(Date date) {
        date ? new Timestamp(date.time) : null
    }

    private BigDecimal decimalValue(Object payload, String name) {
        String value = stringValue(payload, name)
        value?.isBigDecimal() ? value as BigDecimal : null
    }

    private String stringValue(Object payload, String name) {
        Object value = null
        try {
            value = payload[name]
        } catch (Exception ignored) {
            value = params[name]
        }

        String text = value?.toString()?.trim()
        text ?: null
    }

    private String generatedIncidentId(Date now) {
        "INC-MAP-${formatUtc(now, 'yyyyMMddHHmmss')}"
    }

    private String currentUsername() {
        try {
            return springSecurityService?.currentUser?.username?.toString() ?: request.userPrincipal?.name ?: 'map'
        } catch (Exception ignored) {
            request.userPrincipal?.name ?: 'map'
        }
    }

    private String formatUtc(Date date, String pattern) {
        if (!date) {
            return null
        }

        SimpleDateFormat formatter = new SimpleDateFormat(pattern)
        formatter.timeZone = TimeZone.getTimeZone('UTC')
        formatter.format(date)
    }
}
