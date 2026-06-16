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
    </ul>
</div>

<div id="archiveTitle"><h1>Archive Incidents</h1></div>
<table id="showArchiveTable">
    <thead>
    <tr>
        <g:sortableColumn property="objectid_1" title="${message(code: 'incident.objectid_1.label', default: 'Incident ID')}"/>

        <g:sortableColumn property="archiveAction" title="${message(code: 'incident.archiveAction.label', default: 'Archive Action')}"/>

        <g:sortableColumn property="workflowStatus" title="${message(code: 'incident.workflowStatus.label', default: 'Status')}"/>

        <g:sortableColumn property="eventType" title="${message(code: 'incident.eventType.label', default: 'Type')}"/>

        <g:sortableColumn property="eventCat" title="${message(code: 'incident.eventCat.label', default: 'Category')}"/>

        <g:sortableColumn property="eventDate" title="${message(code: 'incident.eventDate.label', default: 'Event Date')}"/>

        <g:sortableColumn property="eventName" title="${message(code: 'incident.eventName.label', default: 'Title')}"/>

        <g:sortableColumn property="eventDesc" title="${message(code: 'incident.eventDesc.label', default: 'Description')}"/>


        <g:sortableColumn property="mgrsCoord" title="${message(code: 'incident.mgrsCoord.label', default: 'MGRS')}"/>

        <g:sortableColumn property="base" title="${message(code: 'incident.base.label', default: 'Location')}"/>

        <g:sortableColumn property="sigEvent" title="${message(code: 'incident.sigEvent.label', default: 'Sig Event')}"/>

        <g:sortableColumn property="airOpsAffected" title="${message(code: 'incident.airOpsAffected.label', default: 'Air Ops Affected')}"/>

        <g:sortableColumn property="source" title="${message(code: 'incident.source.label', default: 'Source')}"/>

        <g:sortableColumn property="createdBy" title="${message(code: 'incident.createdBy.label', default: 'Created By')}"/>

        <g:sortableColumn defaultOrder="desc" property="createdDate" title="${message(code: 'incident.createdDate.label', default: 'Created')}"/>

        <g:sortableColumn property="updatedDate" title="${message(code: 'incident.updatedDate.label', default: 'Updated')}"/>

        <g:sortableColumn property="updatedBy" title="${message(code: 'incident.updatedBy.label', default: 'Updated By')}"/>

        <g:sortableColumn property="archivedAt" title="${message(code: 'incident.archivedAt.label', default: 'Archived At')}"/>

    </tr>
    </thead>

    <tbody>

    <g:each in="${archiveList}" status="i" var="archiveIncidents">
        <tr class="${(i % 2) == 0 ? 'even' : 'odd'}">
            <td><g:link controller="archiveIncidents" action="show" id="${archiveIncidents.id}">${fieldValue(bean: archiveIncidents, field: "objectid_1")}</g:link></td>

            <td>${fieldValue(bean: archiveIncidents, field: "archiveAction")}</td>

            <td>${fieldValue(bean: archiveIncidents, field: "workflowStatus") ?: 'New'}</td>

            <td>${fieldValue(bean: archiveIncidents, field: "eventType")}</td>

            <td>${fieldValue(bean: archiveIncidents, field: "eventCat")}</td>

            <td><g:formatDate timeZone="America/Denver"  date="${archiveIncidents.eventDate}"/></td>

            <td>${fieldValue(bean: archiveIncidents, field: "eventName")}</td>

            <td>${fieldValue(bean: archiveIncidents, field: "eventDesc")}</td>


            <td>${fieldValue(bean: archiveIncidents, field: "mgrsCoord")}</td>

            <td>${fieldValue(bean: archiveIncidents, field: "base")}</td>

            <td>${fieldValue(bean: archiveIncidents, field: "sigEvent")}</td>

            <td>${fieldValue(bean: archiveIncidents, field: "airOpsAffected")}</td>

            <td>${fieldValue(bean: archiveIncidents, field: "source")}</td>

            <td>${fieldValue(bean: archiveIncidents, field: "createdBy")}</td>

            <td><g:formatDate timeZone="America/Denver"  date="${archiveIncidents.createdDate}"/></td>

            <td><g:formatDate timeZone="America/Denver"  date="${archiveIncidents.updatedDate}"/></td>

            <td>${fieldValue(bean: archiveIncidents, field: "updatedBy")}</td>

            <td><g:formatDate timeZone="America/Denver"  date="${archiveIncidents.archivedAt}"/></td>
        </tr>
    </g:each>
    </tbody>
