<!doctype html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>Emergency Management Home</title>
</head>
<body>
<main class="geospatial-status-board-page" role="main">
    <section class="geospatial-status-board-hero">
        <div>
            <p class="geospatial-status-board-kicker">Signed in as ${username}</p>
            <h1>Emergency Management</h1>
            <p class="geospatial-status-board-subtitle">Mission data, airfield posture, and incident tracking in one authenticated workspace.</p>
        </div>
        <div class="geospatial-status-board-session">
            <span>Session active</span>
            <strong>${roles ? roles.join(', ') : 'ROLE_USER'}</strong>
        </div>
    </section>

    <section class="geospatial-status-board-section">
        <div class="geospatial-status-board-section-title">
            <h2>Apps</h2>
        </div>

        <div class="geospatial-status-board-link-grid">
            <g:each var="link" in="${appLinks}">
                <g:if test="${link.uri}">
                    <g:link class="geospatial-status-board-hub-link" uri="${link.uri}">
                        <span>${link.label}</span>
                        <small>${link.description}</small>
                    </g:link>
                </g:if>
                <g:else>
                    <g:link class="geospatial-status-board-hub-link" controller="${link.controller}" action="${link.action ?: 'index'}">
                        <span>${link.label}</span>
                        <small>${link.description}</small>
                    </g:link>
                </g:else>
            </g:each>
        </div>
    </section>

    <section class="geospatial-status-board-section">
        <div class="geospatial-status-board-section-title">
            <h2>APIs</h2>
        </div>

        <div class="geospatial-status-board-link-grid geospatial-status-board-link-grid-compact">
            <g:each var="link" in="${apiLinks}">
                <g:if test="${link.url}">
                    <a class="geospatial-status-board-hub-link geospatial-status-board-api-link"
                       href="${link.url}"
                       target="_blank"
                       rel="noopener">
                        <span>${link.label}</span>
                        <small>${link.description}</small>
                        <strong class="geospatial-status-board-api-method">${link.method ?: 'GET'}</strong>
                        <code>${link.url}</code>
                    </a>
                </g:if>
                <g:else>
                    <g:link class="geospatial-status-board-hub-link geospatial-status-board-api-link" uri="${link.uri}">
                        <span>${link.label}</span>
                        <small>${link.description}</small>
                        <strong class="geospatial-status-board-api-method">${link.method ?: 'GET'}</strong>
                        <code>${link.uri}</code>
                    </g:link>
                </g:else>
            </g:each>
        </div>
    </section>

    <section class="geospatial-status-board-section">
        <div class="geospatial-status-board-section-title">
            <h2>External Pages &amp; Consoles</h2>
        </div>

        <g:if test="${integrationLinks}">
            <div class="geospatial-status-board-link-grid geospatial-status-board-link-grid-compact">
                <g:each var="link" in="${integrationLinks}">
                    <a class="geospatial-status-board-hub-link geospatial-status-board-integration-link"
                       href="${link.url}"
                       target="_blank"
                       rel="noopener">
                        <span>${link.label}</span>
                        <small>${link.description}</small>
                        <code>${link.url}</code>
                    </a>
                </g:each>
            </div>
        </g:if>
        <g:else>
            <div class="geospatial-status-board-empty-state">
                <h3>No integrations configured</h3>
                <p>Configure GeoServer, GeoAI, Data Gateway, or Incident Analyst bridge URLs to show integration links here.</p>
            </div>
        </g:else>
    </section>

    <section class="geospatial-status-board-section geospatial-status-board-inventory-section">
        <div class="geospatial-status-board-section-title">
            <h2>Registered Controllers</h2>
        </div>

        <g:set var="excludedControllers" value="${['home', 'login', 'logout']}"/>
        <g:set var="workControllers" value="${grailsApplication.controllerClasses.findAll { !(it.logicalPropertyName in excludedControllers) }.sort { it.fullName }}"/>

        <g:if test="${workControllers}">
            <div class="geospatial-status-board-module-grid">
                <g:each var="controllerClass" in="${workControllers}">
                    <g:link class="geospatial-status-board-module" controller="${controllerClass.logicalPropertyName}">
                        <span>${controllerClass.name}</span>
                        <small>${controllerClass.fullName}</small>
                    </g:link>
                </g:each>
            </div>
        </g:if>
        <g:else>
            <div class="geospatial-status-board-empty-state">
                <h3>No operational modules registered</h3>
                <p>The authenticated shell is ready for Emergency Management modules as they are added to this application.</p>
            </div>
        </g:else>
    </section>
</main>
</body>
</html>
