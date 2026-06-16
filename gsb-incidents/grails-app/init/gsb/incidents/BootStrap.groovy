package gsb.incidents

import grails.util.Environment

class BootStrap {

    private static final List<String> NEW_MEXICO_AIRFIELDS = [
        'Albuquerque International Sunport',
        'Kirtland AFB',
        'Holloman AFB',
        'Cannon AFB',
        'Santa Fe Regional Airport',
        'Roswell Air Center',
        'Las Cruces International Airport',
        'Lea County Regional Airport',
        'Four Corners Regional Airport',
        'Grant County Airport',
        'Spaceport America',
        'Double Eagle II Airport',
        'Alamogordo-White Sands Regional',
        'Ruidoso Sierra Blanca Regional',
        'Truth or Consequences Municipal'
    ]

    def init = { servletContext ->
        TimeZone.setDefault(TimeZone.getTimeZone('UTC'))

        seedLookupCategory('incident.base', NEW_MEXICO_AIRFIELDS)
        seedLookupCategory('incident.yesNoNa', [
            'Yes',
            'No',
            'N/A'
        ])
        seedLookupCategory('incident.eventType', [
            'Airfield Damage',
            'Facility Damage',
            'Utility Outage',
            'Security',
            'Weather',
            'Aircraft Mishap'
        ])
        seedLookupCategory('incident.eventCategory', [
            'Operational',
            'Infrastructure',
            'Safety',
            'Weather',
            'Security'
        ])
        seedLookupCategory('incident.source', [
            'Operations Center',
            'Airfield Management',
            'Civil Engineer',
            'Security Forces',
            'Weather Flight'
        ])
        if (seedDevelopmentData()) {
            seedCurrentIncidentData()
            seedArchivedIncidentData()
        }
    }

    def destroy = {
    }

    private void seedLookupCategory(String category, List<String> values) {
        IncidentLookupOption.withTransaction {
            values.eachWithIndex { String value, int index ->
                IncidentLookupOption option = IncidentLookupOption.findByCategoryAndValue(category, value)
                if (!option) {
                    new IncidentLookupOption(
                        category: category,
                        value: value,
                        sortOrder: index + 1,
                        active: true
                    ).save(failOnError: true)
                } else {
                    boolean changed = false
                    if (!option.active) {
                        option.active = true
                        changed = true
                    }
                    if (option.sortOrder == null || option.sortOrder == 0) {
                        option.sortOrder = index + 1
                        changed = true
                    }
                    if (changed) {
                        option.save(failOnError: true)
                    }
                }
            }
        }
    }

    private boolean seedDevelopmentData() {
        Environment.current != Environment.PRODUCTION
    }

