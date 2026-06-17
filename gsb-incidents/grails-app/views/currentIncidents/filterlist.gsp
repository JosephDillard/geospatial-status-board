<%@ page import="gsb.incidents.CurrentIncidentsController" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <meta http-equiv="Refresh" content="300"/>
    <g:set var="entityName" value="${message(code: 'currentIncidents.label', default: 'Current Incidents')}"/>
    <title><g:message code="default.list.label" args="[entityName]"/></title>
    <asset:javascript src="fp.js"/>
    <asset:stylesheet src="fp.css"/>
</head>

<body>
<a href="#list-incidents" class="skip" tabindex="-1"><g:message code="default.link.skip.label" default="Skip to content&hellip;"/></a>

<div class="nav" role="navigation">
    <ul>
        <li><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
        <li><g:link class="list" action="index"><g:message code="default.list.label" args="[entityName]" /></g:link></li>
    </ul>
</div>

<div id="list-incidents" class="content scaffold-list" role="main">
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

            <th>Affects Operations</th>

            <th>Source</th>

            <th>Created By</th>

            <th>Created</th>

            <th>Updated By</th>

            <th>Updated</th>

            <th>Previous Edits</th>

        </tr>
        </thead>
        <tbody>
        <g:each in="${currentIncidentsList}" status="i" var="currentIncidents">
            <tr class="${(i % 2) == 0 ? 'even' : 'odd'}">

                <td><g:link action="show" id="${currentIncidents.id}">${currentIncidents.id}</g:link></td>

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

                <td>${fieldValue(bean: currentIncidents, field: "updatedBy")}</td>

                <td><g:formatDate timeZone="America/Denver"  date="${currentIncidents.updatedDate}"/></td>

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

    <div class="pagination">
        <filterpane:paginate total="${currentIncidentsCount}" domainBean="gsb.incidents.CurrentIncidents"/>
        <filterpane:filterButton text="Filter List"/>
        <filterpane:isFiltered>Filter Applied</filterpane:isFiltered>
    </div>
    <filterpane:filterPane domain="gsb.incidents.CurrentIncidents"

                           titleKey="fp.tag.filterPane.titleText"
                           dialog="true"
                           visible="n"
                           showSortPanel="y"
                           showTitle="y"
                           filterParams="n"
                           fullAssociationPathFieldNames="true"/>
</div>

</body>
</html>
