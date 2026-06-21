package geospatial.statusboard

import grails.core.GrailsApplication
import grails.plugin.springsecurity.annotation.Secured
import groovy.json.JsonOutput

import javax.sql.DataSource
import java.sql.Connection
import java.sql.DriverManager
import java.sql.ResultSet
import java.sql.Statement
import java.time.Instant

@Secured(['ROLE_USER'])
class GeoHealthController {

    GrailsApplication grailsApplication
    DataSource dataSource

    def index() {
        Map geoConfig = asMap(grailsApplication.config.geo)
        Map geoserverConfig = asMap(geoConfig.geoserver)
        Map geoaiConfig = asMap(geoConfig.geoai)
        Map gatewayConfig = asMap(geoConfig.gateway)
        Map openclawConfig = asMap(geoConfig.openclaw)
        Map healthConfig = asMap(geoConfig.health)
        int timeoutMs = asInteger(healthConfig.requestTimeoutMs, 2500)

        Map payload = [
            checkedAt: Instant.now().toString(),
            services : [
                geoserver: checkHttp(
                    'GeoServer',
                    geoserverHealthUrl(geoserverConfig.wfsUrl?.toString()),
                    timeoutMs
                ),
                postgis  : checkPostgis(),
                geoai    : checkHttp(
                    'GeoAI API',
                    geoaiHealthUrl(geoaiConfig),
                    timeoutMs
                ),
                gateway  : checkHttp(
                    'Data Gateway',
                    gatewayHealthUrl(gatewayConfig),
                    timeoutMs
                ),
                openclaw : checkHttp(
                    'OpenClaw',
                    openclawHealthUrl(openclawConfig),
                    timeoutMs
                )
            ]
        ]

        render(contentType: 'application/json', text: JsonOutput.toJson(payload))
    }

    private Map checkHttp(String label, String url, int timeoutMs) {
        if (!url) {
            return status(false, label, 'Not configured')
        }

        HttpURLConnection connection = null
        try {
            connection = new URL(url).openConnection() as HttpURLConnection
            connection.connectTimeout = timeoutMs
            connection.readTimeout = timeoutMs
            connection.requestMethod = 'GET'
            int code = connection.responseCode
            boolean up = code >= 200 && code < 400
            return status(up, label, "HTTP ${code}", [url: url])
        } catch (Exception ex) {
            return status(false, label, ex.message ?: ex.class.simpleName, [url: url])
        } finally {
            connection?.disconnect()
        }
    }

    private Map checkPostgis() {
        try {
            Connection connection = dataSource.connection
            try {
                String product = connection.metaData.databaseProductName ?: 'database'
                if (!product.toLowerCase().contains('postgresql')) {
                    return checkConfiguredPostgis("App datasource is ${product}")
                }

                return checkPostgisConnection(connection, [:])
            } finally {
                connection.close()
            }
        } catch (Exception ex) {
            return checkConfiguredPostgis(ex.message ?: ex.class.simpleName)
        }
    }

    private Map checkConfiguredPostgis(String fallbackReason) {
        String host = System.getenv('POSTGIS_HOST') ?: 'localhost'
        String port = System.getenv('POSTGIS_PORT') ?: '5432'
        String db = System.getenv('POSTGIS_DB') ?: 'geostatusboard'
        String user = System.getenv('POSTGIS_USER') ?: 'gsb'
        String password = System.getenv('POSTGIS_PASSWORD') ?: 'gsb'
        String url = "jdbc:postgresql://${host}:${port}/${db}"

        try {
            Connection connection = DriverManager.getConnection(url, user, password)
            try {
                return checkPostgisConnection(connection, [
                    url: url,
                    datasource: fallbackReason
                ])
            } finally {
                connection.close()
            }
        } catch (Exception ex) {
            return status(false, 'PostGIS', ex.message ?: ex.class.simpleName, [
                url: url,
                datasource: fallbackReason
            ])
        }
    }

    private Map checkPostgisConnection(Connection connection, Map details) {
        Statement statement = connection.createStatement()
        try {
            ResultSet rs = statement.executeQuery('SELECT PostGIS_Version()')
            try {
                String version = rs.next() ? rs.getString(1) : 'available'
                return status(true, 'PostGIS', version, details)
            } finally {
                rs.close()
            }
        } finally {
            statement.close()
        }
    }

    private String geoserverHealthUrl(String wfsUrl) {
        if (!wfsUrl) {
            return ''
        }
        String separator = wfsUrl.contains('?') ? '&' : '?'
        "${wfsUrl}${separator}service=WFS&version=1.0.0&request=GetCapabilities"
    }

    private String geoaiHealthUrl(Map geoaiConfig) {
        String explicitHealthUrl = geoaiConfig.healthUrl?.toString()
        if (explicitHealthUrl) {
            return explicitHealthUrl
        }

        String apiUrl = geoaiConfig.apiUrl?.toString()
        apiUrl ? "${apiUrl.replaceAll('/+$', '')}/health" : ''
    }

    private String gatewayHealthUrl(Map gatewayConfig) {
        if (!asBoolean(gatewayConfig.enabled, true)) {
            return ''
        }

        String explicitHealthUrl = gatewayConfig.healthUrl?.toString()
        if (explicitHealthUrl) {
            return explicitHealthUrl
        }

        String hubUrl = gatewayConfig.hubUrl?.toString()
        if (!hubUrl) {
            return ''
        }

        String trimmed = hubUrl.replaceAll('/+$', '')
        int hubIndex = trimmed.indexOf('/hubs/')
        String baseUrl = hubIndex > 0 ? trimmed.substring(0, hubIndex) : trimmed
        "${baseUrl}/health"
    }

    private String openclawHealthUrl(Map openclawConfig) {
        if (!asBoolean(openclawConfig.enabled, true)) {
            return ''
        }

        String explicitHealthUrl = openclawConfig.healthUrl?.toString()
        if (explicitHealthUrl) {
            return explicitHealthUrl
        }

        String gatewayUrl = openclawConfig.gatewayUrl?.toString()
        gatewayUrl ? "${gatewayUrl.replaceAll('/+$', '')}/healthz" : ''
    }

    private Map status(boolean up, String label, String message, Map details = [:]) {
        [
            status : up ? 'up' : 'down',
            label  : label,
            message: message,
            details: details
        ]
    }

    private Map asMap(Object value) {
        if (value instanceof Map) {
            return value.collectEntries { Object key, Object entryValue ->
                [key.toString(), entryValue]
            }
        }

        [:]
    }

    private int asInteger(Object value, int defaultValue) {
        if (value == null) {
            return defaultValue
        }

        if (value instanceof Number) {
            return value as int
        }

        value.toString().isInteger() ? value.toString() as int : defaultValue
    }

    private boolean asBoolean(Object value, boolean defaultValue) {
        if (value == null) {
            return defaultValue
        }

        value instanceof Boolean ? value : value.toString().toBoolean()
    }
}
