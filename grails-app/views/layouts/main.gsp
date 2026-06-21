<!doctype html>
<html lang="en" class="no-js">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <title>
        <g:layoutTitle default="Emergency Management"/>
    </title>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <%
        String faviconController = controllerName?.toString() ?: params.controller?.toString() ?: 'home'
        String faviconUri = request.forwardURI?.toString() ?: request.requestURI?.toString() ?: ''
        if (faviconUri.contains('/incident-analyst')) {
            faviconController = 'incidentAnalyst'
        }
        Map faviconConfig = [
            home                 : [text: 'H', color: '#1f7a8c'],
            map                  : [text: 'M', color: '#246b49'],
            incidentAnalyst      : [text: 'IA', color: '#b45309'],
            currentIncidents     : [text: 'CI', color: '#b91c1c'],
            archiveIncidents     : [text: 'AR', color: '#6d28d9'],
            airportStatus        : [text: 'AS', color: '#0369a1'],
            currentSIT           : [text: 'CS', color: '#0f766e'],
            airfieldSurfaceStatus: [text: 'AF', color: '#64748b'],
            navaid               : [text: 'N', color: '#2563eb'],
            engineerAssets       : [text: 'E', color: '#166534'],
            fireFightingAssets   : [text: 'F', color: '#dc2626'],
            airportLookupOption  : [text: 'AL', color: '#7c3aed'],
            incidentLookupOption : [text: 'IL', color: '#c2410c'],
            appAdmin             : [text: 'AA', color: '#334155'],
            geoAi                : [text: 'GA', color: '#0891b2'],
            geoHealth            : [text: 'GH', color: '#4d7c0f'],
            login                : [text: 'L', color: '#475569']
        ]
        Map activeFavicon = faviconConfig[faviconController] ?: [text: 'EM', color: '#24313f']
        String faviconText = activeFavicon.text?.toString() ?: 'EM'
        String faviconColor = activeFavicon.color?.toString() ?: '#24313f'
        int faviconFontSize = faviconText.size() > 1 ? 23 : 32
        String faviconSvg = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64"><rect width="64" height="64" rx="14" fill="${faviconColor}"/><path d="M0 45 L64 24 V64 H0Z" fill="#ffffff" opacity="0.14"/><text x="32" y="40" text-anchor="middle" font-family="Arial,Helvetica,sans-serif" font-size="${faviconFontSize}" font-weight="800" fill="#ffffff">${faviconText}</text></svg>"""
        String faviconHref = 'data:image/svg+xml,' + java.net.URLEncoder.encode(faviconSvg, 'UTF-8').replace('+', '%20')
    %>
    <link rel="icon" href="${raw(faviconHref)}" type="image/svg+xml" sizes="any"/>
    <asset:link rel="alternate icon" href="favicon.ico" type="image/x-ico"/>

    <asset:stylesheet src="application.css"/>

    <g:layoutHead/>
</head>

<body>

