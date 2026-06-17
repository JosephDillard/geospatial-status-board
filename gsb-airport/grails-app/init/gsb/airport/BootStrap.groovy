package gsb.airport

import grails.util.Environment

import java.net.URLEncoder

class BootStrap {

    private static final String GREEN = 'GREEN - NO SIGNIFICANT DEGRADATION'
    private static final String YELLOW = 'YELLOW - DEGRADED WITH WORK-AROUND'
    private static final String RED = 'RED - DEGRADED NO WORK-AROUND'
    private static final String BLACK = 'BLACK - INCAPACITATED'
    private static final String NA = 'NA'
    private static final List<String> AIRPORT_OVERALL_STATUSES = [
        GREEN,
        YELLOW,
        RED,
        BLACK,
        NA
    ]

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

    private static final List<String> EMERGENCY_RESPONSE_AGENCIES = [
        'FEMA',
        'U.S. Forest Service',
        'Bureau of Land Management Fire',
        'National Park Service Fire',
        'U.S. Fish and Wildlife Service Fire',
        'U.S. Army Corps of Engineers',
        'NOAA National Weather Service',
        'U.S. Geological Survey',
        'New Mexico DHSEM',
        'New Mexico State Forestry Division',
        'New Mexico Department of Transportation',
        'New Mexico Department of Health EMS Bureau',
        'New Mexico State Fire Marshal',
        'New Mexico State Police',
        'County Emergency Management',
        'Local Fire Department',
        'Municipal Airport Authority',
        'Contractor / Mutual Aid'
    ]

    private static final List<Map> DEFAULT_BANNER_TEXTS = [
        [slot: 'brandTitle', label: 'Banner Title', textValue: 'Airport Status', sortOrder: 1],
        [slot: 'brandSubtitle', label: 'Banner Subtitle', textValue: 'Emergency Management', previousTextValue: 'Geospatial Status Board', sortOrder: 2],
        [slot: 'securityMessage', label: 'Top Center Banner', textValue: 'Status app linkable to geospatial data', sortOrder: 3],
        [slot: 'useMessage', label: 'Top Right Banner', textValue: 'Dashboard and map view of airport and airfield status', sortOrder: 4],
        [slot: 'versionMessage', label: 'Footer Banner', textValue: 'GSB', sortOrder: 5],
        [slot: 'quickLinksTitle', label: 'Quick Links Title', textValue: 'Emergency Links', sortOrder: 6]
    ]

    private static final List<Map> DEFAULT_QUICK_LINKS = [
        [category: 'Federal Emergency', label: 'FEMA', url: 'https://www.fema.gov/', description: 'Federal Emergency Management Agency', sortOrder: 10],
        [category: 'Federal Emergency', label: 'Ready.gov', url: 'https://www.ready.gov/', description: 'Preparedness guidance and public emergency information', sortOrder: 20],
        [category: 'Weather', label: 'National Weather Service', url: 'https://www.weather.gov/', description: 'Official watches, warnings, and forecasts', sortOrder: 30],
        [category: 'Weather', label: 'NWS API', url: 'https://www.weather.gov/documentation/services-web-api', description: 'Open weather alert and forecast API documentation', sortOrder: 40],
        [category: 'Weather', label: 'NOAA Radar Services', url: 'https://mapservices.weather.noaa.gov/eventdriven/rest/services/radar', description: 'NOAA radar map services', sortOrder: 50],
        [category: 'Wildfire', label: 'NIFC Open Data', url: 'https://data-nifc.opendata.arcgis.com/', description: 'National Interagency Fire Center open GIS data', sortOrder: 60],
        [category: 'Wildfire', label: 'USFS Fire Data', url: 'https://data.fs.usda.gov/geodata/', description: 'U.S. Forest Service geospatial data', sortOrder: 70],
        [category: 'Seismic and Flood', label: 'USGS Earthquakes', url: 'https://earthquake.usgs.gov/earthquakes/feed/v1.0/geojson.php', description: 'USGS GeoJSON earthquake feeds', sortOrder: 80],
        [category: 'Seismic and Flood', label: 'USGS Water Data', url: 'https://waterdata.usgs.gov/', description: 'Stream gauge and water observation data', sortOrder: 90],
        [category: 'New Mexico', label: 'NM DHSEM', url: 'https://www.dhsem.nm.gov/', description: 'New Mexico emergency management', sortOrder: 100],
        [category: 'New Mexico', label: 'NM RGIS', url: 'https://rgis.unm.edu/', description: 'New Mexico geospatial data clearinghouse', sortOrder: 110],
        [category: 'GIS', label: 'GeoPlatform', url: 'https://www.geoplatform.gov/', description: 'Federal geospatial platform', sortOrder: 120],
        [category: 'GIS', label: 'Data.gov Geospatial', url: 'https://catalog.data.gov/dataset/?metadata_type=geospatial', description: 'Open geospatial datasets', sortOrder: 130]
    ]