    private void seedCurrentIncidentData() {
        CurrentIncidents.withTransaction {
            Date now = new Date()
            List<Map> records = [
                [
                    incidentId: 'INC-NM-0001',
                    eventType: 'Weather',
                    eventName: 'Thunderstorm cell near Ruidoso',
                    eventDesc: 'Radar indicates a heavy precipitation cell moving east of the Ruidoso operating area.',
                    mgrsCoord: '13SBT4314784574',
                    base: 'Ruidoso Sierra Blanca Regional',
                    sigEvent: 'Yes',
                    airOpsAffected: 'Yes',
                    source: 'Weather Flight',
                    eventCat: 'Weather',
                    sector: 'Runway',
                    repairStatus: 'Not Assessed',
                    currentProgress: 'Monitoring weather movement.',
                    repairResponsibility: 'Airfield Management',
                    repairMethod: 'No repair action required.',
                    beNumber: 'BE-WX-001',
                    catCode: 'WX',
                    remark1: 'Supports map weather-overlay testing.'
                ],
                [
                    incidentId: 'INC-NM-0002',
                    eventType: 'Airfield Damage',
                    eventName: 'Primary runway spall report',
                    eventDesc: 'Training scenario: a spall cluster was reported near the Alamogordo midfield area.',
                    mgrsCoord: '13SCS1432218143',
                    base: 'Alamogordo-White Sands Regional',
                    sigEvent: 'Yes',
                    airOpsAffected: 'Yes',
                    source: 'Airfield Management',
                    eventCat: 'Operational',
                    sector: 'Runway',
                    repairStatus: 'In Progress',
                    currentProgress: 'Damage dimensions entered for rapid runway repair planning.',
                    repairResponsibility: 'Civil Engineer',
                    repairMethod: 'Saw-cut and patch affected pavement.',
                    beNumber: 'BE-RWY-014',
                    catCode: '111',
                    remark1: 'Synthetic current incident record.'
                ],
                [
                    incidentId: 'INC-NM-0003',
                    eventType: 'Utility Outage',
                    eventName: 'Commercial power interruption',
                    eventDesc: 'Utility feed interruption reported at Las Cruces support facilities. Generator power is carrying essential loads.',
                    mgrsCoord: '13RDR1282313950',
                    base: 'Las Cruces International Airport',
                    sigEvent: 'No',
                    airOpsAffected: 'No',
                    source: 'Civil Engineer',
                    eventCat: 'Infrastructure',
                    sector: 'Utilities',
                    repairStatus: 'In Progress',
                    currentProgress: 'Utility provider repair crew is on site.',
                    repairResponsibility: 'State/Local',
                    repairMethod: 'Replace failed feeder component.',
                    beNumber: 'BE-UTL-023',
                    catCode: '812',
                    remark1: 'Generator-backed operations remain available.'
                ],
                [
                    incidentId: 'INC-NM-0004',
                    eventType: 'Security',
                    eventName: 'Gate access slowdown',
                    eventDesc: 'Access control queue increased after an exercise badge check at Roswell Air Center.',
                    mgrsCoord: '13SEC9180875962',
                    base: 'Roswell Air Center',
                    sigEvent: 'No',
                    airOpsAffected: 'No',
                    source: 'Security Forces',
                    eventCat: 'Security',
                    sector: 'Entry Control',
                    repairStatus: 'Complete',
                    currentProgress: 'Traffic returned to normal.',
                    repairResponsibility: 'Security Forces',
                    repairMethod: 'Opened secondary inspection lane.',
                    beNumber: 'BE-SEC-009',
                    catCode: '730',
                    remark1: 'Useful for filter and hidden-row testing.'
                ],
                [
                    incidentId: 'INC-NM-0005',
                    eventType: 'Facility Damage',
                    eventName: 'Hangar door actuator fault',
                    eventDesc: 'Kirtland maintenance hangar door is operating manually until an actuator is replaced.',
                    mgrsCoord: '13SDV5434276214',
                    base: 'Kirtland AFB',
                    sigEvent: 'No',
                    airOpsAffected: 'No',
                    source: 'Civil Engineer',
                    eventCat: 'Infrastructure',
                    sector: 'Maintenance',
                    repairStatus: 'In Progress',
                    currentProgress: 'Replacement actuator ordered.',
                    repairResponsibility: 'Civil Engineer',
                    repairMethod: 'Replace actuator and test door interlock.',
                    beNumber: 'BE-FAC-031',
                    catCode: '211',
                    remark1: 'Manual operations are available.'
                ],
                [
                    incidentId: 'INC-NM-0006',
                    eventType: 'Aircraft Mishap',
                    eventName: 'Precautionary landing',
                    eventDesc: 'Aircraft made a precautionary landing at Double Eagle II after an indicator light. No injuries reported.',
                    mgrsCoord: '13SDV2939881891',
                    base: 'Double Eagle II Airport',
                    sigEvent: 'Yes',
                    airOpsAffected: 'Yes',
                    source: 'Operations Center',
                    eventCat: 'Safety',
                    sector: 'Ramp',
                    repairStatus: 'Not Assessed',
                    currentProgress: 'Aircraft secured pending maintenance inspection.',
                    repairResponsibility: 'Operations Center',
                    repairMethod: 'Coordinate recovery after inspection.',
                    beNumber: 'BE-SAFE-006',
                    catCode: '141',
                    remark1: 'Synthetic mishap record for current incident views.'
                ]
            ]

            records.eachWithIndex { Map record, int index ->
                if (!CurrentIncidents.findByIncidentId(record.incidentId as String)) {
                    Date eventDate = daysAgo(now, index)
                    new CurrentIncidents(
                        incidentId: record.incidentId,
                        eventType: record.eventType,
                        eventDate: eventDate,
                        eventName: record.eventName,
                        eventDesc: record.eventDesc,
                        eventDescHan: '',
                        mgrsCoord: record.mgrsCoord,
                        base: record.base,
                        sigEvent: record.sigEvent,
                        airOpsAffected: record.airOpsAffected,
                        source: record.source,
                        entered: eventDate,
                        updatedBy: 'bootstrap',
                        hiddenBy: '',
                        hidden: 'No',
                        updatedDate: eventDate,
                        createdBy: 'bootstrap',
                        createdDate: eventDate,
                        eventSourceHan: 'Status App',
                        eventCat: record.eventCat,
                        workflowStatus: IncidentWorkflowStatus.NEW
                    ).save(failOnError: true)
                }
            }
        }
    }

