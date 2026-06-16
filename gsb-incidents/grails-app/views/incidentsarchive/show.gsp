
<%@ page import="gsb.incidents.IncidentsarchiveController" %>
<!DOCTYPE html>
<html>
	<head>
		<meta name="layout" content="main">
		<meta http-equiv="Refresh" content="300"/>
		<g:set var="entityName" value="${message(code: 'incidentsarchive.label', default: 'incidentsarchive')}" />
		<title><g:message code="default.show.label" args="[entityName]" /></title>
	</head>
	<body>
		<a href="#show-incidentsarchive" class="skip" tabindex="-1"><g:message code="default.link.skip.label" default="Skip to content&hellip;"/></a>
		<div class="nav" role="navigation">
			<ul>
				<li><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
				<li><g:link class="list" action="index"><g:message code="default.list.label" args="[entityName]" /></g:link></li>
			</ul>
		</div>
		<div id="show-incidentsarchive" class="content scaffold-show" role="main">
			<h1><g:message code="default.show.label" args="[entityName]" /></h1>
			<g:if test="${flash.message}">
			<div class="message" role="status">${flash.message}</div>
			</g:if>
			<ol class="property-list incidentsarchive">
			
				<g:if test="${incidents?.incidentId}">
				<li class="fieldcontain">
					<span id="incidentId-label" class="property-label"><g:message code="incidentsarchive.incidentId.label" default="Incident Id" /></span>
					
						<span class="property-value" aria-labelledby="incidentId-label"><g:fieldValue bean="${incidents}" field="incidentId"/></span>
					
				</li>
				</g:if>

				<g:if test="${incidents?.archiveAction}">
				<li class="fieldcontain">
					<span id="archiveAction-label" class="property-label"><g:message code="incidentsarchive.archiveAction.label" default="Archive Action" /></span>

						<span class="property-value" aria-labelledby="archiveAction-label"><g:fieldValue bean="${incidents}" field="archiveAction"/></span>

				</li>
				</g:if>

				<li class="fieldcontain">
					<span id="workflowStatus-label" class="property-label"><g:message code="incidentsarchive.workflowStatus.label" default="Workflow Status" /></span>

						<span class="property-value" aria-labelledby="workflowStatus-label">${incidents?.workflowStatus ?: 'New'}</span>

				</li>
			
				<g:if test="${incidents?.eventType}">
				<li class="fieldcontain">
					<span id="eventType-label" class="property-label"><g:message code="incidentsarchive.eventType.label" default="Event Type" /></span>
					
						<span class="property-value" aria-labelledby="eventType-label"><g:fieldValue bean="${incidents}" field="eventType"/></span>
					
				</li>
				</g:if>

				<g:if test="${incidents?.eventCat}">
					<li class="fieldcontain">
						<span id="eventCat-label" class="property-label"><g:message code="incidentsarchive.eventCat.label" default="Category" /></span>

						<span class="property-value" aria-labelledby="eventCat-label"><g:fieldValue bean="${incidents}" field="eventCat"/></span>

					</li>
				</g:if>
			
				<g:if test="${incidents?.eventDate}">
				<li class="fieldcontain">
					<span id="eventDate-label" class="property-label"><g:message code="incidentsarchive.eventDate.label" default="Event Date" /></span>
					
						<span class="property-value" aria-labelledby="eventDate-label"><g:formatDate timeZone="America/Denver"  date="${incidents?.eventDate}" /></span>
					
				</li>
				</g:if>
			
				<g:if test="${incidents?.eventName}">
				<li class="fieldcontain">
					<span id="eventName-label" class="property-label"><g:message code="incidentsarchive.eventName.label" default="Event Name" /></span>
					
						<span class="property-value" aria-labelledby="eventName-label"><g:fieldValue bean="${incidents}" field="eventName"/></span>
					
				</li>
				</g:if>
			
				<g:if test="${incidents?.eventDesc}">
				<li class="fieldcontain">
					<span id="eventDesc-label" class="property-label"><g:message code="incidentsarchive.eventDesc.label" default="Event Desc" /></span>
					
						<span class="property-value" aria-labelledby="eventDesc-label"><g:fieldValue bean="${incidents}" field="eventDesc"/></span>
					
				</li>
				</g:if>
			
			
				<g:if test="${incidents?.mgrsCoord}">
				<li class="fieldcontain">
					<span id="mgrsCoord-label" class="property-label"><g:message code="incidentsarchive.mgrsCoord.label" default="Mgrs Coordinates" /></span>
					
						<span class="property-value" aria-labelledby="mgrsCoord-label"><g:fieldValue bean="${incidents}" field="mgrsCoord"/></span>
					
				</li>
				</g:if>
			
				<g:if test="${incidents?.base}">
				<li class="fieldcontain">
					<span id="base-label" class="property-label"><g:message code="incidentsarchive.base.label" default="Location" /></span>
					
						<span class="property-value" aria-labelledby="base-label"><g:fieldValue bean="${incidents}" field="base"/></span>
					
				</li>
				</g:if>
			
				<g:if test="${incidents?.sigEvent}">
				<li class="fieldcontain">
					<span id="sigEvent-label" class="property-label"><g:message code="incidentsarchive.sigEvent.label" default="Sig Event" /></span>
					
						<span class="property-value" aria-labelledby="sigEvent-label"><g:fieldValue bean="${incidents}" field="sigEvent"/></span>
					
				</li>
				</g:if>
			
				<g:if test="${incidents?.airOpsAffected}">
				<li class="fieldcontain">
					<span id="airOpsAffected-label" class="property-label"><g:message code="incidentsarchive.airOpsAffected.label" default="Air Ops Affected" /></span>
					
						<span class="property-value" aria-labelledby="airOpsAffected-label"><g:fieldValue bean="${incidents}" field="airOpsAffected"/></span>
					
				</li>
				</g:if>
			
				<g:if test="${incidents?.source}">
				<li class="fieldcontain">
					<span id="source-label" class="property-label"><g:message code="incidentsarchive.source.label" default="Source" /></span>
					
						<span class="property-value" aria-labelledby="source-label"><g:fieldValue bean="${incidents}" field="source"/></span>
					
				</li>
				</g:if>
			
				<g:if test="${incidents?.createdBy}">
				<li class="fieldcontain">
					<span id="entered-label" class="property-label"><g:message code="incidentsarchive.entered.label" default="Created By" /></span>
					
						<span class="property-value" aria-labelledby="entered-label"><g:fieldValue bean="${incidents}" field="createdBy"/></span>
					
				</li>
				</g:if>

				<g:if test="${incidents?.createdDate}">
					<li class="fieldcontain">
						<span id="createdDate-label" class="property-label"><g:message code="incidentsarchive.createdDate.label" default="Created" /></span>

						<span class="property-value" aria-labelledby="createdDate-label"><g:fieldValue bean="${incidents}" field="createdDate"/></span>

					</li>
				</g:if>

				<g:if test="${incidents?.updatedBy}">
					<li class="fieldcontain">
						<span id="updatedBy-label" class="property-label"><g:message code="incidents.updatedBy.label"
																					 default="Updated By"/></span>

						<span class="property-value" aria-labelledby="updatedBy-label"><g:fieldValue
								bean="${incidents}" field="updatedBy"/></span>
					</li>
				</g:if>
			
				<g:if test="${incidents?.updatedDate}">
				<li class="fieldcontain">
					<span id="updatedDate-label" class="property-label"><g:message code="incidentsarchive.updatedDate.label" default="Updated" /></span>
					
						<span class="property-value" aria-labelledby="updatedDate-label"><g:fieldValue bean="${incidents}" field="updatedDate"/></span>
					
				</li>
				</g:if>

				<g:if test="${incidents?.archivedAt}">
				<li class="fieldcontain">
					<span id="archivedAt-label" class="property-label"><g:message code="incidentsarchive.archivedAt.label" default="Archived At" /></span>

						<span class="property-value" aria-labelledby="archivedAt-label"><g:fieldValue bean="${incidents}" field="archivedAt"/></span>

				</li>
				</g:if>

				<g:if test="${incidents?.archivedBy}">
				<li class="fieldcontain">
					<span id="archivedBy-label" class="property-label"><g:message code="incidentsarchive.archivedBy.label" default="Archived By" /></span>

						<span class="property-value" aria-labelledby="archivedBy-label"><g:fieldValue bean="${incidents}" field="archivedBy"/></span>

				</li>
				</g:if>

				<g:if test="${incidents?.sourceCurrentId}">
				<li class="fieldcontain">
					<span id="sourceCurrentId-label" class="property-label"><g:message code="incidentsarchive.sourceCurrentId.label" default="Current Incident ID" /></span>

						<span class="property-value" aria-labelledby="sourceCurrentId-label"><g:fieldValue bean="${incidents}" field="sourceCurrentId"/></span>

				</li>
				</g:if>

				<g:if test="${incidents?.entered}">
					<li class="fieldcontain">
						<span id="eventSourceHan-label" class="property-label"><g:message code="incidentsarchive.eventSourceHan.label" default="App" /></span>

						<span class="property-value" aria-labelledby="eventSourceHan-label"><g:fieldValue bean="${incidents}" field="eventSourceHan"/></span>

					</li>
				</g:if>
			
			</ol>
		</div>
	</body>
</html>