</table>

%{--<div id="currentArchiveTitle">--}%
    %{--<span class="property-label"><h1>Current Incident</h1></span>--}%
%{--</div>--}%

%{--<div id="show-currentIncidents" class="content scaffold-show" role="main">--}%
    %{--<h1><g:message code="default.show.label" args="[entityName]" /></h1>--}%
    %{--<g:if test="${flash.message}">--}%
        %{--<div class="message" role="status">${flash.message}</div>--}%
    %{--</g:if>--}%
    %{--<ol class="property-list currentIncidents">--}%

        %{--<g:if test="${currentIncidents?.id}">--}%
            %{--<li class="fieldcontain">--}%
                %{--<span id="id-label" class="property-label"><g:message code="currentIncidents.id.label" default="Incident Id" /></span>--}%

                %{--<span class="property-value" aria-labelledby="id-label"><g:fieldValue bean="${currentIncidents}" field="id"/></span>--}%

            %{--</li>--}%
        %{--</g:if>--}%

        %{--<g:if test="${currentIncidents?.eventType}">--}%
            %{--<li class="fieldcontain">--}%
                %{--<span id="eventType-label" class="property-label"><g:message code="currentIncidents.eventType.label" default="Event Type" /></span>--}%

                %{--<span class="property-value" aria-labelledby="eventType-label"><g:fieldValue bean="${currentIncidents}" field="eventType"/></span>--}%

            %{--</li>--}%
        %{--</g:if>--}%

        %{--<g:if test="${currentIncidents?.eventCat}">--}%
            %{--<li class="fieldcontain">--}%
                %{--<span id="eventCat-label" class="property-label"><g:message code="currentIncidents.eventCat.label" default="Category" /></span>--}%

                %{--<span class="property-value" aria-labelledby="eventCat-label"><g:fieldValue bean="${currentIncidents}" field="eventCat"/></span>--}%

            %{--</li>--}%
        %{--</g:if>--}%

        %{--<g:if test="${currentIncidents?.eventDate}">--}%
            %{--<li class="fieldcontain">--}%
                %{--<span id="eventDate-label" class="property-label"><g:message code="currentIncidents.eventDate.label" default="Event Date" /></span>--}%

                %{--<span class="property-value" aria-labelledby="eventDate-label"><g:formatDate timeZone="America/Denver"  date="${currentIncidents?.eventDate}" /></span>--}%

            %{--</li>--}%
        %{--</g:if>--}%

        %{--<g:if test="${currentIncidents?.eventName}">--}%
            %{--<li class="fieldcontain">--}%
                %{--<span id="eventName-label" class="property-label"><g:message code="currentIncidents.eventName.label" default="Event Name" /></span>--}%

                %{--<span class="property-value" aria-labelledby="eventName-label"><g:fieldValue bean="${currentIncidents}" field="eventName"/></span>--}%

            %{--</li>--}%
        %{--</g:if>--}%

        %{--<g:if test="${currentIncidents?.eventDesc}">--}%
            %{--<li class="fieldcontain">--}%
                %{--<span id="eventDesc-label" class="property-label"><g:message code="currentIncidents.eventDesc.label" default="Event Desc" /></span>--}%

                %{--<span class="property-value" aria-labelledby="eventDesc-label"><g:fieldValue bean="${currentIncidents}" field="eventDesc"/></span>--}%

            %{--</li>--}%
        %{--</g:if>--}%

            %{--<li class="fieldcontain">--}%


            %{--</li>--}%
        %{--</g:if>--}%

        %{--<g:if test="${currentIncidents?.mgrsCoord}">--}%
            %{--<li class="fieldcontain">--}%
                %{--<span id="mgrsCoord-label" class="property-label"><g:message code="currentIncidents.mgrsCoord.label" default="MGRS" /></span>--}%

                %{--<span class="property-value" aria-labelledby="mgrsCoord-label"><g:fieldValue bean="${currentIncidents}" field="mgrsCoord"/></span>--}%

            %{--</li>--}%
        %{--</g:if>--}%

        %{--<g:if test="${currentIncidents?.base}">--}%
            %{--<li class="fieldcontain">--}%
                %{--<span id="base-label" class="property-label"><g:message code="currentIncidents.base.label" default="Location" /></span>--}%

                %{--<span class="property-value" aria-labelledby="base-label"><g:fieldValue bean="${currentIncidents}" field="base"/></span>--}%

            %{--</li>--}%
        %{--</g:if>--}%

        %{--<g:if test="${currentIncidents?.sigEvent}">--}%
            %{--<li class="fieldcontain">--}%
                %{--<span id="sigEvent-label" class="property-label"><g:message code="currentIncidents.sigEvent.label" default="Sig Event" /></span>--}%

                %{--<span class="property-value" aria-labelledby="sigEvent-label"><g:fieldValue bean="${currentIncidents}" field="sigEvent"/></span>--}%

            %{--</li>--}%
        %{--</g:if>--}%

        %{--<g:if test="${currentIncidents?.airOpsAffected}">--}%
            %{--<li class="fieldcontain">--}%
                %{--<span id="airOpsAffected-label" class="property-label"><g:message code="currentIncidents.airOpsAffected.label" default="Air Ops Affected" /></span>--}%

                %{--<span class="property-value" aria-labelledby="airOpsAffected-label"><g:fieldValue bean="${currentIncidents}" field="airOpsAffected"/></span>--}%

            %{--</li>--}%
        %{--</g:if>--}%

        %{--<g:if test="${currentIncidents?.source}">--}%
            %{--<li class="fieldcontain">--}%
                %{--<span id="source-label" class="property-label"><g:message code="currentIncidents.source.label" default="Source" /></span>--}%

                %{--<span class="property-value" aria-labelledby="source-label"><g:fieldValue bean="${currentIncidents}" field="source"/></span>--}%

            %{--</li>--}%
        %{--</g:if>--}%

        %{--<g:if test="${currentIncidents?.createdBy}">--}%
            %{--<li class="fieldcontain">--}%
                %{--<span id="entered-label" class="property-label"><g:message code="currentIncidents.entered.label" default="Created By" /></span>--}%

                %{--<span class="property-value" aria-labelledby="entered-label"><g:fieldValue bean="${currentIncidents}" field="createdBy"/></span>--}%

            %{--</li>--}%
        %{--</g:if>--}%

        %{--<g:if test="${currentIncidents?.createdDate}">--}%
            %{--<li class="fieldcontain">--}%
                %{--<span id="createdDate-label" class="property-label"><g:message code="currentIncidents.createdDate.label" default="Created" /></span>--}%

                %{--<span class="property-value" aria-labelledby="createdDate-label"><g:fieldValue bean="${currentIncidents}" field="createdDate"/></span>--}%

            %{--</li>--}%
        %{--</g:if>--}%

        %{--<g:if test="${currentIncidents?.updatedBy}">--}%
            %{--<li class="fieldcontain">--}%
                %{--<span id="updatedBy-label" class="property-label"><g:message code="currentIncidents.updatedBy.label"--}%
                                                                             %{--default="Updated By"/></span>--}%

                %{--<span class="property-value" aria-labelledby="updatedBy-label"><g:fieldValue--}%
                        %{--bean="${currentIncidents}" field="updatedBy"/></span>--}%
            %{--</li>--}%
        %{--</g:if>--}%

        %{--<g:if test="${currentIncidents?.updatedDate}">--}%
            %{--<li class="fieldcontain">--}%
                %{--<span id="updatedDate-label" class="property-label"><g:message code="currentIncidents.updatedDate.label" default="Updated" /></span>--}%

                %{--<span class="property-value" aria-labelledby="updatedDate-label"><g:fieldValue bean="${currentIncidents}" field="updatedDate"/></span>--}%

            %{--</li>--}%
        %{--</g:if>--}%

        %{--<g:if test="${currentIncidents?.entered}">--}%
            %{--<li class="fieldcontain">--}%
                %{--<span id="eventSourceHan-label" class="property-label"><g:message code="currentIncidents.eventSourceHan.label" default="App" /></span>--}%

                %{--<span class="property-value" aria-labelledby="eventSourceHan-label"><g:fieldValue bean="${currentIncidents}" field="eventSourceHan"/></span>--}%

            %{--</li>--}%
        %{--</g:if>--}%

    %{--</ol>--}%
    %{--<g:form url="[resource:currentIncidents, action:'delete']" method="DELETE">--}%
        %{--<fieldset class="buttons current-incident-show-buttons">--}%
            %{--<g:link class="edit" action="edit" resource="${currentIncidents}"><g:message code="default.button.edit.label" default="Edit" /></g:link>--}%
        %{--</fieldset>--}%
    %{--</g:form>--}%
%{--</div>--}%

</body>

</html>
