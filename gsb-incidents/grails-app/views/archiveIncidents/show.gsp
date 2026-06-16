
<%@ page import="gsb.incidents.ArchiveIncidentsController" %>
<!DOCTYPE html>
<html>
	<head>
		<meta name="layout" content="main">
		<meta http-equiv="Refresh" content="300"/>
		<g:set var="entityName" value="${message(code: 'archiveIncidents.label', default: 'Archive Incidents')}" />
		<title><g:message code="default.show.label" args="[entityName]" /></title>
	</head>
	<body>
		<a href="#show-archiveIncidents" class="skip" tabindex="-1"><g:message code="default.link.skip.label" default="Skip to content&hellip;"/></a>
		<div class="nav" role="navigation">
			<ul>
				<li><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
				<li><g:link class="list" action="index"><g:message code="default.list.label" args="[entityName]" /></g:link></li>
			</ul>
		</div>
		<div id="show-archiveIncidents" class="content scaffold-show" role="main">
			<h1><g:message code="default.show.label" args="[entityName]" /></h1>
			<g:if test="${flash.message}">
			<div class="message" role="status">${flash.message}</div>
			</g:if>
			<ol class="property-list archiveIncidents">
			
				<g:if test="${archiveIncidents?.incidentId}">
				<li class="fieldcontain">
					<span id="incidentId-label" class="property-label"><g:message code="archiveIncidents.incidentId.label" default="Incident Id" /></span>
					
						<span class="property-value" aria-labelledby="incidentId-label"><g:fieldValue bean="${archiveIncidents}" field="incidentId"/></span>
					
				</li>
				</g:if>

				<g:if test="${archiveIncidents?.archiveAction}">
				<li class="fieldcontain">
					<span id="archiveAction-label" class="property-label"><g:message code="archiveIncidents.archiveAction.label" default="Archive Action" /></span>

						<span class="property-value" aria-labelledby="archiveAction-label"><g:fieldValue bean="${archiveIncidents}" field="archiveAction"/></span>

				</li>
				</g:if>

				<li class="fieldcontain">
					<span id="workflowStatus-label" class="property-label"><g:message code="archiveIncidents.workflowStatus.label" default="Workflow Status" /></span>

						<span class="property-value" aria-labelledby="workflowStatus-label">${archiveIncidents?.workflowStatus ?: 'New'}</span>

				</li>
			
				<g:if test="${archiveIncidents?.eventType}">
				<li class="fieldcontain">
					<span id="eventType-label" class="property-label"><g:message code="archiveIncidents.eventType.label" default="Event Type" /></span>
					
						<span class="property-value" aria-labelledby="eventType-label"><g:fieldValue bean="${archiveIncidents}" field="eventType"/></span>
					
				</li>
				</g:if>

				<g:if test="${archiveIncidents?.eventCat}">
					<li class="fieldcontain">
						<span id="eventCat-label" class="property-label"><g:message code="archiveIncidents.eventCat.label" default="Category" /></span>

						<span class="property-value" aria-labelledby="eventCat-label"><g:fieldValue bean="${archiveIncidents}" field="eventCat"/></span>

					</li>
				</g:if>
			
				<g:if test="${archiveIncidents?.eventDate}">
				<li class="fieldcontain">
					<span id="eventDate-label" class="property-label"><g:message code="archiveIncidents.eventDate.label" default="Event Date" /></span>
					
						<span class="property-value" aria-labelledby="eventDate-label"><g:formatDate timeZone="America/Denver"  date="${archiveIncidents?.eventDate}" /></span>
					
				</li>
				</g:if>
			
				<g:if test="${archiveIncidents?.eventName}">
				<li class="fieldcontain">
					<span id="eventName-label" class="property-label"><g:message code="archiveIncidents.eventName.label" default="Event Name" /></span>
					
						<span class="property-value" aria-labelledby="eventName-label"><g:fieldValue bean="${archiveIncidents}" field="eventName"/></span>
					
				</li>
				</g:if>
			
				<g:if test="${archiveIncidents?.eventDesc}">
				<li class="fieldcontain">
					<span id="eventDesc-label" class="property-label"><g:message code="archiveIncidents.eventDesc.label" default="Event Desc" /></span>
					
						<span class="property-value" aria-labelledby="eventDesc-label"><g:fieldValue bean="${archiveIncidents}" field="eventDesc"/></span>
					
				</li>
				</g:if>
			
			
				<g:if test="${archiveIncidents?.mgrsCoord}">
				<li class="fieldcontain">
					<span id="mgrsCoord-label" class="property-label"><g:message code="archiveIncidents.mgrsCoord.label" default="Mgrs Coordinates" /></span>
					
						<span class="property-value" aria-labelledby="mgrsCoord-label"><g:fieldValue bean="${archiveIncidents}" field="mgrsCoord"/></span>
					
				</li>
				</g:if>
			
				<g:if test="${archiveIncidents?.base}">
				<li class="fieldcontain">
					<span id="base-label" class="property-label"><g:message code="archiveIncidents.base.label" default="Location" /></span>
					
						<span class="property-value" aria-labelledby="base-label"><g:fieldValue bean="${archiveIncidents}" field="base"/></span>
					
				</li>
				</g:if>
			
				<g:if test="${archiveIncidents?.sigEvent}">
				<li class="fieldcontain">
					<span id="sigEvent-label" class="property-label"><g:message code="archiveIncidents.sigEvent.label" default="Sig Event" /></span>
					
						<span class="property-value" aria-labelledby="sigEvent-label"><g:fieldValue bean="${archiveIncidents}" field="sigEvent"/></span>
					
				</li>
				</g:if>
			
				<g:if test="${archiveIncidents?.airOpsAffected}">
				<li class="fieldcontain">
					<span id="airOpsAffected-label" class="property-label"><g:message code="archiveIncidents.airOpsAffected.label" default="Air Ops Affected" /></span>
					
						<span class="property-value" aria-labelledby="airOpsAffected-label"><g:fieldValue bean="${archiveIncidents}" field="airOpsAffected"/></span>
					
				</li>
				</g:if>
			
				<g:if test="${archiveIncidents?.source}">
				<li class="fieldcontain">
					<span id="source-label" class="property-label"><g:message code="archiveIncidents.source.label" default="Source" /></span>
					
						<span class="property-value" aria-labelledby="source-label"><g:fieldValue bean="${archiveIncidents}" field="source"/></span>
					
				</li>
				</g:if>
			
				<g:if test="${archiveIncidents?.createdBy}">
				<li class="fieldcontain">
					<span id="entered-label" class="property-label"><g:message code="archiveIncidents.entered.label" default="Created By" /></span>
					
						<span class="property-value" aria-labelledby="entered-label"><g:fieldValue bean="${archiveIncidents}" field="createdBy"/></span>
					
				</li>
				</g:if>

				<g:if test="${archiveIncidents?.createdDate}">
					<li class="fieldcontain">
						<span id="createdDate-label" class="property-label"><g:message code="archiveIncidents.createdDate.label" default="Created" /></span>

						<span class="property-value" aria-labelledby="createdDate-label"><g:fieldValue bean="${archiveIncidents}" field="createdDate"/></span>

					</li>
				</g:if>

				<g:if test="${archiveIncidents?.updatedBy}">
					<li class="fieldcontain">
						<span id="updatedBy-label" class="property-label"><g:message code="archiveIncidents.updatedBy.label"
																					 default="Updated By"/></span>

						<span class="property-value" aria-labelledby="updatedBy-label"><g:fieldValue
								bean="${archiveIncidents}" field="updatedBy"/></span>
					</li>
				</g:if>
			
				<g:if test="${archiveIncidents?.updatedDate}">
				<li class="fieldcontain">
					<span id="updatedDate-label" class="property-label"><g:message code="archiveIncidents.updatedDate.label" default="Updated" /></span>
					
						<span class="property-value" aria-labelledby="updatedDate-label"><g:fieldValue bean="${archiveIncidents}" field="updatedDate"/></span>
					
				</li>
				</g:if>

				<g:if test="${archiveIncidents?.archivedAt}">
				<li class="fieldcontain">
					<span id="archivedAt-label" class="property-label"><g:message code="archiveIncidents.archivedAt.label" default="Archived At" /></span>

						<span class="property-value" aria-labelledby="archivedAt-label"><g:fieldValue bean="${archiveIncidents}" field="archivedAt"/></span>

				</li>
				</g:if>

				<g:if test="${archiveIncidents?.archivedBy}">
				<li class="fieldcontain">
					<span id="archivedBy-label" class="property-label"><g:message code="archiveIncidents.archivedBy.label" default="Archived By" /></span>

						<span class="property-value" aria-labelledby="archivedBy-label"><g:fieldValue bean="${archiveIncidents}" field="archivedBy"/></span>

				</li>
				</g:if>

				<g:if test="${archiveIncidents?.sourceCurrentId}">
				<li class="fieldcontain">
					<span id="sourceCurrentId-label" class="property-label"><g:message code="archiveIncidents.sourceCurrentId.label" default="Current Incident ID" /></span>

						<span class="property-value" aria-labelledby="sourceCurrentId-label"><g:fieldValue bean="${archiveIncidents}" field="sourceCurrentId"/></span>

				</li>
				</g:if>

				<g:if test="${archiveIncidents?.entered}">
					<li class="fieldcontain">
						<span id="eventSourceHan-label" class="property-label"><g:message code="archiveIncidents.eventSourceHan.label" default="App" /></span>

						<span class="property-value" aria-labelledby="eventSourceHan-label"><g:fieldValue bean="${archiveIncidents}" field="eventSourceHan"/></span>

					</li>
				</g:if>
			
			</ol>
		</div>
	</body>
</html>
