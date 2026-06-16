<%@ page import="gsb.incidents.IncidentsarchiveController" %>
<!DOCTYPE html>
<html>
<head>
	<meta name="layout" content="main">
	<meta http-equiv="Refresh" content="300"/>
	<g:set var="entityName" value="${message(code: 'incidentsarchive.label', default: 'incidentsarchive')}"/>
	<title><g:message code="default.list.label" args="[entityName]"/></title>
	<asset:javascript src="fp.js"/>
	<asset:stylesheet src="fp.css"/>
</head>

<body>
<a href="#list-incidentsarchive" class="skip" tabindex="-1"><g:message code="default.link.skip.label" default="Skip to content&hellip;"/></a>

<div class="nav" role="navigation">
	<ul>
		<li><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
	</ul>
</div>

<div id="list-incidentsarchive" class="content scaffold-list" role="main">
	<h1>Incident Archive List</h1>


	<g:if test="${flash.message}">
		<div class="message" role="status">${flash.message}</div>
	</g:if>

	<table>
		<thead>
		<tr>

			<g:sortableColumn property="incidentId" title="${message(code: 'incidentsarchive.incidentId.label', default: 'Incident ID')}"/>

			<g:sortableColumn property="archiveAction" title="${message(code: 'incidentsarchive.archiveAction.label', default: 'Archive Action')}"/>

			<g:sortableColumn property="workflowStatus" title="${message(code: 'incidentsarchive.workflowStatus.label', default: 'Status')}"/>

			<g:sortableColumn property="eventType" title="${message(code: 'incidentsarchive.eventType.label', default: 'Type')}"/>

			<g:sortableColumn property="eventCat" title="${message(code: 'incidentsarchive.eventCat.label', default: 'Category')}"/>

			<g:sortableColumn property="eventDate" title="${message(code: 'incidentsarchive.eventDate.label', default: 'Event Date')}"/>

			<g:sortableColumn property="eventName" title="${message(code: 'incidentsarchive.eventName.label', default: 'Title')}"/>

			<g:sortableColumn property="eventDesc" title="${message(code: 'incidentsarchive.eventDesc.label', default: 'Description')}"/>


			<g:sortableColumn property="mgrsCoord" title="${message(code: 'incidentsarchive.mgrsCoord.label', default: 'MGRS')}"/>

			<g:sortableColumn property="base" title="${message(code: 'incidentsarchive.base.label', default: 'Location')}"/>

			<g:sortableColumn property="sigEvent" title="${message(code: 'incidentsarchive.sigEvent.label', default: 'Sig Event')}"/>

			<g:sortableColumn property="airOpsAffected" title="${message(code: 'incidentsarchive.airOpsAffected.label', default: 'Air Ops Affected')}"/>

			<g:sortableColumn property="source" title="${message(code: 'incidentsarchive.source.label', default: 'Source')}"/>

			<g:sortableColumn property="createdBy" title="${message(code: 'incidentsarchive.createdBy.label', default: 'Created By')}"/>

			<g:sortableColumn defaultOrder="desc" property="createdDate" title="${message(code: 'incidentsarchive.createdDate.label', default: 'Created')}"/>

			<g:sortableColumn property="updatedBy" title="${message(code: 'incidentsarchive.updatedBy.label', default: 'Updated By')}"/>

			<g:sortableColumn property="updatedDate" title="${message(code: 'incidentsarchive.updatedDate.label', default: 'Updated')}"/>

			<g:sortableColumn property="archivedAt" title="${message(code: 'incidentsarchive.archivedAt.label', default: 'Archived At')}"/>

			<g:sortableColumn property="archivedBy" title="${message(code: 'incidentsarchive.archivedBy.label', default: 'Archived By')}"/>

		</tr>
		</thead>
		<tbody>
		<g:each in="${incidentsList}" status="i" var="incidents">
			<tr class="${(i % 2) == 0 ? 'even' : 'odd'}">

				<td><g:link action="show" id="${incidents.id}">${fieldValue(bean: incidents, field: "incidentId")}</g:link></td>

				<td>${fieldValue(bean: incidents, field: "archiveAction")}</td>

				<td>${fieldValue(bean: incidents, field: "workflowStatus") ?: 'New'}</td>

				<td>${fieldValue(bean: incidents, field: "eventType")}</td>

				<td>${fieldValue(bean: incidents, field: "eventCat")}</td>

				<td><g:formatDate timeZone="America/Denver"  date="${incidents.eventDate}"/></td>

				<td>${fieldValue(bean: incidents, field: "eventName")}</td>

				<td>${fieldValue(bean: incidents, field: "eventDesc")}</td>


				<td><g:link controller="map" action="index" params="[layer: 'incidentsArchive', field: 'mgrs_coord', value: incidents.mgrsCoord]">
					${fieldValue(bean: incidents, field: "mgrsCoord")}</g:link> </td>

				<td>${fieldValue(bean: incidents, field: "base")}</td>

				<td>${fieldValue(bean: incidents, field: "sigEvent")}</td>

				<td>${fieldValue(bean: incidents, field: "airOpsAffected")}</td>

				<td>${fieldValue(bean: incidents, field: "source")}</td>

				<td>${fieldValue(bean: incidents, field: "createdBy")}</td>

				<td><g:formatDate timeZone="America/Denver"  date="${incidents.createdDate}"/></td>

				<td>${fieldValue(bean: incidents, field: "updatedBy")}</td>

				<td><g:formatDate timeZone="America/Denver"  date="${incidents.updatedDate}"/></td>

				<td><g:formatDate timeZone="America/Denver"  date="${incidents.archivedAt}"/></td>

				<td>${fieldValue(bean: incidents, field: "archivedBy")}</td>

			</tr>
		</g:each>
		</tbody>
	</table>

	<div class="pagination">
		<g:paginate total="${incidentsCount ?: 0}"/>
	</div>

	<form name="filterselect">
		<span><h2>Filter Incident List</h2></span>
		<span></span>
		<span><select name="fieldn" size="1" onChange="fieldname()">
			<option value="filter?sort=eventDate&max=100&order=desc&filter.op.eventCat=Equal&filter.eventCat=">Sort by...</option>
			<option value="filter?sort=eventDate&max=100&order=desc&filter.op.eventCat=Equal&filter.eventCat=">Sort by Event Date and Time</option>
			<option value="filter?sort=createdDate&max=100&order=desc&filter.op.eventCat=Equal&filter.eventCat=">Sort by Created Date and Time</option>
			<option value="filter?sort=eventType&max=100&order=asc&filter.op.eventCat=Equal&filter.eventCat=">Sort by Incident Type</option>
		</select></span>
		<span></span>
		<span><select name="fieldf" size="1" onChange="fieldfilter()">
			<option value="Damage">Select Incident Category...</option>
			<option value="Damage">FACDAM</option>
			<option value="CBRN">CBRN</option>
			<option value="ExpHaz">ExpHaz</option>
			<option value="Protection">Protection</option>
			<option value="incidentsarchive">Misc. incidentsarchive</option>
		</select></span>
		<script type="text/javascript">
			var url1;
			var url2;

			function fieldname() {
				url1 = document.filterselect.fieldn.options[document.filterselect.fieldn.selectedIndex].value;
				document.filterselect.urlchange.value = url1 + url2;
			}
			function fieldfilter() {
				url2 = document.filterselect.fieldf.options[document.filterselect.fieldf.selectedIndex].value;
				document.filterselect.urlchange.value = url1 + url2;
			}
			function go() {
				location = url1 + url2;

			}

		</script>
		<span></span>

		<span><input type="button" name="test" value="Go!" onClick="go()"></span>
	</form>
	<a name="bottom"></a>
</div>
<div></div>
<div></div>
<div></div>
<h4>Incident Archive is an append-only history. A snapshot is added when a current incident is created, edited, moved on the board, or deleted.</h4>
</body>
</html>
