package gsb.incidents

class IncidentWorkflowStatus {
    static final String NEW = 'New'
    static final List<String> STATUSES = [
        NEW,
        'Acknowledged',
        'Needs Action',
        'Significant Event',
        'Trending Downward',
        'Upward',
        'Closed'
    ].asImmutable()

    static String normalize(String value) {
        String candidate = value?.trim()
        STATUSES.find { String status ->
            status.equalsIgnoreCase(candidate ?: '')
        } ?: NEW
    }
}
