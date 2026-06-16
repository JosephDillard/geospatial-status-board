<%@ page import="gsb.incidents.IncidentWorkflowStatus" %>
<!DOCTYPE html>
<html>
<head>
	<meta name="layout" content="main">
	<meta http-equiv="Refresh" content="300"/>
	<g:set var="entityName" value="${message(code: 'currentIncidents.label', default: 'Current Incidents')}" />
	<title>Incident Board</title>
	<style>
		.incident-board-shell {
			padding: 1rem;
		}

		.incident-board-header {
			align-items: center;
			display: flex;
			flex-wrap: wrap;
			gap: 0.75rem;
			justify-content: space-between;
			margin-bottom: 1rem;
		}

		.incident-board {
			display: grid;
			gap: 0.75rem;
			grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
		}

		.incident-board-column {
			background: #eef3f4;
			border: 1px solid #c7d5dd;
			border-radius: 6px;
			min-height: 14rem;
			padding: 0.75rem;
		}

		.incident-board-column h2 {
			align-items: center;
			display: flex;
			font-size: 1rem;
			justify-content: space-between;
			margin: 0 0 0.75rem;
		}

		.incident-count {
			background: #183d66;
			border-radius: 999px;
			color: #fff;
			font-size: 0.8rem;
			padding: 0.1rem 0.5rem;
		}

		.incident-card {
			background: #fff;
			border: 1px solid #d7e0e5;
			border-radius: 6px;
			margin-bottom: 0.75rem;
			padding: 0.75rem;
		}

		.incident-card-title {
			font-weight: 700;
			margin-bottom: 0.35rem;
		}

		.incident-card-meta {
			color: #4b5f6c;
			font-size: 0.85rem;
			margin-bottom: 0.5rem;
		}

		.incident-card-actions {
			align-items: center;
			display: flex;
			gap: 0.4rem;
			margin-top: 0.65rem;
		}

		.incident-card-actions select {
			min-width: 0;
			width: 100%;
		}
	</style>
</head>
<body>
<a href="#current-incidents-board" class="skip" tabindex="-1"><g:message code="default.link.skip.label" default="Skip to content&hellip;"/></a>

<div class="nav" role="navigation">
	<ul>
		<li><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
		<li><g:link class="list" action="index"><g:message code="default.list.label" args="[entityName]" /></g:link></li>
		<li><g:link class="create" action="create"><g:message code="default.new.label" args="[entityName]" /></g:link></li>
	</ul>
</div>

<main id="current-incidents-board" class="incident-board-shell" role="main">
	<div class="incident-board-header">
		<div>
			<h1>Incident Board</h1>
			<p>${currentIncidentsCount ?: 0} current incident(s)</p>
		</div>
		<g:link class="list" action="index">Table View</g:link>
	</div>

	<g:if test="${flash.message}">
		<div class="message" role="status">${flash.message}</div>
	</g:if>

	<section class="incident-board" aria-label="Current incident workflow board">
		<g:each in="${workflowStatuses ?: IncidentWorkflowStatus.STATUSES}" var="status">
			<g:set var="incidentsForStatus" value="${workflowColumns?.get(status) ?: []}" />
			<div class="incident-board-column">
				<h2>
					<span>${status}</span>
					<span class="incident-count">${incidentsForStatus.size()}</span>
				</h2>

				<g:each in="${incidentsForStatus}" var="incident">
					<article class="incident-card">
						<div class="incident-card-title">
							<g:link action="show" id="${incident.id}">${incident.eventName ?: incident.incidentId ?: incident.id}</g:link>
						</div>
						<div class="incident-card-meta">${incident.eventType ?: 'Unspecified'} - ${incident.base ?: 'No location'}</div>
						<div>${incident.eventDesc ?: ''}</div>
						<div class="incident-card-meta">
							Updated <g:formatDate timeZone="America/Denver" date="${incident.updatedDate ?: incident.createdDate}" />
						</div>
						<g:form action="updateWorkflowStatus" id="${incident.id}" method="POST">
							<g:hiddenField name="returnTo" value="board"/>
							<div class="incident-card-actions">
								<g:select name="workflowStatus"
										  from="${workflowStatuses ?: IncidentWorkflowStatus.STATUSES}"
										  value="${incident.workflowStatus ?: IncidentWorkflowStatus.NEW}"/>
								<button type="submit">Move</button>
							</div>
						</g:form>
					</article>
				</g:each>
			</div>
		</g:each>
	</section>
</main>
</body>
</html>