    def init = { servletContext ->
        seedAppChromeContent()
        seedLookupCategory('airport.overallStatus', AIRPORT_OVERALL_STATUSES)
        deactivateLookupValuesNotInList('airport.overallStatus', AIRPORT_OVERALL_STATUSES)
        seedLookupCategory('airport.operationalStatus', [
            GREEN,
            YELLOW,
            RED,
            BLACK,
            NA
        ])
        seedLookupCategory('currentSit.status', [
            GREEN,
            YELLOW,
            RED,
            BLACK,
            'N/A'
        ])
        seedLookupCategory('airfieldSurface.condition', [
            'Construction',
            'Damaged',
            'Destroyed',
            'Patched FFM',
            'Patched Other',
            'Not Damaged'
        ])
        seedLookupCategory('navaid.status', [
            'GREEN',
            'YELLOW',
            'RED',
            'UNKNOWN',
            NA
        ])
        seedLookupCategory('asset.airfieldName', NEW_MEXICO_AIRFIELDS)
        seedLookupCategory('asset.serviceOwner', EMERGENCY_RESPONSE_AGENCIES)
        deactivateLookupValuesNotInList('asset.serviceOwner', EMERGENCY_RESPONSE_AGENCIES)

        if (seedDevelopmentData()) {
            seedAirportStatusData()
            seedAirfieldSurfaceData()
            seedEngineerAssetData()
            seedFireFightingAssetData()
            seedUtilityStatusData()
        }
    }

    def destroy = {
    }

    private void seedAppChromeContent() {
        AppBannerText.withTransaction {
            DEFAULT_BANNER_TEXTS.each { Map row ->
                AppBannerText bannerText = AppBannerText.findBySlot(row.slot as String)
                if (!bannerText) {
                    new AppBannerText(
                        slot: row.slot,
                        label: row.label,
                        textValue: row.textValue,
                        sortOrder: row.sortOrder,
                        active: true
                    ).save(failOnError: true)
                } else if (row.previousTextValue && bannerText.textValue == row.previousTextValue) {
                    bannerText.textValue = row.textValue
                    bannerText.save(failOnError: true)
                }
            }
        }

        AppQuickLink.withTransaction {
            DEFAULT_QUICK_LINKS.each { Map row ->
                if (!AppQuickLink.findByLabelAndUrl(row.label as String, row.url as String)) {
                    new AppQuickLink(
                        label: row.label,
                        url: row.url,
                        category: row.category,
                        description: row.description,
                        sortOrder: row.sortOrder,
                        active: true,
                        openInNewWindow: true
                    ).save(failOnError: true)
                }
            }
        }
    }

