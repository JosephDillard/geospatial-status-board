<%@ page import="gsb.incidents.CurrentIncidentsController" %>
<%@ page import="gsb.incidents.IncidentWorkflowStatus" %>

<div class="fieldcontain ${hasErrors(bean: currentIncidents, field: 'workflowStatus', 'error')} ">
	<label for="workflowStatus">
		<g:message code="currentIncidents.workflowStatus.label" default="Workflow Status" />
	</label>
	<g:select name="workflowStatus"
			  from="${workflowStatuses ?: IncidentWorkflowStatus.STATUSES}"
			  value="${currentIncidents?.workflowStatus ?: IncidentWorkflowStatus.NEW}"/>
</div>

<div class="fieldcontain ${hasErrors(bean: currentIncidents, field: 'incidentId', 'error')} ">
	<label for="incidentId">
		<g:message code="currentIncidents.incidentId.label" default="Incident ID" />
	</label>
	<g:textField name="incidentId" value="${currentIncidents?.incidentId}"/>
</div>

<div class="fieldcontain ${hasErrors(bean: currentIncidents, field: 'eventType', 'error')} ">
	<label for="eventType">
		<g:message code="currentIncidents.eventType.label" default="Type" />
	</label>
	<incidentLookup:select name="eventType" category="incident.eventType" value="${currentIncidents?.eventType}" valueMessagePrefix="currentIncidents.eventType" noSelection="['': '']"/>
</div>

<div class="fieldcontain ${hasErrors(bean: currentIncidents, field: 'eventCat', 'error')} ">
	<label for="eventCat">
		<g:message code="currentIncidents.eventCat.label" default="Category" />
	</label>
	<incidentLookup:select name="eventCat" category="incident.eventCategory" value="${currentIncidents?.eventCat}" valueMessagePrefix="currentIncidents.eventCat" noSelection="['': '']"/>
</div>

<div class="fieldcontain ${hasErrors(bean: currentIncidents, field: 'eventName', 'error')} ">
	<label for="eventName">
		<g:message code="currentIncidents.eventName.label" default="Title" />
	</label>
	<g:textField name="eventName" value="${currentIncidents?.eventName}"/>
</div>

<div class="fieldcontain ${hasErrors(bean: currentIncidents, field: 'eventDesc', 'error')} ">
	<label for="eventDesc">
		<g:message code="currentIncidents.eventDesc.label" default="Description" />
	</label>
	<g:textArea name="eventDesc" value="${currentIncidents?.eventDesc}" rows="4"/>
</div>

<div class="fieldcontain ${hasErrors(bean: currentIncidents, field: 'mgrsCoord', 'error')} ">
	<label for="mgrsCoord">
		<g:message code="currentIncidents.mgrsCoord.label" default="MGRS" />
	</label>
	<g:textField name="mgrsCoord" value="${currentIncidents?.mgrsCoord}"/>
</div>

<div class="fieldcontain ${hasErrors(bean: currentIncidents, field: 'base', 'error')} ">
	<label for="base">
		<g:message code="currentIncidents.base.label" default="Location" />
	</label>
	<incidentLookup:select name="base" category="incident.base" value="${currentIncidents?.base}" valueMessagePrefix="currentIncidents.base" noSelection="['': '']"/>
</div>

<div class="fieldcontain ${hasErrors(bean: currentIncidents, field: 'sigEvent', 'error')} ">
	<label for="sigEvent">
		<g:message code="currentIncidents.sigEvent.label" default="Significant" />
	</label>
	<incidentLookup:select name="sigEvent" category="incident.yesNoNa" value="${currentIncidents?.sigEvent}" valueMessagePrefix="currentIncidents.sigEvent" noSelection="['': '']"/>
</div>

<div class="fieldcontain ${hasErrors(bean: currentIncidents, field: 'airOpsAffected', 'error')} ">
	<label for="airOpsAffected">
		<g:message code="currentIncidents.airOpsAffected.label" default="Affects Operations" />
	</label>
	<incidentLookup:select name="airOpsAffected" category="incident.yesNoNa" value="${currentIncidents?.airOpsAffected}" valueMessagePrefix="currentIncidents.airOpsAffected" noSelection="['': '']"/>
</div>

<div class="fieldcontain ${hasErrors(bean: currentIncidents, field: 'source', 'error')} ">
	<label for="source">
		<g:message code="currentIncidents.source.label" default="Source" />
	</label>
	<incidentLookup:select name="source" category="incident.source" value="${currentIncidents?.source}" valueMessagePrefix="currentIncidents.source" noSelection="['': '']"/>
</div>
