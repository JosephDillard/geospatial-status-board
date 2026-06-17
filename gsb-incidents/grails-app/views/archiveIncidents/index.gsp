<%@ page import="gsb.incidents.ArchiveIncidentsController" %>
<!DOCTYPE html>
<html>
<head>
	<meta name="layout" content="main">
	<meta http-equiv="Refresh" content="300"/>
	<g:set var="entityName" value="${message(code: 'archiveIncidents.label', default: 'Archive Incidents')}"/>
	<title><g:message code="default.list.label" args="[entityName]"/></title>
	<asset:javascript src="fp.js"/>
	<asset:stylesheet src="fp.css"/>
</head>

<body>
<a href="#list-archiveIncidents" class="skip" tabindex="-1"><g:message code="default.link.skip.label" default="Skip to content&hellip;"/></a>

<div class="nav" role="navigation">
	<ul>
		<li><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
	</ul>
</div>

<div id="list-archiveIncidents" class="content scaffold-list" role="main">
	<h1>Archive Incidents</h1>


	<g:if test="${flash.message}">
		<div class="message" role="status">${flash.message}</div>
	</g:if>

	<table>
		<thead>
		<tr>

			<g:sortableColumn property="incidentId" title="${message(code: 'archiveIncidents.incidentId.label', default: 'Incident ID')}"/>

			<g:sortableColumn property="archiveAction" title="${message(code: 'archiveIncidents.archiveAction.label', default: 'Archive Action')}"/>

			<g:sortableColumn property="workflowStatus" title="${message(code: 'archiveIncidents.workflowStatus.label', default: 'Status')}"/>

			<g:sortableColumn property="eventType" title="${message(code: 'archiveIncidents.eventType.label', default: 'Type')}"/>

			<g:sortableColumn property="eventCat" title="${message(code: 'archiveIncidents.eventCat.label', default: 'Category')}"/>

			<g:sortableColumn property="eventDate" title="${message(code: 'archiveIncidents.eventDate.label', default: 'Event Date')}"/>

			<g:sortableColumn property="eventName" title="${message(code: 'archiveIncidents.eventName.label', default: 'Title')}"/>

			<g:sortableColumn property="eventDesc" title="${message(code: 'archiveIncidents.eventDesc.label', default: 'Description')}"/>


			<g:sortableColumn property="mgrsCoord" title="${message(code: 'archiveIncidents.mgrsCoord.label', default: 'MGRS')}"/>

			<g:sortableColumn property="base" title="${message(code: 'archiveIncidents.base.label', default: 'Location')}"/>

			<g:sortableColumn property="sigEvent" title="${message(code: 'archiveIncidents.sigEvent.label', default: 'Sig Event')}"/>

			<g:sortableColumn property="airOpsAffected" title="${message(code: 'archiveIncidents.airOpsAffected.label', default: 'Affects Operations')}"/>

			<g:sortableColumn property="source" title="${message(code: 'archiveIncidents.source.label', default: 'Source')}"/>

			<g:sortableColumn property="createdBy" title="${message(code: 'archiveIncidents.createdBy.label', default: 'Created By')}"/>

			<g:sortableColumn defaultOrder="desc" property="createdDate" title="${message(code: 'archiveIncidents.createdDate.label', default: 'Created')}"/>

			<g:sortableColumn property="updatedBy" title="${message(code: 'archiveIncidents.updatedBy.label', default: 'Updated By')}"/>

			<g:sortableColumn property="updatedDate" title="${message(code: 'archiveIncidents.updatedDate.label', default: 'Updated')}"/>

			<g:sortableColumn property="archivedAt" title="${message(code: 'archiveIncidents.archivedAt.label', default: 'Archived At')}"/>

			<g:sortableColumn property="archivedBy" title="${message(code: 'archiveIncidents.archivedBy.label', default: 'Archived By')}"/>

		</tr>
		</thead>
		<tbody>
		<g:each in="${archiveIncidentsList}" status="i" var="archiveIncidents">
			<tr class="${(i % 2) == 0 ? 'even' : 'odd'}">

				<td><g:link action="show" id="${archiveIncidents.id}">${fieldValue(bean: archiveIncidents, field: "incidentId")}</g:link></td>

				<td>${fieldValue(bean: archiveIncidents, field: "archiveAction")}</td>

				<td>${fieldValue(bean: archiveIncidents, field: "workflowStatus") ?: 'New'}</td>

				<td>${fieldValue(bean: archiveIncidents, field: "eventType")}</td>

				<td>${fieldValue(bean: archiveIncidents, field: "eventCat")}</td>

				<td><g:formatDate timeZone="America/Denver"  date="${archiveIncidents.eventDate}"/></td>

				<td>${fieldValue(bean: archiveIncidents, field: "eventName")}</td>

				<td>${fieldValue(bean: archiveIncidents, field: "eventDesc")}</td>


				<td><g:link controller="map" action="index" params="[layer: 'archiveIncidents', field: 'mgrs_coord', value: archiveIncidents.mgrsCoord]">
					${fieldValue(bean: archiveIncidents, field: "mgrsCoord")}</g:link> </td>

				<td>${fieldValue(bean: archiveIncidents, field: "base")}</td>

				<td>${fieldValue(bean: archiveIncidents, field: "sigEvent")}</td>

				<td>${fieldValue(bean: archiveIncidents, field: "airOpsAffected")}</td>

				<td>${fieldValue(bean: archiveIncidents, field: "source")}</td>

				<td>${fieldValue(bean: archiveIncidents, field: "createdBy")}</td>

				<td><g:formatDate timeZone="America/Denver"  date="${archiveIncidents.createdDate}"/></td>

				<td>${fieldValue(bean: archiveIncidents, field: "updatedBy")}</td>

				<td><g:formatDate timeZone="America/Denver"  date="${archiveIncidents.updatedDate}"/></td>

				<td><g:formatDate timeZone="America/Denver"  date="${archiveIncidents.archivedAt}"/></td>

				<td>${fieldValue(bean: archiveIncidents, field: "archivedBy")}</td>

			</tr>
		</g:each>
		</tbody>
	</table>

	<div class="pagination">
		<g:paginate total="${archiveIncidentsCount ?: 0}"/>
	</div>

	<a name="bottom"></a>
</div>
<div></div>
<div></div>
<div></div>
<h4>Archive Incidents is an append-only history. A snapshot is added when a current incident is created, edited, moved on the board, or deleted.</h4>
</body>
</html>