    private void seedLookupCategory(String category, List<String> values) {
        AirportLookupOption.withTransaction {
            values.eachWithIndex { String value, int index ->
                AirportLookupOption option = AirportLookupOption.findByCategoryAndValue(category, value)
                if (!option) {
                    new AirportLookupOption(
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

    private void deactivateLookupValuesNotInList(String category, List<String> values) {
        AirportLookupOption.withTransaction {
            AirportLookupOption.findAllByCategory(category).each { AirportLookupOption option ->
                if (option.active && !values.contains(option.value)) {
                    option.active = false
                    option.save(failOnError: true)
                }
            }
        }
    }

    private boolean seedDevelopmentData() {
        Environment.current != Environment.PRODUCTION
    }

    private void seedAirportStatusData() {
        AirportStatus.withTransaction {
            Date now = new Date()
            List<Map> records = [
                [
                    name: 'Albuquerque International Sunport',
                    overall: GREEN,
                    ops: GREEN,
                    mx: GREEN,
                    muns: NA,
                    pol: GREEN,
                    primary: GREEN,
                    secondary: GREEN,
                    airfield: GREEN,
                    infrastructure: GREEN,
                    atcals: GREEN,
                    c4i: GREEN,
                    cyber: GREEN,
                    radio: GREEN,
                    defense: GREEN,
                    remarks: 'Commercial hub available for contingency passenger and cargo movement.'
                ],
                [
                    name: 'Kirtland AFB',
                    overall: GREEN,
                    ops: GREEN,
                    mx: YELLOW,
                    muns: GREEN,
                    pol: GREEN,
                    primary: GREEN,
                    secondary: YELLOW,
                    airfield: GREEN,
                    infrastructure: YELLOW,
                    atcals: GREEN,
                    c4i: GREEN,
                    cyber: GREEN,
                    radio: GREEN,
                    defense: GREEN,
                    remarks: 'Primary operations are available; one maintenance bay is capacity limited.'
                ],
                [
                    name: 'Holloman AFB',
                    overall: YELLOW,
                    ops: YELLOW,
                    mx: GREEN,
                    muns: GREEN,
                    pol: GREEN,
                    primary: YELLOW,
                    secondary: GREEN,
                    airfield: YELLOW,
                    infrastructure: GREEN,
                    atcals: YELLOW,
                    c4i: GREEN,
                    cyber: GREEN,
                    radio: YELLOW,
                    defense: GREEN,
                    remarks: 'Crosswind runway available while primary runway shoulder work continues.'
                ],
                [
                    name: 'Cannon AFB',
                    overall: GREEN,
                    ops: GREEN,
                    mx: GREEN,
                    muns: GREEN,
                    pol: YELLOW,
                    primary: GREEN,
                    secondary: GREEN,
                    airfield: GREEN,
                    infrastructure: GREEN,
                    atcals: GREEN,
                    c4i: GREEN,
                    cyber: GREEN,
                    radio: GREEN,
                    defense: GREEN,
                    remarks: 'Fuel distribution is using a reduced pump set until parts arrive.'
                ],
                [
                    name: 'Santa Fe Regional Airport',
                    overall: GREEN,
                    ops: GREEN,
                    mx: YELLOW,
                    muns: NA,
                    pol: GREEN,
                    primary: GREEN,
                    secondary: GREEN,
                    airfield: GREEN,
                    infrastructure: GREEN,
                    atcals: YELLOW,
                    c4i: GREEN,
                    cyber: GREEN,
                    radio: GREEN,
                    defense: GREEN,
                    remarks: 'Regional airport suitable for staging light cargo and liaison aircraft.'
                ],
                [
                    name: 'Roswell Air Center',
                    overall: GREEN,
                    ops: GREEN,
                    mx: GREEN,
                    muns: NA,
                    pol: GREEN,
                    primary: GREEN,
                    secondary: GREEN,
                    airfield: GREEN,
                    infrastructure: GREEN,
                    atcals: GREEN,
                    c4i: GREEN,
                    cyber: GREEN,
                    radio: GREEN,
                    defense: YELLOW,
                    remarks: 'Large ramp and hangar capacity available; security staffing is augmented.'
                ],
                [
                    name: 'Las Cruces International Airport',
                    overall: YELLOW,
                    ops: GREEN,
                    mx: YELLOW,
                    muns: NA,
                    pol: YELLOW,
                    primary: GREEN,
                    secondary: GREEN,
                    airfield: GREEN,
                    infrastructure: YELLOW,
                    atcals: YELLOW,
                    c4i: GREEN,
                    cyber: GREEN,
                    radio: GREEN,
                    defense: GREEN,
                    remarks: 'Generator-backed facilities are online during commercial power maintenance.'
                ],
                [
                    name: 'Lea County Regional Airport',
                    overall: GREEN,
                    ops: GREEN,
                    mx: GREEN,
                    muns: NA,
                    pol: GREEN,
                    primary: GREEN,
                    secondary: GREEN,
                    airfield: GREEN,
                    infrastructure: GREEN,
                    atcals: GREEN,
                    c4i: GREEN,
                    cyber: GREEN,
                    radio: GREEN,
                    defense: GREEN,
                    remarks: 'No significant degradation reported.'
                ],
                [
                    name: 'Four Corners Regional Airport',
                    overall: YELLOW,
                    ops: YELLOW,
                    mx: GREEN,
                    muns: NA,
                    pol: GREEN,
                    primary: YELLOW,
                    secondary: GREEN,
                    airfield: YELLOW,
                    infrastructure: GREEN,
                    atcals: GREEN,
                    c4i: GREEN,
                    cyber: GREEN,
                    radio: GREEN,
                    defense: GREEN,
                    remarks: 'Runway lighting repairs are complete; final inspection remains open.'
                ],
                [
                    name: 'Grant County Airport',
                    overall: GREEN,
                    ops: GREEN,
                    mx: GREEN,
                    muns: NA,
                    pol: GREEN,
                    primary: GREEN,
                    secondary: GREEN,
                    airfield: GREEN,
                    infrastructure: GREEN,
                    atcals: GREEN,
                    c4i: GREEN,
                    cyber: GREEN,
                    radio: GREEN,
                    defense: GREEN,
                    remarks: 'Available as a western New Mexico diversion and staging location.'
                ],
                [
                    name: 'Spaceport America',
                    overall: YELLOW,
                    ops: YELLOW,
                    mx: YELLOW,
                    muns: NA,
                    pol: YELLOW,
                    primary: GREEN,
                    secondary: NA,
                    airfield: GREEN,
                    infrastructure: YELLOW,
                    atcals: YELLOW,
                    c4i: GREEN,
                    cyber: GREEN,
                    radio: YELLOW,
                    defense: GREEN,
                    remarks: 'Restricted operations require coordination with range control.'
                ],
                [
                    name: 'Double Eagle II Airport',
                    overall: GREEN,
                    ops: GREEN,
                    mx: GREEN,
                    muns: NA,
                    pol: GREEN,
                    primary: GREEN,
                    secondary: GREEN,
                    airfield: GREEN,
                    infrastructure: GREEN,
                    atcals: GREEN,
                    c4i: GREEN,
                    cyber: GREEN,
                    radio: GREEN,
                    defense: GREEN,
                    remarks: 'General aviation field available for light aircraft staging.'
                ],
                [
                    name: 'Alamogordo-White Sands Regional',
                    overall: RED,
                    ops: YELLOW,
                    mx: YELLOW,
                    muns: NA,
                    pol: YELLOW,
                    primary: RED,
                    secondary: YELLOW,
                    airfield: RED,
                    infrastructure: YELLOW,
                    atcals: YELLOW,
                    c4i: GREEN,
                    cyber: GREEN,
                    radio: YELLOW,
                    defense: GREEN,
                    remarks: 'Primary runway closed for survey; emergency response remains available.'
                ],
                [
                    name: 'Ruidoso Sierra Blanca Regional',
                    overall: YELLOW,
                    ops: YELLOW,
                    mx: GREEN,
                    muns: NA,
                    pol: YELLOW,
                    primary: YELLOW,
                    secondary: NA,
                    airfield: YELLOW,
                    infrastructure: YELLOW,
                    atcals: GREEN,
                    c4i: GREEN,
                    cyber: GREEN,
                    radio: GREEN,
                    defense: GREEN,
                    remarks: 'Mountain weather can reduce operating windows; fuel resupply scheduled.'
                ],
                [
                    name: 'Truth or Consequences Municipal',
                    overall: BLACK,
                    ops: RED,
                    mx: YELLOW,
                    muns: NA,
                    pol: RED,
                    primary: BLACK,
                    secondary: RED,
                    airfield: BLACK,
                    infrastructure: RED,
                    atcals: RED,
                    c4i: YELLOW,
                    cyber: GREEN,
                    radio: RED,
                    defense: YELLOW,
                    remarks: 'Training scenario: runway unavailable after simulated storm damage.'
                ]
            ]

            records.eachWithIndex { Map record, int index ->
                if (AirportStatus.countByAirfieldName(record.name as String) == 0) {
                    Date updated = daysAgo(now, index)
                    AirportStatus status = new AirportStatus(
                        objectId: "APT-${index + 1}".toString(),
                        airfieldName: record.name,
                        overall: record.overall,
                        ops: record.ops,
                        opsRemarks: record.remarks,
                        mx: record.mx,
                        mxRemarks: 'Maintenance posture loaded from development bootstrap data.',
                        muns: record.muns,
                        munsRemarks: record.muns == NA ? 'Not applicable for this location.' : 'Supply support status seeded for testing.',
                        pol: record.pol,
                        polRemarks: 'Fuel and POL status seeded for dashboard testing.',
                        rwPri: record.primary,
                        rwPriRemarks: 'Primary runway status seeded for testing.',
                        rwSec: record.secondary,
                        rwSecRemarks: 'Secondary runway status seeded for testing.',
                        airfield: record.airfield,
                        airfieldRemarks: record.remarks,
                        infrastructure: record.infrastructure,
                        infraRemarks: 'Infrastructure status seeded for testing.',
                        atcalsNavaids: record.atcals,
                        atcalsNavaidsRemarks: 'Navigation and air traffic support status seeded for testing.',
                        c4i: record.c4i,
                        c4iRemarks: 'C4I status seeded for testing.',
                        cyber: record.cyber,
                        cyberRemarks: 'Cyber status seeded for testing.',
                        radio: record.radio,
                        radioRemarks: 'Radio communications status seeded for testing.',
                        baseDefense: record.defense,
                        baseDefenseRemarks: 'Security status seeded for testing.',
                        mapit: mapLink('airportStatus', 'site_name', record.name as String),
                        korean: '',
                        sort: index + 1,
                        active: 'YES',
                        absUpdatedBy: 'bootstrap',
                        lastUpdated: updated,
                        sortBy: index + 1
                    ).save(failOnError: true, flush: true)

                    CurrentSIT current = CurrentSIT.get(status.id)
                    if (current) {
                        current.airfieldName = record.name
                        current.korean = ''
                        current.ceoverall = record.overall
                        current.runway = record.primary
                        current.runwaytwo = record.secondary
                        current.airfield = record.airfield
                        current.facilities = record.infrastructure
                        current.utilities = record.pol
                        current.emerresp = record.defense
                        current.nbcipe = record.infrastructure
                        current.firepersonnel = index % 4 == 0 ? YELLOW : GREEN
                        current.eodpersonnel = index % 5 == 0 ? YELLOW : GREEN
                        current.nbcpersonnel = index % 6 == 0 ? YELLOW : GREEN
                        current.engpersonnel = index % 3 == 0 ? YELLOW : GREEN
                        current.overpersonnel = record.overall
                        current.fireassets = index % 4 == 0 ? YELLOW : GREEN
                        current.eodassets = index % 5 == 0 ? YELLOW : GREEN
                        current.nbcassets = index % 6 == 0 ? YELLOW : GREEN
                        current.snowassets = NA
                        current.engassets = record.mx
                        current.overassets = record.overall
                        current.remarks = record.remarks
                        current.mapit = mapLink('airportStatus', 'site_name', record.name as String)
                        current.sort = index + 1
                        current.active = 'YES'
                        current.cedUpdatedBy = 'bootstrap'
                        current.lastUpdated = updated
                        current.save(failOnError: true, flush: true)
                    }
                }
            }
        }
    }

    private void seedAirfieldSurfaceData() {
        AirfieldSurfaceStatus.withTransaction {
            Date now = new Date()
            List<Map> records = [
                [airfieldName: 'Kirtland AFB', runway: '08/26', sectionLabel: 'TWY A Intersection', condition: 'Not Damaged', repairStatus: 'Open', notes: 'Surface inspection complete.'],
                [airfieldName: 'Holloman AFB', runway: '07/25', sectionLabel: 'West Shoulder', condition: 'Patched Other', repairStatus: 'Monitoring', notes: 'Temporary shoulder patch in place.'],
                [airfieldName: 'Cannon AFB', runway: '04/22', sectionLabel: 'Fuel Apron', condition: 'Construction', repairStatus: 'In Progress', notes: 'Apron work limits heavy parking.'],
                [airfieldName: 'Alamogordo-White Sands Regional', runway: '03/21', sectionLabel: 'Midfield', condition: 'Damaged', repairStatus: 'Assessing', notes: 'Training scenario damage pending repair estimate.'],
                [airfieldName: 'Truth or Consequences Municipal', runway: '13/31', sectionLabel: 'North Threshold', condition: 'Destroyed', repairStatus: 'Not Started', notes: 'Training scenario closure.'],
                [airfieldName: 'Roswell Air Center', runway: '03/21', sectionLabel: 'Main Ramp', condition: 'Not Damaged', repairStatus: 'Closed', notes: 'No active repair action required.']
            ]

            records.eachWithIndex { Map record, int index ->
                String objectId = "RWD-${index + 1}".toString()
                if (!AirfieldSurfaceStatus.findByObjectId(objectId)) {
                    new AirfieldSurfaceStatus(
                        objectId: objectId,
                        airfieldName: record.airfieldName,
                        runway: record.runway,
                        sectionLabel: record.sectionLabel,
                        condition: record.condition,
                        notes: record.notes,
                        repairStatus: record.repairStatus,
                        updatedBy: 'bootstrap',
                        lastUpdated: daysAgo(now, index)
                    ).save(failOnError: true)
                }
            }
        }
    }

    private void seedEngineerAssetData() {
        EngineerAssets.withTransaction {
            List<Map> records = [
                [airfieldName: 'Kirtland AFB', locationName: 'Public works yard', serviceOwner: 'New Mexico Department of Transportation', itemName: 'Rapid runway repair kit', utc: '4F9RR', nsn: '3895-01-001-0001', avai: 4.0f, auth: 6.0f, remarks: 'Two kits positioned near the main apron.'],
                [airfieldName: 'Holloman AFB', locationName: 'Engineer staging', serviceOwner: 'U.S. Army Corps of Engineers', itemName: 'Airfield lighting repair set', utc: '4F9LT', nsn: '6210-01-001-0002', avai: 3.0f, auth: 3.0f, remarks: 'Fully mission capable.'],
                [airfieldName: 'Cannon AFB', locationName: 'Emergency staging lot', serviceOwner: 'FEMA', itemName: 'Loader with bucket', utc: '4F9LD', nsn: '3805-01-001-0003', avai: 5.0f, auth: 4.0f, remarks: 'One excess loader available for mutual support.'],
                [airfieldName: 'Las Cruces International Airport', locationName: 'Public works yard', serviceOwner: 'New Mexico DHSEM', itemName: 'Mobile generator', utc: 'GEN30', nsn: '6115-01-001-0004', avai: 2.0f, auth: 3.0f, remarks: 'One additional generator requested.'],
                [airfieldName: 'Roswell Air Center', locationName: 'Hangar 84', serviceOwner: 'Contractor / Mutual Aid', itemName: 'Sweeper truck', utc: 'SWP01', nsn: '3825-01-001-0005', avai: 2.0f, auth: 2.0f, remarks: 'Supports ramp FOD control.']
            ]

            records.each { Map record ->
                EngineerAssets asset = EngineerAssets.findByAirfieldNameAndLocationNameAndItemName(
                    record.airfieldName as String,
                    record.locationName as String,
                    record.itemName as String
                ) ?: new EngineerAssets()

                asset.properties = [
                    airfieldName: record.airfieldName,
                    locationName: record.locationName,
                    serviceOwner: record.serviceOwner,
                    itemName: record.itemName,
                    utc: record.utc,
                    nsn: record.nsn,
                    avai: record.avai,
                    auth: record.auth,
                    remarks: record.remarks,
                    createdBy: 'bootstrap',
                    editedBy: 'bootstrap'
                ]
                asset.save(failOnError: true)
            }
        }
    }

    private void seedFireFightingAssetData() {
        FireFightingAssets.withTransaction {
            List<Map> records = [
                [airfieldName: 'Kirtland AFB', locationName: 'Fire Station 1', serviceOwner: 'Local Fire Department', itemName: 'ARFF vehicle', utc: 'ARFF1', nsn: '4210-01-001-0101', avai: 3.0f, auth: 3.0f, remarks: 'All crash rescue vehicles available.'],
                [airfieldName: 'Holloman AFB', locationName: 'Fire Station 2', serviceOwner: 'New Mexico State Fire Marshal', itemName: 'Foam tender', utc: 'FOAM1', nsn: '4210-01-001-0102', avai: 1.0f, auth: 2.0f, remarks: 'One tender in scheduled maintenance.'],
                [airfieldName: 'Roswell Air Center', locationName: 'ARFF station', serviceOwner: 'Municipal Airport Authority', itemName: 'ARFF vehicle', utc: 'ARFF2', nsn: '4210-01-001-0103', avai: 2.0f, auth: 2.0f, remarks: 'Civil ARFF support available.'],
                [airfieldName: 'Las Cruces International Airport', locationName: 'Fire bay', serviceOwner: 'New Mexico Department of Health EMS Bureau', itemName: 'Rescue truck', utc: 'RESC1', nsn: '4210-01-001-0104', avai: 1.0f, auth: 1.0f, remarks: 'Available during published operating hours.'],
                [airfieldName: 'Truth or Consequences Municipal', locationName: 'Municipal station', serviceOwner: 'County Emergency Management', itemName: 'Mutual aid engine', utc: 'ENG1', nsn: '4210-01-001-0105', avai: 0.0f, auth: 1.0f, remarks: 'Training scenario: no dedicated ARFF vehicle on site.']
            ]

            records.each { Map record ->
                FireFightingAssets asset = FireFightingAssets.findByAirfieldNameAndLocationNameAndItemName(
                    record.airfieldName as String,
                    record.locationName as String,
                    record.itemName as String
                ) ?: new FireFightingAssets()

                asset.properties = [
                    airfieldName: record.airfieldName,
                    locationName: record.locationName,
                    serviceOwner: record.serviceOwner,
                    itemName: record.itemName,
                    utc: record.utc,
                    nsn: record.nsn,
                    avai: record.avai,
                    auth: record.auth,
                    remarks: record.remarks,
                    createdBy: 'bootstrap',
                    editedBy: 'bootstrap'
                ]
                asset.save(failOnError: true)
            }
        }
    }

    private void seedUtilityStatusData() {
        UtilityStatus.withTransaction {
            Date now = new Date()
            List<Map> records = [
                [airfieldName: 'Kirtland AFB', potableWater: GREEN, nonPotableWater: GREEN, electricalPower: GREEN, sewage: GREEN, fuel: GREEN],
                [airfieldName: 'Holloman AFB', potableWater: GREEN, nonPotableWater: GREEN, electricalPower: YELLOW, sewage: GREEN, fuel: GREEN],
                [airfieldName: 'Cannon AFB', potableWater: GREEN, nonPotableWater: GREEN, electricalPower: GREEN, sewage: GREEN, fuel: YELLOW],
                [airfieldName: 'Las Cruces International Airport', potableWater: GREEN, nonPotableWater: YELLOW, electricalPower: YELLOW, sewage: GREEN, fuel: YELLOW],
                [airfieldName: 'Roswell Air Center', potableWater: GREEN, nonPotableWater: GREEN, electricalPower: GREEN, sewage: GREEN, fuel: GREEN],
                [airfieldName: 'Truth or Consequences Municipal', potableWater: RED, nonPotableWater: RED, electricalPower: BLACK, sewage: RED, fuel: RED]
            ]

            records.eachWithIndex { Map record, int index ->
                if (!UtilityStatus.findByAirfieldName(record.airfieldName as String)) {
                    new UtilityStatus(
                        airfieldName: record.airfieldName,
                        potableWater: record.potableWater,
                        nonPotableWater: record.nonPotableWater,
                        electricalPower: record.electricalPower,
                        sewage: record.sewage,
                        fuel: record.fuel,
                        updatedDate: daysAgo(now, index)
                    ).save(failOnError: true)
                }
            }
        }
    }

    private Date daysAgo(Date baseDate, int days) {
        long offsetMillis = days * 24L * 60L * 60L * 1000L
        new Date(baseDate.time - offsetMillis)
    }

    private String mapLink(String layer, String field, String value) {
        "/GeoStatusBoard/map?layer=${layer}&field=${field}&value=${URLEncoder.encode(value ?: '', 'UTF-8')}"
    }
}
