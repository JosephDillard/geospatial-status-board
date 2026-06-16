package gsb.incidents

class Incidentsarchive {
    String incidentId
    String eventType
    Date eventDate
    String eventName
    String eventDesc
    String eventDescHan
    String mgrsCoord
    String base
    String sigEvent
    String airOpsAffected
    String source
    Date entered
    String updatedBy
    Date updatedDate
    String createdBy
    Date   createdDate
    String eventSourceHan
    String eventCat
    String workflowStatus
    String archiveAction
    Date archivedAt
    String archivedBy
    Long sourceCurrentId

    static constraints = {
        incidentId nullable: true, blank: true
        eventType nullable: true, blank: true
        eventDate nullable: true, blank: true
        eventName nullable: true, blank: true
        eventDesc nullable: true, blank: true
        eventDescHan nullable: true, blank: true
        mgrsCoord nullable: true, blank: true
        base nullable: true, blank: true
        sigEvent nullable: true, blank: true
        airOpsAffected nullable: true, blank: true
        source nullable: true, blank: true
        entered nullable: true, blank: true
        updatedBy nullable: true, blank: true
        updatedDate nullable: true, blank: true
        createdBy nullable: true, blank: true
        createdDate nullable: true, blank: true
        eventSourceHan nullable: true, blank: true
        eventCat nullable: true, blank: true
        workflowStatus nullable: true, blank: true, inList: IncidentWorkflowStatus.STATUSES
        archiveAction nullable: true, blank: true
        archivedAt nullable: true, blank: true
        archivedBy nullable: true, blank: true
        sourceCurrentId nullable: true, blank: true
    }
    static mapping = {
        id column: 'OBJECTID_1'
        eventDesc type: 'text', sqlType: 'text'
        eventDescHan type: 'text', sqlType: 'text'
        workflowStatus column: 'WORKFLOW_STATUS'
        archiveAction column: 'ARCHIVE_ACTION'
        archivedAt column: 'ARCHIVED_AT'
        archivedBy column: 'ARCHIVED_BY'
        sourceCurrentId column: 'SOURCE_CURRENT_ID'
        //incidentId column: 'OBJECTID_1'
        table "AFIM_EVENT_ARCHIVE"
        datasource 'geodbthree'

    }
}
