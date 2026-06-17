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
            <h2>Available Work Areas</h2>
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
