package gsb.incidents

import groovy.sql.Sql

import java.sql.Connection
import java.sql.Timestamp
import java.text.SimpleDateFormat

class IncidentArchiveService {

    def dataSource_geodbthree

    List<String> getWorkflowStatuses() {
        IncidentWorkflowStatus.STATUSES
    }

    String normalizeWorkflowStatus(String value) {
        IncidentWorkflowStatus.normalize(value)
    }

    void ensureIncidentAuditColumns() {
        withSql { Sql sql, Connection connection ->
            ensureColumn(sql, 'AFIM_EVENT_POINT_BM0914', 'WORKFLOW_STATUS', 'varchar(64)')
            ensureColumn(sql, 'AFIM_EVENT_ARCHIVE', 'WORKFLOW_STATUS', 'varchar(64)')
            ensureColumn(sql, 'AFIM_EVENT_ARCHIVE', 'ARCHIVE_ACTION', 'varchar(32)')
            ensureColumn(sql, 'AFIM_EVENT_ARCHIVE', 'ARCHIVED_AT', 'timestamp')
            ensureColumn(sql, 'AFIM_EVENT_ARCHIVE', 'ARCHIVED_BY', 'varchar(255)')
            ensureColumn(sql, 'AFIM_EVENT_ARCHIVE', 'SOURCE_CURRENT_ID', 'bigint')

            if (isPostgres(connection)) {
                sql.execute('CREATE INDEX IF NOT EXISTS afim_event_archive_source_current_id_idx ON AFIM_EVENT_ARCHIVE (SOURCE_CURRENT_ID)')
                sql.execute('CREATE INDEX IF NOT EXISTS afim_event_archive_archived_at_idx ON AFIM_EVENT_ARCHIVE (ARCHIVED_AT)')
            }
        }
    }

