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

			<th>Incident ID</th>

			<th>Type</th>

			<th>Category</th>

			<th>Event Date</th>

			<th>Title</th>

			<th>Description</th>


			<th>MGRS</th>

			<th>Location</th>

			<th>Sig Event</th>

			<th>Affects Operations</th>

			<th>Source</th>

			<th>Created By</th>

			<th>Created</th>

			<th>Updated By</th>

			<th>Updated</th>

		</tr>
		</thead>
		<tbody>
		<g:each in="${archiveIncidentsList}" status="i" var="archiveIncidents">
			<tr class="${(i % 2) == 0 ? 'even' : 'odd'}">

				<td><g:link action="show" id="${archiveIncidents.id}">${fieldValue(bean: archiveIncidents, field: "incidentId")}</g:link></td>

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

			</tr>
		</g:each>
		</tbody>
	</table>

	<div class="pagination">
		<g:paginate total="${archiveIncidentsCount ?: 0}"/>
	</div>

</div>

</body>
</html>
