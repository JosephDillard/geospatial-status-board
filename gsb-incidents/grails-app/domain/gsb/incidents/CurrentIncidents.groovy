package gsb.incidents

class CurrentIncidents {
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
    String hiddenBy
    String hidden
    Date updatedDate
    String createdBy
    Date createdDate
    String eventSourceHan
    String eventCat
    String workflowStatus

    static constraints = {
        //incidentId nullable: true, blank: true
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
        hiddenBy nullable: true, blank: true
        hidden nullable: true, blank: true
        updatedDate nullable: true, blank: true
        createdBy nullable: true, blank: true
        createdDate nullable: true, blank: true
        eventSourceHan nullable: true, blank: true
        eventCat nullable: true, blank: true
        workflowStatus nullable: true, blank: true, inList: IncidentWorkflowStatus.STATUSES
    }
    static mapping = {
        id column: 'OBJECTID_1'
        eventDesc type: 'text', sqlType: 'text'
        eventDescHan type: 'text', sqlType: 'text'
        workflowStatus column: 'WORKFLOW_STATUS'
        //incidentId column: 'OBJECTID_1'
        version false
        table 'AFIM_EVENT_POINT_BM0914'
        datasource 'geodbthree'
    }
}
