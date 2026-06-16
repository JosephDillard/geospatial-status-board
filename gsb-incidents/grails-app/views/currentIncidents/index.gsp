<%@ page import="gsb.incidents.CurrentIncidentsController" %>
<!DOCTYPE html>
<html>
	<head>
		<meta name="layout" content="main">
		<meta http-equiv="Refresh" content="300"/>
		<g:set var="entityName" value="${message(code: 'currentIncidents.label', default: 'Current Incidents')}" />
		<title><g:message code="default.list.label" args="[entityName]" /></title>

		<asset:javascript src="fp.js"/>
		<asset:stylesheet src="fp.css"/>

		<g:javascript library="jquery" plugin="jquery"></g:javascript>
	</head>

	<body>
		<a href="#list-currentIncidents" class="skip" tabindex="-1"><g:message code="default.link.skip.label" default="Skip to content&hellip;"/></a>
	
		<div class="nav" role="navigation">
			<ul>
				<li><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
				<li><g:link class="list" action="board">Incident Board</g:link></li>
			</ul>
		</div>
	
		<div id="list-currentIncidents" class="content scaffold-list" role="main">

			%{--<div class="pagination">--}%
				%{--<filterpane:paginate total="${currentIncidentsCount}" domainBean="gsb.incidents.CurrentIncidents"/>--}%
				%{--<h2><filterpane:filterButton text="Filter List"/></h2>--}%
				%{--<filterpane:isFiltered>Filter Applied</filterpane:isFiltered>--}%
			%{--</div>--}%

			<h1>Current Incident List</h1>
			
			
			<g:if test="${flash.message}">
				<div class="message" role="status">${flash.message}</div>
			</g:if>
			
			<table>
				<thead>
					<tr>
						<g:sortableColumn property="id" title="${message(code: 'currentIncident.id.label', default: 'Incident ID')}"/>

						<g:sortableColumn property="workflowStatus" title="${message(code: 'currentIncident.workflowStatus.label', default: 'Status')}"/>

						<g:sortableColumn property="eventType" title="${message(code: 'currentIncident.eventType.label', default: 'Type')}"/>

						<g:sortableColumn property="eventCat" title="${message(code: 'currentIncident.eventCat.label', default: 'Category')}"/>

						<g:sortableColumn property="eventDate" title="${message(code: 'currentIncident.eventDate.label', default: 'Event Date')}"/>

						<g:sortableColumn property="eventName" title="${message(code: 'currentIncident.eventName.label', default: 'Title')}"/>

						%{--<g:sortableColumn property="id" title="${message(code: 'currentIncident.eventDesc.label', default: 'Description')}"/>--}%

						<th id="desc_header" class="sortable"><a href="">Description</a></th>

						%{--<g:sortableColumn property="eventDesc" title="${message(code: 'currentIncident.eventDesc.label', default: 'Description')}"/>--}%



						<g:sortableColumn property="mgrsCoord" title="${message(code: 'currentIncident.mgrsCoord.label', default: 'MGRS')}"/>

						<g:sortableColumn property="base" title="${message(code: 'currentIncident.base.label', default: 'Location')}"/>

						<g:sortableColumn property="sigEvent" title="${message(code: 'currentIncident.sigEvent.label', default: 'Sig Event')}"/>

						<g:sortableColumn property="airOpsAffected" title="${message(code: 'currentIncident.airOpsAffected.label', default: 'Air Ops Affected')}"/>

						<g:sortableColumn property="source" title="${message(code: 'currentIncident.source.label', default: 'Source')}"/>

						<g:sortableColumn property="createdBy" title="${message(code: 'currentIncident.createdBy.label', default: 'Created By')}"/>

						<g:sortableColumn defaultOrder="desc" property="createdDate" title="${message(code: 'currentIncident.createdDate.label', default: 'Created')}"/>

						<g:sortableColumn property="updatedDate" title="${message(code: 'currentIncident.updatedDate.label', default: 'Updated')}"/>

						<g:sortableColumn property="updatedBy" title="${message(code: 'currentIncident.updatedBy.label', default: 'Updated By')}"/>

						%{--<th></th>--}%

						<g:sortableColumn property="updatedDate" title="Previous Edits (click if shown)"></g:sortableColumn>

					</tr>
				</thead>
				<tbody>
				<g:each in="${currentIncidentsList}" status="i" var="currentIncidents">
					<tr class="${(i % 2) == 0 ? 'even' : 'odd'}">
						<td><g:link action="show" id="${currentIncidents.id}">${currentIncidents.id}</g:link></td>

						<td>${fieldValue(bean: currentIncidents, field: "workflowStatus") ?: 'New'}</td>

						<td>${fieldValue(bean: currentIncidents, field: "eventType")}</td>

						<td>${fieldValue(bean: currentIncidents, field: "eventCat")}</td>

						<td><g:formatDate timeZone="America/Denver"  date="${currentIncidents.eventDate}"/></td>

						<td>${fieldValue(bean: currentIncidents, field: "eventName")}</td>

						<td>${fieldValue(bean: currentIncidents, field: "eventDesc")}</td>


						<td><g:link controller="map" action="index" params="[layer: 'currentIncidents', field: 'mgrs_coord', value: currentIncidents.mgrsCoord]">
							${fieldValue(bean: currentIncidents, field: "mgrsCoord")}</g:link> </td>

						<td>${fieldValue(bean: currentIncidents, field: "base")}</td>

						<td>${fieldValue(bean: currentIncidents, field: "sigEvent")}</td>

						<td>${fieldValue(bean: currentIncidents, field: "airOpsAffected")}</td>

						<td>${fieldValue(bean: currentIncidents, field: "source")}</td>

						<td>${fieldValue(bean: currentIncidents, field: "createdBy")}</td>

						<td><g:formatDate timeZone="America/Denver"  date="${currentIncidents.createdDate}"/></td>

						<td><g:formatDate timeZone="America/Denver"  date="${currentIncidents.updatedDate}"/></td>

						<td>${fieldValue(bean: currentIncidents, field: "updatedBy")}</td>

						%{--<td>--}%
							%{--<button type="button" onclick="hideIncidentClick()">Hide Incident</button>--}%
						%{--</td>--}%

						<g:if test="${currentIncidents.updatedDate && currentIncidents.updatedBy}">
							<td><g:link action="showArchive" id="${currentIncidents.id}">
								<button title="Shows archived edits for this incident">Previous Edits</button>
							</g:link></td>
						</g:if>
						<g:else>
							<td></td>
						</g:else>

					</tr>
				</g:each>
				</tbody>
			</table>

			%{--<div class="pagination">--}%
				%{--<filterpane:paginate total="${currentIncidentsCount}" domainBean="gsb.incidents.CurrentIncidents"/>--}%
				%{--<h2><filterpane:filterButton text="Filter List"/></h2>--}%
				%{--<filterpane:isFiltered>Filter Applied</filterpane:isFiltered>--}%
			%{--</div>--}%
			%{--<filterpane:filterPane domain="gsb.incidents.CurrentIncidents"--}%

								   %{--titleKey="fp.tag.filterPane.titleText"--}%
								   %{--dialog="true"--}%
								   %{--visible="n"--}%
								   %{--showSortPanel="y"--}%
								   %{--showTitle="y"--}%
								   %{--filterParams="n"--}%
								   %{--fullAssociationPathFieldNames="true"/>--}%

			%{--<form class="filterselect_gsp" name="filterselect">--}%
				%{--<span><h2>Filter Incident List</h2></span>--}%
				%{--<span></span>--}%
				%{--<span><select name="fieldn" size="1" onChange="fieldname()">--}%
					%{--<option value="filter?sort=eventDate&max=100&order=desc&filter.op.eventCat=Equal&filter.eventCat=">Sort by...</option>--}%
					%{--<option value="filter?sort=eventDate&max=100&order=desc&filter.op.eventCat=Equal&filter.eventCat=">Sort by Event Date and Time</option>--}%
					%{--<option value="filter?sort=createdDate&max=100&order=desc&filter.op.eventCat=Equal&filter.eventCat=">Sort by Created Date and Time</option>--}%
					%{--<option value="filter?sort=eventType&max=100&order=asc&filter.op.eventCat=Equal&filter.eventCat=">Sort by Incident Type</option>--}%
				%{--</select></span>--}%
				%{--<span></span>--}%
				%{--<span><select name="fieldf" size="1" onChange="fieldfilter()">--}%
					%{--<option value="Damage">Select Incident Category...</option>--}%
					%{--<option value="Damage">FACDAM</option>--}%
					%{--<option value="CBRN">CBRN</option>--}%
					%{--<option value="ExpHaz">ExpHaz</option>--}%
					%{--<option value="Protection">Protection</option>--}%
					%{--<option value="Incidents">Misc. Incidents</option>--}%
				%{--</select></span>--}%
				%{--<script type="text/javascript">--}%
                    %{--var url1;--}%
                    %{--var url2;--}%

                    %{--function fieldname() {--}%
                        %{--url1 = document.filterselect.fieldn.options[document.filterselect.fieldn.selectedIndex].value;--}%
                        %{--document.filterselect.urlchange.value = url1 + url2;--}%
                    %{--}--}%
                    %{--function fieldfilter() {--}%
                        %{--url2 = document.filterselect.fieldf.options[document.filterselect.fieldf.selectedIndex].value;--}%
                        %{--document.filterselect.urlchange.value = url1 + url2;--}%
                    %{--}--}%
                    %{--function go() {--}%
                        %{--location = url1 + url2;--}%
                    %{--}--}%

                    %{--$(document).ready(function() {--}%
                        %{--$("#desc_header, #hangul_desc_header").on('click', function(e) {--}%
                            %{--e.preventDefault();--}%
						%{--});--}%
					%{--});--}%

                    %{--function hideIncidentClick() {--}%
                        %{--var url = '${createLink(action: 'setHidden')}';--}%
                        %{--console.log("hey");--}%
                        %{--$.ajax({--}%
                            %{--method: 'POST',--}%
							%{--data: 417506,--}%
                            %{--url: url,--}%
							%{--success: function() {--}%
                                %{--console.log("succes")--}%
							%{--}--}%
						%{--});--}%
					%{--}--}%

				%{--</script>--}%
				%{--<span></span>--}%

				%{--<span><input type="button" name="test" value="Go!" onClick="go()"></span>--}%
			%{--</form>--}%
			%{--<a name="bottom"></a>--}%
		</div>
	</body>
</html>