    Map createCurrentIncidentFromParams(def params, String username = null) {
        ensureIncidentAuditColumns()

        Date now = new Date()
        String actor = username ?: 'system'
        Map values = currentIncidentValues(params, actor, now)

        withSql { Sql sql, Connection connection ->
            Long objectId = nextCurrentObjectId(sql)
            values.id = objectId
            sql.executeUpdate(
                '''INSERT INTO AFIM_EVENT_POINT_BM0914 (
                    OBJECTID_1, INCIDENT_ID, EVENT_TYPE, EVENT_CAT, EVENT_NAME, EVENT_DESC, EVENT_DESC_HAN,
                    MGRS_COORD, BASE, SIG_EVENT, AIR_OPS_AFFECTED, SOURCE, ENTERED, UPDATED_BY,
                    HIDDEN_BY, HIDDEN, UPDATED_DATE, CREATED_BY, CREATED_DATE, EVENT_SOURCE_HAN, WORKFLOW_STATUS
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
                [
                    objectId,
                    values.incidentId,
                    values.eventType,
                    values.eventCat,
                    values.eventName,
                    values.eventDesc,
                    '',
                    values.mgrsCoord,
                    values.base,
                    values.sigEvent,
                    values.airOpsAffected,
                    values.source,
                    timestampValue(now),
                    actor,
                    '',
                    'No',
                    timestampValue(now),
                    actor,
                    timestampValue(now),
                    'Status App',
                    values.workflowStatus
                ]
            )
        }

        archiveCurrentIncidentById(values.id as Long, 'CREATED', actor)
        [saved: true, id: values.id, incidentId: values.incidentId, workflowStatus: values.workflowStatus]
    }

    Map updateCurrentIncidentFromParams(Long currentIncidentId, def params, String username = null) {
        if (currentIncidentId == null) {
            return [found: false]
        }

        ensureIncidentAuditColumns()
        Date now = new Date()
        String actor = username ?: 'system'
        Map values = currentIncidentValues(params, actor, now)

        int updated = withSql { Sql sql, Connection connection ->
            sql.executeUpdate(
                '''UPDATE AFIM_EVENT_POINT_BM0914
                   SET INCIDENT_ID = ?, EVENT_TYPE = ?, EVENT_CAT = ?, EVENT_NAME = ?, EVENT_DESC = ?,
                       MGRS_COORD = ?, BASE = ?, SIG_EVENT = ?, AIR_OPS_AFFECTED = ?, SOURCE = ?,
                       UPDATED_BY = ?, UPDATED_DATE = ?, WORKFLOW_STATUS = ?
                   WHERE OBJECTID_1 = ?''',
                [
                    values.incidentId,
                    values.eventType,
                    values.eventCat,
                    values.eventName,
                    values.eventDesc,
                    values.mgrsCoord,
                    values.base,
                    values.sigEvent,
                    values.airOpsAffected,
                    values.source,
                    actor,
                    timestampValue(now),
                    values.workflowStatus,
                    currentIncidentId
                ]
            )
        } as int

        if (updated < 1) {
            return [found: false]
        }

        archiveCurrentIncidentById(currentIncidentId, 'UPDATED', actor)
        [found: true, id: currentIncidentId, incidentId: values.incidentId, workflowStatus: values.workflowStatus]
    }

    Map deleteCurrentIncident(Long currentIncidentId, String username = null) {
        if (currentIncidentId == null) {
            return [found: false]
        }

        ensureIncidentAuditColumns()
        String actor = username ?: 'system'
        Map archiveResult = archiveCurrentIncidentById(currentIncidentId, 'DELETED', actor)
        int deleted = withSql { Sql sql, Connection connection ->
            sql.executeUpdate('DELETE FROM AFIM_EVENT_POINT_BM0914 WHERE OBJECTID_1 = ?', [currentIncidentId])
        } as int

        [found: deleted > 0 || archiveResult.archived, id: currentIncidentId]
    }

    Map updateCurrentIncidentWorkflowStatus(Long currentIncidentId, String workflowStatus, String username = null) {
        if (currentIncidentId == null) {
            return [found: false]
        }

        ensureIncidentAuditColumns()
        Date now = new Date()
        String actor = username ?: 'system'
        String status = normalizeWorkflowStatus(workflowStatus)

        Map current = withSql { Sql sql, Connection connection ->
            def row = sql.firstRow('SELECT INCIDENT_ID FROM AFIM_EVENT_POINT_BM0914 WHERE OBJECTID_1 = ?', [currentIncidentId])
            if (!row) {
                return [found: false]
            }

            sql.executeUpdate(
                'UPDATE AFIM_EVENT_POINT_BM0914 SET WORKFLOW_STATUS = ?, UPDATED_DATE = ?, UPDATED_BY = ? WHERE OBJECTID_1 = ?',
                [status, timestampValue(now), actor, currentIncidentId]
            )

            [found: true, incidentId: row.incident_id]
        } as Map

        if (!current.found) {
            return [found: false]
        }

        archiveCurrentIncidentById(currentIncidentId, 'STATUS_CHANGED', actor)
        [
            found : true,
            id    : currentIncidentId,
            label : current.incidentId ?: currentIncidentId,
            status: status
        ]
    }

    Map archiveCurrentIncidentById(Long currentIncidentId, String archiveAction, String username = null) {
        if (currentIncidentId == null) {
            return [archived: false]
        }

        ensureIncidentAuditColumns()

        withSql { Sql sql, Connection connection ->
            def currentRow = sql.firstRow('SELECT INCIDENT_ID FROM AFIM_EVENT_POINT_BM0914 WHERE OBJECTID_1 = ?', [currentIncidentId])
            if (!currentRow) {
                return [archived: false]
            }

            Long archiveId = nextArchiveId(sql)
            Long archiveObjectId = nextArchiveObjectId(sql)
            String actor = username ?: 'system'
            String action = normalizeArchiveAction(archiveAction)
            Timestamp archivedAt = timestampValue(new Date())
            boolean includeGeom = hasColumn(connection, 'afim_event_archive', 'geom') && hasColumn(connection, 'afim_event_point_bm0914', 'geom')
            String geometryColumn = includeGeom ? ', GEOM' : ''
            String geometrySelect = includeGeom ? ', GEOM' : ''

            int inserted = sql.executeUpdate(
                """INSERT INTO AFIM_EVENT_ARCHIVE (
                    ID, OBJECTID_1, VERSION, INCIDENT_ID, EVENT_TYPE, EVENT_DATE, EVENT_NAME, EVENT_DESC, EVENT_DESC_HAN,
                    MGRS_COORD, BASE, SIG_EVENT, AIR_OPS_AFFECTED, SOURCE, ENTERED, UPDATED_BY, UPDATED_DATE,
                    CREATED_BY, CREATED_DATE, EVENT_SOURCE_HAN, EVENT_CAT, WORKFLOW_STATUS, ARCHIVE_ACTION,
                    ARCHIVED_AT, ARCHIVED_BY, SOURCE_CURRENT_ID${geometryColumn}
                )
                SELECT ?, ?, 0, INCIDENT_ID, EVENT_TYPE, EVENT_DATE, EVENT_NAME, EVENT_DESC, EVENT_DESC_HAN,
                       MGRS_COORD, BASE, SIG_EVENT, AIR_OPS_AFFECTED, SOURCE, ENTERED, UPDATED_BY, UPDATED_DATE,
                       CREATED_BY, CREATED_DATE, EVENT_SOURCE_HAN, EVENT_CAT, WORKFLOW_STATUS, ?, ?, ?, ?${geometrySelect}
                FROM AFIM_EVENT_POINT_BM0914
                WHERE OBJECTID_1 = ?""",
                [archiveId, archiveObjectId, action, archivedAt, actor, currentIncidentId, currentIncidentId]
            )

            [
                archived       : inserted > 0,
                id             : archiveId,
                objectid_1     : archiveObjectId,
                sourceCurrentId: currentIncidentId,
                incidentId     : currentRow.incident_id,
                archiveAction  : action
            ]
        } as Map
    }

    Map archiveCurrentIncident(CurrentIncidents currentIncident, String archiveAction, String username = null) {
        if (currentIncident == null) {
            return [archived: false]
        }

        archiveCurrentIncidentById(currentIncident.id as Long, archiveAction, username ?: currentIncident.updatedBy ?: currentIncident.createdBy)
    }

    private Long nextCurrentObjectId(Sql sql) {
        sql.firstRow('SELECT COALESCE(MAX(OBJECTID_1), 0) + 1 AS next_id FROM AFIM_EVENT_POINT_BM0914').next_id as Long
    }

    private Long nextArchiveId(Sql sql) {
        sql.firstRow('SELECT COALESCE(MAX(ID), 0) + 1 AS next_id FROM AFIM_EVENT_ARCHIVE').next_id as Long
    }

    private Long nextArchiveObjectId(Sql sql) {
        sql.firstRow('SELECT COALESCE(MAX(OBJECTID_1), 0) + 1 AS next_id FROM AFIM_EVENT_ARCHIVE').next_id as Long
    }

    private String normalizeArchiveAction(String archiveAction) {
        String action = archiveAction?.trim()?.toUpperCase()
        ['CREATED', 'UPDATED', 'STATUS_CHANGED', 'DELETED'].contains(action) ? action : 'UPDATED'
    }

    private void ensureColumn(Sql sql, String table, String column, String type) {
        sql.execute("ALTER TABLE ${table} ADD COLUMN IF NOT EXISTS ${column} ${type}".toString())
    }

    private Map currentIncidentValues(def params, String username, Date now) {
        [
            incidentId    : stringParam(params, 'incidentId') ?: generatedIncidentId(now),
            eventType     : stringParam(params, 'eventType'),
            eventCat      : stringParam(params, 'eventCat'),
            eventName     : stringParam(params, 'eventName'),
            eventDesc     : stringParam(params, 'eventDesc'),
            mgrsCoord     : stringParam(params, 'mgrsCoord'),
            base          : stringParam(params, 'base'),
            sigEvent      : stringParam(params, 'sigEvent') ?: 'No',
            airOpsAffected: stringParam(params, 'airOpsAffected') ?: 'No',
            source        : stringParam(params, 'source') ?: 'Status App',
            workflowStatus: normalizeWorkflowStatus(stringParam(params, 'workflowStatus')),
            updatedBy     : username
        ]
    }

    private String stringParam(def params, String name) {
        params[name]?.toString()?.trim() ?: null
    }

    private Timestamp timestampValue(Date date) {
        date ? new Timestamp(date.time) : null
    }

    private String generatedIncidentId(Date now) {
        SimpleDateFormat formatter = new SimpleDateFormat('yyyyMMddHHmmss')
        formatter.timeZone = TimeZone.getTimeZone('UTC')
        "INC-${formatter.format(now)}"
    }

    private boolean hasColumn(Connection connection, String table, String column) {
        def rs = connection.metaData.getColumns(null, null, table, column)
        boolean found = false
        try {
            found = rs.next()
        } finally {
            rs?.close()
        }
        found
    }

    private boolean isPostgres(Connection connection) {
        (connection.metaData.databaseProductName ?: '').toLowerCase().contains('postgresql')
    }

    private Object withSql(Closure work) {
        Connection connection = null
        Sql sql = null
        try {
            connection = dataSource_geodbthree.connection
            sql = new Sql(connection)
            work(sql, connection)
        } finally {
            sql?.close()
            if (connection && !connection.closed) {
                connection.close()
            }
        }
    }
}
