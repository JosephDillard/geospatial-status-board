package geospatial.statusboard

import grails.core.GrailsApplication
import grails.plugin.springsecurity.annotation.Secured
import groovy.sql.GroovyRowResult
import groovy.sql.Sql
import groovy.json.JsonOutput
import groovy.json.JsonSlurper

import javax.sql.DataSource

@Secured(['ROLE_USER'])
class GeoAiController {

    GrailsApplication grailsApplication
    DataSource dataSource

    private static final String PERSISTED_JOBS_SQL = '''
        WITH feature_counts AS (
            SELECT job_id,
                   COUNT(*) AS feature_count,
                   MAX(loaded_at::timestamptz) AS feature_loaded_at,
                   MAX(workflow_id) AS workflow_id
            FROM public.detected_roads
            WHERE job_id IS NOT NULL
              AND btrim(job_id) <> ''
            GROUP BY job_id
        )
        SELECT COALESCE(j.job_id, f.job_id) AS job_id,
               COALESCE(j.workflow_id, f.workflow_id, '') AS workflow_id,
               COALESCE(f.feature_count, j.feature_count, 0) AS feature_count,
               COALESCE(j.loaded_at, f.feature_loaded_at) AS loaded_at,
               COALESCE(j.status, 'loaded') AS status
        FROM public.geoai_jobs j
        FULL OUTER JOIN feature_counts f ON f.job_id = j.job_id
        WHERE COALESCE(j.job_id, f.job_id) IS NOT NULL
          AND btrim(COALESCE(j.job_id, f.job_id)) <> ''
        ORDER BY COALESCE(j.loaded_at, f.feature_loaded_at) DESC NULLS LAST,
                 COALESCE(j.job_id, f.job_id) DESC
        LIMIT ?
    '''

    private static final String FEATURE_JOBS_SQL = '''
        SELECT job_id,
               COALESCE(MAX(workflow_id), '') AS workflow_id,
               COUNT(*) AS feature_count,
               MAX(loaded_at::timestamptz) AS loaded_at,
               'loaded' AS status
        FROM public.detected_roads
        WHERE job_id IS NOT NULL
          AND btrim(job_id) <> ''
        GROUP BY job_id
        ORDER BY MAX(loaded_at::timestamptz) DESC NULLS LAST, job_id DESC
        LIMIT ?
    '''

    private static final String JOBS_ONLY_SQL = '''
        SELECT job_id,
               COALESCE(workflow_id, '') AS workflow_id,
               COALESCE(feature_count, 0) AS feature_count,
               loaded_at,
               COALESCE(status, 'loaded') AS status
        FROM public.geoai_jobs
        WHERE job_id IS NOT NULL
          AND btrim(job_id) <> ''
        ORDER BY loaded_at DESC NULLS LAST, job_id DESC
        LIMIT ?
    '''

    private static final String BASIC_FEATURE_JOBS_SQL = '''
        SELECT job_id,
               '' AS workflow_id,
               COUNT(*) AS feature_count,
               NULL AS loaded_at,
               'loaded' AS status
        FROM public.detected_roads
        WHERE job_id IS NOT NULL
          AND btrim(job_id) <> ''
        GROUP BY job_id
        ORDER BY job_id DESC
        LIMIT ?
    '''

    def options() {
        proxyJson('GET', '/run-options')
    }

    def jobs() {
        int limit = asInteger(params.limit, 100)
        limit = Math.max(1, Math.min(limit, 500))
        renderJson([jobs: queryJobs(limit)])
    }

    def createRun() {
        proxyJson('POST', '/runs', request.JSON as Map)
    }

    def runStatus(String id) {
        if (!id) {
            response.status = 400
            renderJson([detail: 'Run id is required'])
            return
        }

        proxyJson('GET', "/runs/${encodePathSegment(id)}")
    }

    private void proxyJson(String method, String path, Map body = null) {
        Map geoConfig = asMap(grailsApplication.config.geo)
        Map geoaiConfig = asMap(geoConfig.geoai)
        String apiUrl = geoaiConfig.apiUrl?.toString()?.replaceAll('/+$', '')
        int timeoutMs = asInteger(geoaiConfig.requestTimeoutMs, 5000)

        if (!apiUrl) {
            response.status = 503
            renderJson([detail: 'GeoAI API URL is not configured'])
            return
        }

        HttpURLConnection connection = null
        try {
            connection = new URL("${apiUrl}${path}").openConnection() as HttpURLConnection
            connection.connectTimeout = timeoutMs
            connection.readTimeout = timeoutMs
            connection.requestMethod = method
            connection.setRequestProperty('Accept', 'application/json')

            if (body != null) {
                connection.doOutput = true
                connection.setRequestProperty('Content-Type', 'application/json')
                connection.outputStream.withWriter('UTF-8') { writer ->
                    writer << JsonOutput.toJson(body)
                }
            }

            int code = connection.responseCode
            String text = readResponse(connection, code)
            response.status = code
            render(contentType: 'application/json', text: text ?: '{}')
        } catch (Exception ex) {
            response.status = 503
            renderJson([
                detail : ex.message ?: ex.class.simpleName,
                service: 'GeoAI API'
            ])
        } finally {
            connection?.disconnect()
        }
    }

