package gsb.incidents

class FACDAMIncidents {
    //ORIG Incident Fields
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

    //CFEN FACDAM Specific Fields
    String sector
    String repairStatus
    String currentProgress
    String repairResponsibility
    String repairMethod
    String beNumber
    String catCode
    String remark1
    String remark2
    String remark3

    static constraints = {
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
        sector nullable: true, blank: true
        repairStatus nullable: true, blank: true
        currentProgress nullable: true, blank: true
        repairResponsibility nullable: true, blank: true
        repairMethod nullable: true, blank: true
        beNumber nullable: true, blank: true
        catCode nullable: true, blank: true
        remark1 nullable: true, blank: true
        remark2 nullable: true, blank: true
        remark3 nullable: true, blank: true
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