<nav class="navbar navbar-expand-lg navbar-dark navbar-static-top" role="navigation">
    <div class="container-fluid">
        <g:link class="navbar-brand geospatial-status-board-brand" uri="/"><gsb:bannerText slot="brandSubtitle" defaultText="Emergency Management"/></g:link>
        <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarContent" aria-controls="navbarContent" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="navbarContent">
            <ul class="nav navbar-nav ml-auto">
                <sec:ifLoggedIn>
                    <li class="nav-item gsb-service-health-nav-item">
                        <div id="gsb-service-health"
                             class="gsb-service-health"
                             data-health-url="${createLink(controller: 'geoHealth', action: 'index')}"
                             aria-label="Service health"
                             role="status">
                            <div class="gsb-service-health-item is-checking"
                                 data-service-health="geoserver"
                                 data-service-label="GeoServer"
                                 title="Checking GeoServer">
                                <span class="gsb-service-health-dot" aria-hidden="true"></span>
                                <span>GeoServer</span>
                            </div>
                            <div class="gsb-service-health-item is-checking"
                                 data-service-health="postgis"
                                 data-service-label="PostGIS"
                                 title="Checking PostGIS">
                                <span class="gsb-service-health-dot" aria-hidden="true"></span>
                                <span>PostGIS</span>
                            </div>
                            <div class="gsb-service-health-item is-checking"
                                 data-service-health="geoai"
                                 data-service-label="GeoAI"
                                 title="Checking GeoAI API">
                                <span class="gsb-service-health-dot" aria-hidden="true"></span>
                                <span>GeoAI</span>
                            </div>
                            <div class="gsb-service-health-item is-checking"
                                 data-service-health="gateway"
                                 data-service-label="Data Gateway"
                                 title="Checking Data Gateway">
                                <span class="gsb-service-health-dot" aria-hidden="true"></span>
                                <span>Gateway</span>
                            </div>
                            <div class="gsb-service-health-item is-checking"
                                 data-service-health="openclaw"
                                 data-service-label="OpenClaw"
                                 title="Checking OpenClaw">
                                <span class="gsb-service-health-dot" aria-hidden="true"></span>
                                <span>OpenClaw</span>
                            </div>
                        </div>
                    </li>
                </sec:ifLoggedIn>
                <g:pageProperty name="page.nav"/>
                <sec:ifLoggedIn>
                    <li class="nav-item">
                        <span class="navbar-text geospatial-status-board-user">user: <sec:username/></span>
                    </li>
                    <li class="nav-item">
                        <g:form controller="logout" action="index" method="POST" class="geospatial-status-board-logout-form">
                            <button type="submit" class="btn btn-outline-light btn-sm geospatial-status-board-logout-button">Logout</button>
                        </g:form>
                    </li>
                    <sec:ifAnyGranted roles="ROLE_ADMIN">
                        <li class="nav-item">
                            <g:link controller="appAdmin"
                                    action="index"
                                    class="geospatial-status-board-admin-button"
                                    title="App Admin"
                                    aria-label="App Admin">
                                <svg aria-hidden="true" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                     stroke-linecap="round" stroke-linejoin="round">
                                    <path d="M12.22 2h-.44a2 2 0 0 0-2 2v.18a2 2 0 0 1-1 1.73l-.43.25a2 2 0 0 1-2 0l-.15-.08a2 2 0 0 0-2.73.73l-.22.38a2 2 0 0 0 .73 2.73l.15.1a2 2 0 0 1 1 1.72v.51a2 2 0 0 1-1 1.74l-.15.09a2 2 0 0 0-.73 2.73l.22.38a2 2 0 0 0 2.73.73l.15-.08a2 2 0 0 1 2 0l.43.25a2 2 0 0 1 1 1.73V20a2 2 0 0 0 2 2h.44a2 2 0 0 0 2-2v-.18a2 2 0 0 1 1-1.73l.43-.25a2 2 0 0 1 2 0l.15.08a2 2 0 0 0 2.73-.73l.22-.39a2 2 0 0 0-.73-2.73l-.15-.08a2 2 0 0 1-1-1.74v-.5a2 2 0 0 1 1-1.74l.15-.09a2 2 0 0 0 .73-2.73l-.22-.38a2 2 0 0 0-2.73-.73l-.15.08a2 2 0 0 1-2 0l-.43-.25a2 2 0 0 1-1-1.73V4a2 2 0 0 0-2-2z"/>
                                    <circle cx="12" cy="12" r="3"/>
                                </svg>
                            </g:link>
                        </li>
                    </sec:ifAnyGranted>
                </sec:ifLoggedIn>
                <sec:ifNotLoggedIn>
                    <li class="nav-item">
                        <g:link controller="login" action="auth" class="nav-link">Login</g:link>
                    </li>
                </sec:ifNotLoggedIn>
            </ul>
        </div>
    </div>
</nav>
<g:set var="hideQuickLinks" value="${pageProperty(name: 'page.hideQuickLinks')?.toString()?.trim() == 'true'}"/>
<g:if test="${!hideQuickLinks}">
    <gsb:quickLinks/>
</g:if>

<g:layoutBody/>

<footer class="geospatial-status-board-footer" role="contentinfo">
    <div class="container-fluid">
        <span>Emergency Management</span>
    </div>
</footer>

<div id="spinner" class="spinner" style="display:none;">
    <g:message code="spinner.alt" default="Loading&hellip;"/>
</div>

<asset:javascript src="application.js"/>
<script>
(function () {
    var panel = document.getElementById('gsb-service-health');
    if (!panel) {
        return;
    }

    var healthUrl = panel.getAttribute('data-health-url');
    var serviceKeys = ['geoserver', 'postgis', 'geoai', 'gateway', 'openclaw'];

    function setServiceHealth(key, status, message) {
        var item = panel.querySelector('[data-service-health="' + key + '"]');
        if (!item) {
            return;
        }

        var label = item.getAttribute('data-service-label') || key;
        item.classList.toggle('is-up', status === 'up');
        item.classList.toggle('is-down', status === 'down');
        item.classList.toggle('is-checking', status !== 'up' && status !== 'down');
        item.title = message || (status === 'up' ? 'Available' : 'Unavailable');
        item.setAttribute('aria-label', label + ': ' + item.title);
    }

    function setAll(status, message) {
        serviceKeys.forEach(function (key) {
            setServiceHealth(key, status, message);
        });
    }

    function refreshServiceHealth() {
        if (!healthUrl || !window.fetch) {
            setAll('down', 'Service health check unavailable');
            return;
        }

        fetch(healthUrl, { credentials: 'same-origin' })
            .then(function (response) {
                if (!response.ok) {
                    throw new Error('Health check returned HTTP ' + response.status);
                }
                return response.json();
            })
            .then(function (payload) {
                var services = payload.services || {};
                serviceKeys.forEach(function (key) {
                    var service = services[key] || {};
                    setServiceHealth(key, service.status || 'down', service.message || 'No status');
                });
            })
            .catch(function (error) {
                setAll('down', error.message || 'Health check failed');
            });
    }

    refreshServiceHealth();
    window.setInterval(refreshServiceHealth, 60000);
})();
</script>

</body>
</html>