    private List<Map> queryJobs(int limit) {
        Sql sql = new Sql(dataSource)
        try {
            List<Map> jobs = rowsFor(sql, PERSISTED_JOBS_SQL, limit) ?:
                rowsFor(sql, JOBS_ONLY_SQL, limit) ?:
                rowsFor(sql, FEATURE_JOBS_SQL, limit) ?:
                rowsFor(sql, BASIC_FEATURE_JOBS_SQL, limit)
            return jobs ?: queryJobsFromWfs(limit)
        } catch (Exception ignored) {
            queryJobsFromWfs(limit)
        } finally {
            sql.close()
        }
    }

    private List<Map> queryJobsFromWfs(int limit) {
        Map geoConfig = asMap(grailsApplication.config.geo)
        Map geoserverConfig = asMap(geoConfig.geoserver)
        Map detectedLayer = asMap(asMap(geoConfig.layers).detectedRoads)
        String wfsUrl = geoserverConfig.wfsUrl?.toString()
        String typeName = detectedLayer.typeName?.toString() ?: 'gsb:detected_roads'
        int timeoutMs = asInteger(geoserverConfig.requestTimeoutMs, 5000)
        int maxFeatures = Math.max(limit, asInteger(detectedLayer.maxFeatures, 5000))

        if (!wfsUrl || !typeName) {
            return []
        }

        Map query = [
            service     : 'WFS',
            version     : '1.0.0',
            request     : 'GetFeature',
            typeName    : typeName,
            propertyName: 'job_id,workflow_id,loaded_at',
            outputFormat: 'application/json',
            maxFeatures : maxFeatures
        ]
        String separator = wfsUrl.contains('?') ? '&' : '?'
        String requestUrl = "${wfsUrl}${separator}${query.collect { String key, Object value ->
            "${encodeQueryParam(key)}=${encodeQueryParam(value)}"
        }.join('&')}"

        HttpURLConnection connection = null
        try {
            connection = new URL(requestUrl).openConnection() as HttpURLConnection
            connection.connectTimeout = timeoutMs
            connection.readTimeout = timeoutMs
            connection.requestMethod = 'GET'
            connection.setRequestProperty('Accept', 'application/json')

            int code = connection.responseCode
            if (code < 200 || code >= 300) {
                return []
            }

            def payload = new JsonSlurper().parseText(readResponse(connection, code) ?: '{}')
            Map<String, Map> jobsById = [:]
            (payload.features ?: []).each { Object feature ->
                Map properties = asMap(asMap(feature).properties)
                String jobId = properties.job_id?.toString()?.trim()
                if (jobId) {
                    Map job = jobsById[jobId]
                    if (!job) {
                        job = [
                            id           : jobId,
                            job_id       : jobId,
                            workflow_id  : '',
                            feature_count: 0L,
                            loaded_at    : '',
                            status       : 'loaded'
                        ]
                        jobsById[jobId] = job
                    }

                    job.feature_count = (job.feature_count as Long) + 1L
                    if (!job.workflow_id && properties.workflow_id) {
                        job.workflow_id = properties.workflow_id.toString()
                    }
                    String loadedAt = properties.loaded_at?.toString() ?: ''
                    if (loadedAt && (!job.loaded_at || loadedAt > job.loaded_at.toString())) {
                        job.loaded_at = loadedAt
                    }
                }
            }

            jobsById.values()
                .sort { Map left, Map right ->
                    int loadedCompare = (right.loaded_at?.toString() ?: '') <=> (left.loaded_at?.toString() ?: '')
                    loadedCompare ?: ((right.job_id?.toString() ?: '') <=> (left.job_id?.toString() ?: ''))
                }
                .take(limit)
        } catch (Exception ignored) {
            []
        } finally {
            connection?.disconnect()
        }
    }

    private List<Map> rowsFor(Sql sql, String query, int limit) {
        try {
            sql.rows(query, [limit]).collect { GroovyRowResult row ->
                [
                    id           : row.job_id?.toString() ?: '',
                    job_id       : row.job_id?.toString() ?: '',
                    workflow_id  : row.workflow_id?.toString() ?: '',
                    feature_count: row.feature_count instanceof Number ? row.feature_count as Long : 0L,
                    loaded_at    : row.loaded_at?.toString() ?: '',
                    status       : row.status?.toString() ?: 'loaded'
                ]
            }.findAll { Map job ->
                job.job_id
            }
        } catch (Exception ignored) {
            []
        }
    }

    private String readResponse(HttpURLConnection connection, int code) {
        InputStream stream = code >= 400 ? connection.errorStream : connection.inputStream
        stream ? stream.getText('UTF-8') : ''
    }

    private String encodePathSegment(String value) {
        URLEncoder.encode(value, 'UTF-8').replace('+', '%20')
    }

    private String encodeQueryParam(Object value) {
        URLEncoder.encode(value?.toString() ?: '', 'UTF-8')
    }

    private void renderJson(Map payload) {
        render(contentType: 'application/json', text: JsonOutput.toJson(payload))
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
}