    private void seedArchivedIncidentData() {
        ArchiveIncidents.withTransaction {
            Date now = new Date()
            List<Map> records = [
                [incidentId: 'ARC-NM-0001', eventType: 'Weather', eventName: 'Dust advisory', eventDesc: 'Archived training record for a dust advisory near Holloman.', mgrsCoord: '13SCS2384120931', base: 'Holloman AFB', sigEvent: 'No', airOpsAffected: 'Yes', source: 'Weather Flight', eventCat: 'Weather'],
                [incidentId: 'ARC-NM-0002', eventType: 'Facility Damage', eventName: 'Roof leak repaired', eventDesc: 'Archived record for a roof leak at a Kirtland support facility.', mgrsCoord: '13SDV5451275992', base: 'Kirtland AFB', sigEvent: 'No', airOpsAffected: 'No', source: 'Civil Engineer', eventCat: 'Infrastructure'],
                [incidentId: 'ARC-NM-0003', eventType: 'Airfield Damage', eventName: 'FOD sweep complete', eventDesc: 'Archived record for a FOD sweep after high winds at Cannon.', mgrsCoord: '13SFA3191022194', base: 'Cannon AFB', sigEvent: 'No', airOpsAffected: 'No', source: 'Airfield Management', eventCat: 'Operational'],
                [incidentId: 'ARC-NM-0004', eventType: 'Security', eventName: 'Perimeter sensor reset', eventDesc: 'Archived record for a perimeter sensor reset at Roswell.', mgrsCoord: '13SEC9135576021', base: 'Roswell Air Center', sigEvent: 'No', airOpsAffected: 'No', source: 'Security Forces', eventCat: 'Security'],
                [incidentId: 'ARC-NM-0005', eventType: 'Utility Outage', eventName: 'Water main maintenance', eventDesc: 'Archived record for planned water maintenance at Santa Fe Regional.', mgrsCoord: '13SDV9687774419', base: 'Santa Fe Regional Airport', sigEvent: 'No', airOpsAffected: 'No', source: 'Civil Engineer', eventCat: 'Infrastructure'],
                [incidentId: 'ARC-NM-0006', eventType: 'Aircraft Mishap', eventName: 'Bird strike inspection', eventDesc: 'Archived record for a bird strike inspection at Albuquerque.', mgrsCoord: '13SDV5107276490', base: 'Albuquerque International Sunport', sigEvent: 'Yes', airOpsAffected: 'No', source: 'Operations Center', eventCat: 'Safety'],
                [incidentId: 'ARC-NM-0007', eventType: 'Weather', eventName: 'Lightning within five miles', eventDesc: 'Archived record for lightning near Spaceport America.', mgrsCoord: '13RDR5368996432', base: 'Spaceport America', sigEvent: 'No', airOpsAffected: 'Yes', source: 'Weather Flight', eventCat: 'Weather'],
                [incidentId: 'ARC-NM-0008', eventType: 'Facility Damage', eventName: 'Apron lighting repaired', eventDesc: 'Archived record for apron lighting repair at Grant County.', mgrsCoord: '12SVC7237372429', base: 'Grant County Airport', sigEvent: 'No', airOpsAffected: 'No', source: 'Civil Engineer', eventCat: 'Infrastructure']
            ]

            records.eachWithIndex { Map record, int index ->
                if (!ArchiveIncidents.findByIncidentId(record.incidentId as String)) {
                    Date eventDate = daysAgo(now, index + 7)
                    new ArchiveIncidents(
                        objectid_1: index + 1L,
                        incidentId: record.incidentId,
                        eventType: record.eventType,
                        eventDate: eventDate,
                        eventName: record.eventName,
                        eventDesc: record.eventDesc,
                        eventDescHan: '',
                        mgrsCoord: record.mgrsCoord,
                        base: record.base,
                        sigEvent: record.sigEvent,
                        airOpsAffected: record.airOpsAffected,
                        source: record.source,
                        entered: eventDate,
                        updatedBy: 'bootstrap',
                        updatedDate: eventDate,
                        createdBy: 'bootstrap',
                        createdDate: eventDate,
                        eventSourceHan: 'Status App',
                        eventCat: record.eventCat,
                        workflowStatus: IncidentWorkflowStatus.NEW,
                        archiveAction: 'CREATED',
                        archivedAt: eventDate,
                        archivedBy: 'bootstrap'
                    ).save(failOnError: true)
                }
            }
        }
    }

    private Date daysAgo(Date baseDate, int days) {
        long offsetMillis = days * 24L * 60L * 60L * 1000L
        new Date(baseDate.time - offsetMillis)
    }
}
