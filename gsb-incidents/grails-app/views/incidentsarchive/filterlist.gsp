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
	<h1>Incident List</h1>
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

			<th>Air Ops Affected</th>

			<th>Source</th>

			<th>Created By</th>

			<th>Created</th>

			<th>Updated By</th>

			<th>Updated</th>

		</tr>
		</thead>
		<tbody>
		<g:each in="${incidentsList}" status="i" var="incidents">
			<tr class="${(i % 2) == 0 ? 'even' : 'odd'}">

				<td><g:link action="show" id="${incidents.id}">${fieldValue(bean: incidents, field: "incidentId")}</g:link></td>

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

			</tr>
		</g:each>
		</tbody>
	</table>

	<div class="pagination">
		<g:paginate total="${incidentsCount ?: 0}"/>
	</div>

	<form name="filterselect">
		<span>Filter Incident List</span>
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
</div>

</body>
</html>
