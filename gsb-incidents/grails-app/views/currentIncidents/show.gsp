<%@ page import="gsb.incidents.CurrentIncidentsController" %>
<!DOCTYPE html>
<html>
	<head>
		
		<head>
		<meta name="layout" content="main">
		<meta http-equiv="Refresh" content="300"/>
<g:set var="entityName" value="${message(code: 'currentIncidents.label', default: 'Current Incidents')}" />
<title><g:message code="default.show.label" args="[entityName]" /></title>
</head>
<body>
<a href="#show-currentIncidents" class="skip" tabindex="-1"><g:message code="default.link.skip.label" default="Skip to content&hellip;"/></a>
<div class="nav" role="navigation">
	<ul>
		<li><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
		<li><g:link class="list" action="index"><g:message code="default.list.label" args="[entityName]" /></g:link></li>
		<li><g:link class="list" action="board">Incident Board</g:link></li>
	</ul>
</div>
<div id="show-currentIncidents" class="content scaffold-show" role="main">
	<h1><g:message code="default.show.label" args="[entityName]" /></h1>
	<g:if test="${flash.message}">
		<div class="message" role="status">${flash.message}</div>
	</g:if>
	<ol class="property-list currentIncidents">

		<g:if test="${currentIncidents?.id}">
			<li class="fieldcontain">
				<span id="id-label" class="property-label"><g:message code="currentIncidents.id.label" default="Incident Id" /></span>

				<span class="property-value" aria-labelledby="id-label"><g:fieldValue bean="${currentIncidents}" field="id"/></span>

			</li>
		</g:if>

		<li class="fieldcontain">
			<span id="workflowStatus-label" class="property-label"><g:message code="currentIncidents.workflowStatus.label" default="Workflow Status" /></span>

			<span class="property-value" aria-labelledby="workflowStatus-label">${currentIncidents?.workflowStatus ?: 'New'}</span>

		</li>

		<g:if test="${currentIncidents?.eventType}">
			<li class="fieldcontain">
				<span id="eventType-label" class="property-label"><g:message code="currentIncidents.eventType.label" default="Event Type" /></span>

				<span class="property-value" aria-labelledby="eventType-label"><g:fieldValue bean="${currentIncidents}" field="eventType"/></span>

			</li>
		</g:if>

		<g:if test="${currentIncidents?.eventCat}">
			<li class="fieldcontain">
				<span id="eventCat-label" class="property-label"><g:message code="currentIncidents.eventCat.label" default="Category" /></span>

				<span class="property-value" aria-labelledby="eventCat-label"><g:fieldValue bean="${currentIncidents}" field="eventCat"/></span>

			</li>
		</g:if>

		<g:if test="${currentIncidents?.eventDate}">
			<li class="fieldcontain">
				<span id="eventDate-label" class="property-label"><g:message code="currentIncidents.eventDate.label" default="Event Date" /></span>

				<span class="property-value" aria-labelledby="eventDate-label"><g:formatDate timeZone="America/Denver"  date="${currentIncidents?.eventDate}" /></span>

			</li>
		</g:if>

		<g:if test="${currentIncidents?.eventName}">
			<li class="fieldcontain">
				<span id="eventName-label" class="property-label"><g:message code="currentIncidents.eventName.label" default="Event Name" /></span>

				<span class="property-value" aria-labelledby="eventName-label"><g:fieldValue bean="${currentIncidents}" field="eventName"/></span>

			</li>
		</g:if>

		<g:if test="${currentIncidents?.eventDesc}">
			<li class="fieldcontain">
				<span id="eventDesc-label" class="property-label"><g:message code="currentIncidents.eventDesc.label" default="Event Desc" /></span>

				<span class="property-value" aria-labelledby="eventDesc-label"><g:fieldValue bean="${currentIncidents}" field="eventDesc"/></span>

			</li>
		</g:if>


		<g:if test="${currentIncidents?.mgrsCoord}">
			<li class="fieldcontain">
				<span id="mgrsCoord-label" class="property-label"><g:message code="currentIncidents.mgrsCoord.label" default="MGRS" /></span>

				<span class="property-value" aria-labelledby="mgrsCoord-label"><g:fieldValue bean="${currentIncidents}" field="mgrsCoord"/></span>

			</li>
		</g:if>

		<g:if test="${currentIncidents?.base}">
			<li class="fieldcontain">
				<span id="base-label" class="property-label"><g:message code="currentIncidents.base.label" default="Location" /></span>

				<span class="property-value" aria-labelledby="base-label"><g:fieldValue bean="${currentIncidents}" field="base"/></span>

			</li>
		</g:if>

		<g:if test="${currentIncidents?.sigEvent}">
			<li class="fieldcontain">
				<span id="sigEvent-label" class="property-label"><g:message code="currentIncidents.sigEvent.label" default="Sig Event" /></span>

				<span class="property-value" aria-labelledby="sigEvent-label"><g:fieldValue bean="${currentIncidents}" field="sigEvent"/></span>

			</li>
		</g:if>

		<g:if test="${currentIncidents?.airOpsAffected}">
			<li class="fieldcontain">
				<span id="airOpsAffected-label" class="property-label"><g:message code="currentIncidents.airOpsAffected.label" default="Air Ops Affected" /></span>

				<span class="property-value" aria-labelledby="airOpsAffected-label"><g:fieldValue bean="${currentIncidents}" field="airOpsAffected"/></span>

			</li>
		</g:if>

		<g:if test="${currentIncidents?.source}">
			<li class="fieldcontain">
				<span id="source-label" class="property-label"><g:message code="currentIncidents.source.label" default="Source" /></span>

				<span class="property-value" aria-labelledby="source-label"><g:fieldValue bean="${currentIncidents}" field="source"/></span>

			</li>
		</g:if>

		<g:if test="${currentIncidents?.createdBy}">
			<li class="fieldcontain">
				<span id="entered-label" class="property-label"><g:message code="currentIncidents.entered.label" default="Created By" /></span>

				<span class="property-value" aria-labelledby="entered-label"><g:fieldValue bean="${currentIncidents}" field="createdBy"/></span>

			</li>
		</g:if>

		<g:if test="${currentIncidents?.createdDate}">
			<li class="fieldcontain">
				<span id="createdDate-label" class="property-label"><g:message code="currentIncidents.createdDate.label" default="Created" /></span>

				<span class="property-value" aria-labelledby="createdDate-label"><g:fieldValue bean="${currentIncidents}" field="createdDate"/></span>

			</li>
		</g:if>

		<g:if test="${currentIncidents?.updatedBy}">
			<li class="fieldcontain">
				<span id="updatedBy-label" class="property-label"><g:message code="currentIncidents.updatedBy.label"
																			 default="Updated By"/></span>

				<span class="property-value" aria-labelledby="updatedBy-label"><g:fieldValue
						bean="${currentIncidents}" field="updatedBy"/></span>
			</li>
		</g:if>

		<g:if test="${currentIncidents?.updatedDate}">
			<li class="fieldcontain">
				<span id="updatedDate-label" class="property-label"><g:message code="currentIncidents.updatedDate.label" default="Updated" /></span>

				<span class="property-value" aria-labelledby="updatedDate-label"><g:fieldValue bean="${currentIncidents}" field="updatedDate"/></span>

			</li>
		</g:if>

		<g:if test="${currentIncidents?.entered}">
			<li class="fieldcontain">
				<span id="eventSourceHan-label" class="property-label"><g:message code="currentIncidents.eventSourceHan.label" default="App" /></span>

				<span class="property-value" aria-labelledby="eventSourceHan-label"><g:fieldValue bean="${currentIncidents}" field="eventSourceHan"/></span>

			</li>
		</g:if>

	</ol>
	<g:form url="[resource:currentIncidents, action:'delete']" method="DELETE">
		<fieldset class="buttons current-incident-show-buttons">
			<g:link class="edit" action="edit" resource="${currentIncidents}"><g:message code="default.button.edit.label" default="Edit" /></g:link>
			<input class="delete" type="submit" value="${message(code: 'default.button.delete.label', default: 'Delete')}" onclick="return confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');" />
		</fieldset>
	</g:form>
</div>

</body>

</html>
