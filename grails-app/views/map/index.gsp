<!doctype html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>Map View</title>
    <content tag="hideQuickLinks">true</content>
    <link rel="stylesheet" href="${mapLibreCssUrl}"/>
    <g:if test="${drawEnabled && mapDrawCssUrl}">
        <link rel="stylesheet" href="${mapDrawCssUrl}"/>
    </g:if>
</head>
<body>
<main class="geo-map-page" role="main">
    <section class="geo-map-toolbar" aria-label="Map controls">
        <div>
            <h1>Map View</h1>
            <p>Geospatial view of airport, airfield, and incident status layers.</p>
        </div>
        <g:form controller="map" action="index" method="GET" class="geo-map-form">
            <button id="geo-filter-toggle"
                    type="button"
                    class="geo-map-form-toggle"
                    aria-expanded="${selectedValue ? 'true' : 'false'}"
                    aria-controls="geo-filter-fields">Filter</button>
            <div id="geo-filter-fields" class="geo-filter-fields"${selectedValue ? '' : ' hidden'}>
                <div class="geo-map-field">
                    <label for="layer">Layer</label>
                    <select id="layer" name="layer">
                        <g:each in="${layers}" var="entry">
                            <option value="${entry.key}"${entry.key == selectedLayer ? ' selected' : ''}>${entry.value.title}</option>
                        </g:each>
                    </select>
                </div>

                <div class="geo-map-field">
                    <label for="field">Filter field</label>
                    <select id="field" name="field" data-selected-field="${selectedField}">
                        <option value="${selectedField}">${selectedField}</option>
                    </select>
                </div>

                <div class="geo-map-field">
                    <label for="value">Filter value</label>
                    <input id="value" name="value" type="text" value="${selectedValue}"/>
                </div>
            </div>

            <button type="submit" class="btn btn-primary">Load</button>
        </g:form>
    </section>

    <section class="geo-map-shell" aria-label="Geospatial map">
        <div id="geo-map-status" class="geo-map-status" aria-label="Map messages">
            <button id="geo-map-status-toggle"
                    type="button"
                    class="geo-map-status-toggle"
                    aria-label="Collapse map messages"
                    aria-expanded="true"
                    title="Collapse map messages">
                <span id="geo-map-status-count" class="geo-map-status-count">0</span>
                <span id="geo-map-status-icon" class="geo-map-status-icon" aria-hidden="true">&lt;</span>
            </button>
            <span id="geo-map-status-message" class="geo-map-status-message" aria-live="polite">Loading map...</span>
        </div>
        <div class="geo-map-thumb-controls" aria-label="Map panels">
            <button id="geo-layer-toggle"
                    type="button"
                    class="geo-map-thumb-button geo-map-drawer-toggle"
                    aria-label="Layers"
                    title="Layers"
                    aria-expanded="true">
                <span class="geo-layer-thumb" aria-hidden="true">
                    <span></span><span></span><span></span>
                </span>
                <span class="geo-map-thumb-label">Layers</span>
            </button>
            <div id="geo-basemap-picker" class="geo-basemap-picker" aria-label="Basemaps">
                <button id="geo-basemap-toggle"
                        type="button"
                        class="geo-map-thumb-button"
                        aria-label="Basemaps"
                        title="Basemaps"
                        aria-expanded="false">
                    <span class="geo-basemap-toggle-preview" aria-hidden="true"></span>
                    <span id="geo-basemap-toggle-label" class="geo-map-thumb-label">Basemap</span>
                </button>
                <div id="geo-basemap-menu" class="geo-basemap-menu" hidden>
                    <g:each in="${basemaps}" var="entry">
                        <button type="button"
                                class="geo-basemap-card"
                                data-basemap-key="${entry.key}"
                                data-basemap-preview-image="${entry.value.previewImage ?: ''}"
                                aria-label="${entry.value.title}"
                                title="${entry.value.title}"
                                style="--basemap-preview: ${entry.value.preview};">
                            <span class="geo-basemap-preview" aria-hidden="true"></span>
                            <span class="geo-basemap-card-label">${entry.value.buttonLabel ?: entry.value.title}</span>
                        </button>
                    </g:each>
                </div>
            </div>
        </div>
        <aside id="geo-layer-drawer" class="geo-layer-drawer" aria-label="Map layers">
            <div class="geo-layer-drawer-header">
                <strong>Layers</strong>
                <button id="geo-layer-close" type="button" class="geo-map-icon-button" aria-label="Hide layers">x</button>
            </div>
            <details open>
                <summary>Internal</summary>
                <div id="geo-internal-layer-list" class="geo-layer-list"></div>
            </details>
            <details open>
                <summary>External</summary>
                <div id="geo-external-layer-list" class="geo-layer-list"></div>
            </details>
        </aside>

        <div id="geo-left-map-controls" class="geo-left-map-controls" aria-label="Map controls">
            <div id="geo-zoom-control" class="geo-zoom-control" aria-label="Zoom controls">
                <button id="geo-zoom-in" type="button" class="geo-map-square-button" aria-label="Zoom in" title="Zoom in">+</button>
                <select id="geo-zoom-level" aria-label="Zoom level"></select>
                <button id="geo-zoom-out" type="button" class="geo-map-square-button" aria-label="Zoom out" title="Zoom out">-</button>
            </div>
            <div id="geo-view-tools" class="geo-view-control">
                <button id="geo-fit-layer"
                        type="button"
                        class="geo-map-square-button geo-fit-layer-button"
                        aria-label="Fit layers"
                        title="Fit layers">
                    <span aria-hidden="true"></span>
                </button>
            </div>
            <div id="geo-incident-tools" class="geo-incident-control">
                <button id="geo-incident-create-toggle"
                        type="button"
                        class="geo-map-square-button geo-incident-create-toggle"
                        aria-label="Create incident"
                        aria-pressed="false"
                        title="Create incident">
                    <span aria-hidden="true"></span>
                </button>
            </div>
            <div id="geo-place-search-tools" class="geo-place-search-control">
                <button id="geo-place-search-toggle"
                        type="button"
                        class="geo-map-square-button geo-place-search-toggle"
                        aria-label="Search nearby Wikipedia places"
                        aria-pressed="false"
                        title="Search nearby Wikipedia places">
                    Wiki
                </button>
            </div>
            <div id="geo-ai-tools" class="geo-ai-control">
                <button id="geo-ai-toggle"
                        type="button"
                        class="geo-map-square-button geo-ai-toggle"
                        aria-label="LLM request"
                        aria-expanded="false"
                        title="LLM request">
                    LLM
                </button>
                <aside id="geo-ai-panel" class="geo-ai-panel" aria-label="GeoAI request" hidden>
                    <div class="geo-ai-panel-header">
                        <strong>GeoAI Request</strong>
                        <button id="geo-ai-close" type="button" class="geo-map-icon-button" aria-label="Close GeoAI request">x</button>
                    </div>
                    <form id="geo-ai-form" class="geo-ai-form">
                        <div class="geo-ai-field">
                            <label for="geo-ai-model">Model</label>
                            <select id="geo-ai-model" name="modelId" disabled>
                                <option value="">Loading...</option>
                            </select>
                        </div>
                        <div class="geo-ai-field">
                            <label for="geo-ai-workflow">Workflow</label>
                            <select id="geo-ai-workflow" name="workflowId" disabled>
                                <option value="">Select model first</option>
                            </select>
                        </div>
                        <div class="geo-ai-field">
                            <label for="geo-ai-extent">Extent</label>
                            <output id="geo-ai-extent">Current map view</output>
                        </div>
                        <div class="geo-ai-actions">
                            <button id="geo-ai-submit" type="submit" class="btn btn-primary" disabled>Submit</button>
                        </div>
                    </form>
                    <output id="geo-ai-status" class="geo-ai-status" aria-live="polite">Checking GeoAI...</output>
                </aside>
            </div>
            <div id="geo-measure-tools" class="geo-measure-control">
                <button id="geo-measure-toggle"
                        type="button"
                        class="geo-map-square-button geo-measure-toggle"
                        aria-label="Measure distance"
                        aria-expanded="false"
                        aria-pressed="false"
                        title="Measure distance">
                    <span aria-hidden="true"></span>
                </button>
                <div id="geo-measure-panel" class="geo-measure-panel" hidden>
                    <output id="geo-measure-output" class="geo-map-tool-output">0 mi</output>
                    <button id="geo-measure-clear" type="button" class="geo-map-tool-button">Clear</button>
                </div>
            </div>
            <div id="geo-north-control" class="geo-north-control">
                <button id="geo-reset-north"
                        type="button"
                        class="geo-map-square-button geo-north-arrow-button"
                        aria-label="Reset north"
                        title="Reset north">
                    <span class="geo-north-label" aria-hidden="true">N</span>
                    <span id="geo-north-arrow-indicator" class="geo-north-arrow-indicator" aria-hidden="true"></span>
                </button>
            </div>
        </div>

        <div id="geo-draw-tools" class="geo-draw-summary" aria-label="Draw summary" hidden>
            <output id="geo-draw-output" class="geo-map-tool-output">Ready</output>
        </div>

        <div id="geo-coordinate-panel" class="geo-coordinate-panel" aria-label="Coordinates">
            <select id="geo-coordinate-format" aria-label="Coordinate format">
                <option value="mgrs">MGRS</option>
                <option value="latLon">Lat/Lon</option>
                <option value="dms">DMS</option>
            </select>
            <label class="geo-coordinate-copy-toggle" title="Copy selected coordinate when clicking the map">
                <input id="geo-coordinate-click-copy" type="checkbox" aria-label="Copy selected coordinate when clicking the map"/>
            </label>
            <output id="geo-coordinate-output">Move over map</output>
        </div>
        <aside id="geo-incident-create-panel" class="geo-incident-create-panel" aria-label="Create incident" hidden>
            <div class="geo-incident-create-header">
                <strong>New Incident</strong>
                <button id="geo-incident-create-close" type="button" class="geo-map-icon-button" aria-label="Close incident form">x</button>
            </div>
            <form id="geo-incident-create-form" class="geo-incident-create-form">
                <div class="geo-incident-field">
                    <label for="geo-incident-event-name">Name</label>
                    <input id="geo-incident-event-name" name="eventName" type="text" required/>
                </div>
                <div class="geo-incident-field-pair">
                    <div class="geo-incident-field">
                        <label for="geo-incident-event-type">Type</label>
                        <input id="geo-incident-event-type" name="eventType" type="text" list="geo-incident-event-type-options" required/>
                    </div>
                    <div class="geo-incident-field">
                        <label for="geo-incident-event-cat">Category</label>
                        <input id="geo-incident-event-cat" name="eventCat" type="text" list="geo-incident-event-cat-options"/>
                    </div>
                </div>
                <div class="geo-incident-field">
                    <label for="geo-incident-event-desc">Description</label>
                    <textarea id="geo-incident-event-desc" name="eventDesc" rows="3"></textarea>
                </div>
                <div class="geo-incident-field-pair">
                    <div class="geo-incident-field">
                        <label for="geo-incident-base">Base</label>
                        <input id="geo-incident-base" name="base" type="text" list="geo-incident-base-options"/>
                    </div>
                    <div class="geo-incident-field">
                        <label for="geo-incident-source">Source</label>
                        <input id="geo-incident-source" name="source" type="text" list="geo-incident-source-options"/>
                    </div>
                </div>
                <div class="geo-incident-field-pair">
                    <div class="geo-incident-field">
                        <label for="geo-incident-sig-event">Significant</label>
                        <input id="geo-incident-sig-event" name="sigEvent" type="text" list="geo-incident-yes-no-options" value="No"/>
                    </div>
                    <div class="geo-incident-field">
                        <label for="geo-incident-air-ops">Air Ops</label>
                        <input id="geo-incident-air-ops" name="airOpsAffected" type="text" list="geo-incident-yes-no-options" value="No"/>
                    </div>
                </div>
                <div class="geo-incident-field">
                    <label for="geo-incident-id">Incident ID</label>
                    <input id="geo-incident-id" name="incidentId" type="text" placeholder="Auto"/>
                </div>
                <div class="geo-incident-field-pair">
                    <div class="geo-incident-field">
                        <label for="geo-incident-lat">Latitude</label>
                        <input id="geo-incident-lat" name="latitude" type="text" readonly/>
                    </div>
                    <div class="geo-incident-field">
                        <label for="geo-incident-lon">Longitude</label>
                        <input id="geo-incident-lon" name="longitude" type="text" readonly/>
                    </div>
                </div>
                <div class="geo-incident-field">
                    <label for="geo-incident-mgrs">MGRS</label>
                    <input id="geo-incident-mgrs" name="mgrsCoord" type="text" readonly/>
                </div>
                <div class="geo-incident-actions">
                    <button id="geo-incident-save" type="submit" class="btn btn-primary">Save</button>
                    <button id="geo-incident-cancel" type="button" class="geo-map-tool-button">Cancel</button>
                </div>
            </form>
            <datalist id="geo-incident-event-type-options"></datalist>
            <datalist id="geo-incident-event-cat-options"></datalist>
            <datalist id="geo-incident-base-options"></datalist>
            <datalist id="geo-incident-source-options"></datalist>
            <datalist id="geo-incident-yes-no-options"></datalist>
        </aside>
        <div id="geo-map" class="geo-map-canvas"></div>
    </section>
</main>

<script src="${mapLibreJsUrl}"></script>
<g:if test="${drawEnabled && mapDrawJsUrl}">
    <script>window.mapboxgl = window.maplibregl;</script>
    <script src="${mapDrawJsUrl}"></script>
</g:if>
<g:if test="${mgrsEnabled && mgrsJsUrl}">
    <script src="${mgrsJsUrl}"></script>
</g:if>
<script>
(function () {
    var config = ${raw(mapConfigJson)};
    var incidentLookupOptions = ${raw(incidentLookupOptionsJson)};
    var incidentCreateUrl = '${createLink(controller: 'currentIncidents', action: 'mapCreate')}';
    var statusEl = document.getElementById('geo-map-status');
    var statusMessage = document.getElementById('geo-map-status-message');
    var statusToggle = document.getElementById('geo-map-status-toggle');
    var statusCount = document.getElementById('geo-map-status-count');
    var statusIcon = document.getElementById('geo-map-status-icon');
    var layerToggle = document.getElementById('geo-layer-toggle');
    var layerDrawer = document.getElementById('geo-layer-drawer');
    var layerClose = document.getElementById('geo-layer-close');
    var internalLayerList = document.getElementById('geo-internal-layer-list');
    var externalLayerList = document.getElementById('geo-external-layer-list');
    var basemapPicker = document.getElementById('geo-basemap-picker');
    var basemapToggle = document.getElementById('geo-basemap-toggle');
    var basemapToggleLabel = document.getElementById('geo-basemap-toggle-label');
    var basemapMenu = document.getElementById('geo-basemap-menu');
    var filterToggle = document.getElementById('geo-filter-toggle');
    var filterFields = document.getElementById('geo-filter-fields');
    var filterLayerSelect = document.getElementById('layer');
    var filterFieldSelect = document.getElementById('field');
    var coordinatePanel = document.getElementById('geo-coordinate-panel');
    var coordinateOutput = document.getElementById('geo-coordinate-output');
    var coordinateFormat = document.getElementById('geo-coordinate-format');
    var coordinateClickCopy = document.getElementById('geo-coordinate-click-copy');
    var zoomInButton = document.getElementById('geo-zoom-in');
    var zoomOutButton = document.getElementById('geo-zoom-out');
    var zoomLevelSelect = document.getElementById('geo-zoom-level');
    var zoomControl = document.getElementById('geo-zoom-control');
    var viewTools = document.getElementById('geo-view-tools');
    var fitLayer = document.getElementById('geo-fit-layer');
    var incidentTools = document.getElementById('geo-incident-tools');
    var incidentCreateToggle = document.getElementById('geo-incident-create-toggle');
    var incidentCreatePanel = document.getElementById('geo-incident-create-panel');
    var incidentCreateClose = document.getElementById('geo-incident-create-close');
    var incidentCreateForm = document.getElementById('geo-incident-create-form');
    var incidentCancel = document.getElementById('geo-incident-cancel');
    var incidentSave = document.getElementById('geo-incident-save');
    var placeSearchTools = document.getElementById('geo-place-search-tools');
    var placeSearchToggle = document.getElementById('geo-place-search-toggle');
    var geoAiTools = document.getElementById('geo-ai-tools');
    var geoAiToggle = document.getElementById('geo-ai-toggle');
    var geoAiPanel = document.getElementById('geo-ai-panel');
    var geoAiClose = document.getElementById('geo-ai-close');
    var geoAiForm = document.getElementById('geo-ai-form');
    var geoAiModel = document.getElementById('geo-ai-model');
    var geoAiWorkflow = document.getElementById('geo-ai-workflow');
    var geoAiSubmit = document.getElementById('geo-ai-submit');
    var geoAiExtent = document.getElementById('geo-ai-extent');
    var geoAiStatus = document.getElementById('geo-ai-status');
    var measureTools = document.getElementById('geo-measure-tools');
    var measureToggle = document.getElementById('geo-measure-toggle');
    var measurePanel = document.getElementById('geo-measure-panel');
    var measureClear = document.getElementById('geo-measure-clear');
    var measureOutput = document.getElementById('geo-measure-output');
    var resetNorth = document.getElementById('geo-reset-north');
    var northArrowIndicator = document.getElementById('geo-north-arrow-indicator');
    var drawTools = document.getElementById('geo-draw-tools');
    var drawOutput = document.getElementById('geo-draw-output');
    var measureSourceId = 'measure-features';
    var measureLayerIds = ['measure-line', 'measure-points'];
    var incidentDraftSourceId = 'incident-draft-source';
    var incidentDraftLayerId = 'incident-draft-layer';
    var localIncidentSourceId = 'incident-created-source';
    var localIncidentLayerId = 'incident-created-layer';
    var basemapSourceId = 'geo-basemap-source';
    var basemapLayerId = 'geo-basemap-raster';
    var backgroundLayerId = 'geo-basemap-background';
    var activeBasemapKey = config.selectedBasemap;
    var internalLayerState = {};
    var internalLayerRequestSeq = 0;
    var externalLayerState = {};
    var renderLayerToLayerKey = {};
    var layerIssueState = {};
    var layerFilters = {};
    var persistedLayerFilterOptions = {};
    var measureMode = false;
    var measurePoints = [];
    var incidentCreateMode = false;
    var placeSearchMode = false;
    var incidentDraft = null;
    var localIncidentFeatures = [];
    var hoverCoordinate = null;
    var draw = null;
    var geoAiModels = [];
    var geoAiWorkflows = [];
    var geoAiCurrentRunId = null;
    var geoAiPollTimer = null;
    var geoAiRunActive = false;
    var gatewaySocket = null;
    var gatewayReconnectTimer = null;
    var gatewayConnected = false;

    function setStatus(message, isError) {
        var collapsed = statusEl.classList.contains('is-collapsed');
        statusMessage.textContent = message;
        statusEl.className = isError ? 'geo-map-status geo-map-status-error' : 'geo-map-status';
        statusEl.classList.toggle('is-collapsed', collapsed);
        updateStatusIssueCount();
    }

    function layerIssueCount() {
        return Object.keys(layerIssueState).filter(function (key) {
            return layerIssueState[key];
        }).length;
    }

    function updateStatusIssueCount() {
        var count = layerIssueCount();
        statusCount.textContent = String(count);
        statusEl.classList.toggle('has-layer-issues', count > 0);
        statusToggle.setAttribute('aria-label', (statusEl.classList.contains('is-collapsed') ? 'Expand' : 'Collapse') +
            ' map messages. ' + count + ' layer issue' + (count === 1 ? '' : 's') + '.');
    }

    function setStatusCollapsed(collapsed) {
        statusEl.classList.toggle('is-collapsed', collapsed);
        statusToggle.setAttribute('aria-expanded', collapsed ? 'false' : 'true');
        statusToggle.title = collapsed ? 'Expand map messages' : 'Collapse map messages';
        statusIcon.textContent = collapsed ? '>' : '<';
        updateStatusIssueCount();
    }

    function firstKey(object) {
        var keys = Object.keys(object || {});
        return keys.length ? keys[0] : null;
    }

    function safeId(value) {
        return String(value).replace(/[^a-zA-Z0-9_-]/g, '-');
    }

    function cssUrl(value) {
        return 'url("' + String(value || '').replace(/["\\]/g, '\\$&') + '")';
    }

    function sourceIdFor(key) {
        return 'status-source-' + safeId(key);
    }

    function setFilterOpen(open) {
        if (!filterToggle || !filterFields) {
            return;
        }
        filterFields.hidden = !open;
        filterToggle.setAttribute('aria-expanded', open ? 'true' : 'false');
        filterToggle.classList.toggle('is-active', open);
    }

    function compactFields(values) {
        var seen = {};
        return (values || []).filter(function (value) {
            value = String(value || '').trim();
            if (!value || seen[value]) {
                return false;
            }
            seen[value] = true;
            return true;
        });
    }

    function filterableFieldsForLayer(layer) {
        var configuredFields = compactFields(layer.filterFields || []);
        if (configuredFields.length) {
            return configuredFields;
        }

        return compactFields([
            layer.idField,
            layer.labelField,
            layer.filterField,
            layer.iconField,
        ].concat(layer.popupFields || []));
    }

    function filterFieldLabel(field) {
        return popupLabel(field);
    }

    function populateTopFilterFields() {
        if (!filterLayerSelect || !filterFieldSelect) {
            return;
        }

        var selectedLayer = (config.layers || {})[filterLayerSelect.value] || {};
        var selectedField = filterFieldSelect.getAttribute('data-selected-field') || selectedLayer.idField || '';
        var fields = filterableFieldsForLayer(selectedLayer);
        if (selectedField && fields.indexOf(selectedField) < 0) {
            fields.unshift(selectedField);
        }

        filterFieldSelect.innerHTML = '';
        fields.forEach(function (field) {
            var option = document.createElement('option');
            option.value = field;
            option.textContent = filterFieldLabel(field);
            filterFieldSelect.appendChild(option);
        });
        filterFieldSelect.value = fields.indexOf(selectedField) >= 0 ? selectedField : (fields[0] || '');
    }

    function geoAiConfig() {
        return config.geoai || {};
    }

    function gatewayConfig() {
        return config.gateway || {};
    }

    function signalRRecordSeparator() {
        return String.fromCharCode(0x1e);
    }

    function gatewayValue(payload, camelName) {
        if (!payload) {
            return null;
        }
        var pascalName = camelName.charAt(0).toUpperCase() + camelName.slice(1);
        return payload[camelName] != null ? payload[camelName] : payload[pascalName];
    }

    function gatewayHubBaseUrl() {
        return String(gatewayConfig().hubUrl || '').replace(/\/+$/, '');
    }

    function gatewayNegotiateUrl() {
        var url = new URL(gatewayHubBaseUrl(), window.location.href);
        url.pathname = url.pathname.replace(/\/$/, '') + '/negotiate';
        url.searchParams.set('negotiateVersion', '1');
        return url.toString();
    }

    function gatewayWebSocketUrl(connectionToken) {
        var url = new URL(gatewayHubBaseUrl(), window.location.href);
        url.protocol = url.protocol === 'https:' ? 'wss:' : 'ws:';
        if (connectionToken) {
            url.searchParams.set('id', connectionToken);
        }
        return url.toString();
    }

    function gatewayTypeNameTable(value) {
        var text = String(value || '').trim();
        if (!text) {
            return '';
        }
        var parts = text.split(':');
        text = parts[parts.length - 1];
        parts = text.split('.');
        return parts[parts.length - 1].toLowerCase();
    }

    function gatewayLayerKeyForPayload(payload) {
        var explicitKey = gatewayValue(payload, 'layerKey');
        if (explicitKey && (config.layers || {})[explicitKey]) {
            return explicitKey;
        }

        var targetTypeName = gatewayValue(payload, 'targetTypeName');
        var targetTable = gatewayValue(payload, 'targetTable');
        var targetTypeTable = gatewayTypeNameTable(targetTypeName);
        var table = gatewayTypeNameTable(targetTable);
        return Object.keys(config.layers || {}).find(function (key) {
            var layer = config.layers[key] || {};
            var layerTable = gatewayTypeNameTable(layer.typeName);
            return (targetTypeName && String(layer.typeName || '').toLowerCase() === String(targetTypeName).toLowerCase()) ||
                (targetTypeTable && layerTable === targetTypeTable) ||
                (table && layerTable === table);
        }) || null;
    }

    function gatewayFilterValue(payload) {
        var explicitFilter = gatewayValue(payload, 'filterValue');
        if (explicitFilter) {
            return explicitFilter;
        }
        return gatewayValue(payload, 'jobId');
    }

    function refreshLayerFromGatewayPayload(payload) {
        var key = gatewayLayerKeyForPayload(payload);
        if (!key) {
            setStatus('Gateway live event received, but no matching map layer is configured.');
            return;
        }

        var layer = config.layers[key] || {};
        var filterValue = gatewayFilterValue(payload);
        if (layer.filterField && filterValue) {
            filterValue = String(filterValue);
            layerFilters[key] = filterValue;
            rememberPersistedLayerFilterOption(key, {
                value: filterValue,
                label: 'Job ' + shortRunId(filterValue),
                title: filterValue
            });
            var filter = layerFilterSelect(key);
            if (filter) {
                filter.value = filterValue;
            }
        }

        var checkbox = document.querySelector('[data-layer-kind="internal"][data-layer-key="' + key + '"]');
        if (checkbox) {
            checkbox.checked = true;
        }
        if ((internalLayerState[key] || {}).loaded) {
            removeInternalLayer(key);
        }
        loadInternalLayer(key);
        setStatus('Gateway requested refresh for ' + (layer.title || key) +
            (filterValue ? ' job ' + shortRunId(filterValue) : '') + '.');
    }

    function handleGatewayInvocation(target, args) {
        var configuredEvent = String(gatewayConfig().eventName || 'layer.refresh_requested').toLowerCase();
        if (String(target || '').toLowerCase() === configuredEvent) {
            refreshLayerFromGatewayPayload((args || [])[0] || {});
        }
    }

    function handleGatewaySocketMessage(event) {
        String(event.data || '').split(signalRRecordSeparator()).forEach(function (frame) {
            if (!frame) {
                return;
            }
            var message = JSON.parse(frame);
            if (message.type === 1 && message.target) {
                handleGatewayInvocation(message.target, message.arguments || []);
            }
        });
    }

    function scheduleGatewayReconnect() {
        if (!gatewayConfig().enabled || gatewayReconnectTimer) {
            return;
        }
        gatewayReconnectTimer = window.setTimeout(function () {
            gatewayReconnectTimer = null;
            connectGatewayUpdates();
        }, Number(gatewayConfig().reconnectDelayMs || 5000));
    }

    function openGatewaySocket(connectionToken) {
        var socket = new WebSocket(gatewayWebSocketUrl(connectionToken));
        gatewaySocket = socket;
        socket.onopen = function () {
            gatewayConnected = true;
            socket.send(JSON.stringify({ protocol: 'json', version: 1 }) + signalRRecordSeparator());
            setStatus('Connected to Geospatial Data Gateway live stream.');
        };
        socket.onmessage = handleGatewaySocketMessage;
        socket.onclose = function () {
            gatewayConnected = false;
            if (gatewaySocket === socket) {
                gatewaySocket = null;
            }
            scheduleGatewayReconnect();
        };
        socket.onerror = function () {
            if (!gatewayConnected) {
                setStatus('Geospatial Data Gateway live stream is unavailable; retrying.');
            }
        };
    }

    function connectGatewayUpdates() {
        if (!gatewayConfig().enabled || !gatewayHubBaseUrl()) {
            return;
        }
        if (!window.fetch || !window.WebSocket) {
            setStatus('This browser cannot connect to the gateway live stream.', true);
            return;
        }
        if (gatewaySocket && (gatewaySocket.readyState === WebSocket.OPEN || gatewaySocket.readyState === WebSocket.CONNECTING)) {
            return;
        }

        fetch(gatewayNegotiateUrl(), {
            method: 'POST',
            credentials: 'omit',
            headers: {
                'Accept': 'application/json'
            }
        })
            .then(function (response) {
                if (!response.ok) {
                    throw new Error('Gateway negotiate returned HTTP ' + response.status);
                }
                return response.json();
            })
            .then(function (payload) {
                openGatewaySocket(payload.connectionToken || payload.connectionId || '');
            })
            .catch(function () {
                setStatus('Geospatial Data Gateway live stream is unavailable; retrying.');
                scheduleGatewayReconnect();
            });
    }

    function formatGeoAiJobTime(value) {
        if (!value) {
            return '';
        }
        var date = new Date(value);
        if (Number.isNaN(date.getTime())) {
            return String(value);
        }
        return date.toLocaleString([], {
            month: 'short',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });
    }

    function geoAiJobOption(job) {
        var id = String(job.job_id || job.id || '');
        var count = Number(job.feature_count || 0);
        var parts = ['Job ' + shortRunId(id)];
        if (job.workflow_id) {
            parts.push(job.workflow_id);
        }
        parts.push(count + ' feature' + (count === 1 ? '' : 's'));
        var loadedAt = formatGeoAiJobTime(job.loaded_at);
        if (loadedAt) {
            parts.push(loadedAt);
        }
        return {
            value: id,
            label: parts.join(' - '),
            title: id
        };
    }

    function mergeLayerFilterOptions(existingOptions, newOptions) {
        var seen = {};
        var merged = [];
        (existingOptions || []).concat(newOptions || []).map(normalizeLayerFilterOption).forEach(function (option) {
            if (!option.value || seen[option.value]) {
                return;
            }
            seen[option.value] = true;
            merged.push(option);
        });
        return merged;
    }

    function rememberPersistedLayerFilterOption(key, option) {
        if (!option || !option.value) {
            return;
        }
        persistedLayerFilterOptions[key] = mergeLayerFilterOptions([option], persistedLayerFilterOptions[key] || []);
        refreshLayerFilterOptions(key);
    }

    function rememberGeoAiJobFromRun(run) {
        if (!run || !run.id) {
            return;
        }
        rememberPersistedLayerFilterOption('detectedRoads', {
            value: run.id,
            label: 'Job ' + shortRunId(run.id) + ' - ' + postgisLoadCount(run) + ' feature' +
                (postgisLoadCount(run) === 1 ? '' : 's'),
            title: run.id
        });
    }

    function loadGeoAiJobs() {
        var jobsUrl = geoAiConfig().jobsUrl;
        if (!jobsUrl || !window.fetch) {
            return Promise.resolve();
        }
        var url = jobsUrl + (jobsUrl.indexOf('?') >= 0 ? '&' : '?') + 'limit=200';
        return geoAiFetch(url)
            .then(function (payload) {
                var jobs = (payload.jobs || []).map(geoAiJobOption);
                persistedLayerFilterOptions.detectedRoads = mergeLayerFilterOptions(
                    jobs,
                    persistedLayerFilterOptions.detectedRoads || []
                );
                refreshLayerFilterOptions('detectedRoads');
            })
            .catch(function () {
                refreshLayerFilterOptions('detectedRoads');
            });
    }

    function setGeoAiPanelOpen(open) {
        if (!geoAiPanel || !geoAiToggle) {
            return;
        }
        geoAiPanel.hidden = !open;
        geoAiToggle.classList.toggle('is-active', open);
        geoAiToggle.setAttribute('aria-expanded', open ? 'true' : 'false');
        if (open) {
            setPlaceSearchMode(false);
            setIncidentCreateMode(false);
            setIncidentPanelOpen(false);
            setMeasureMode(false);
            updateGeoAiExtent();
            if (!geoAiModels.length) {
                loadGeoAiOptions();
            }
        }
    }

    function setGeoAiStatus(message, isError) {
        if (!geoAiStatus) {
            return;
        }
        geoAiStatus.textContent = message || '';
        geoAiStatus.classList.toggle('is-error', !!isError);
    }

    function setGeoAiControlsEnabled(enabled) {
        var available = enabled && !geoAiRunActive;
        if (geoAiModel) {
            geoAiModel.disabled = !available;
        }
        if (geoAiWorkflow) {
            geoAiWorkflow.disabled = !available || !geoAiWorkflow.value;
        }
        if (geoAiSubmit) {
            geoAiSubmit.disabled = !available ||
                !geoAiModel ||
                !geoAiModel.value ||
                !geoAiWorkflow ||
                !geoAiWorkflow.value;
        }
    }

    function geoAiFetch(url, options) {
        var timeoutMs = Number(geoAiConfig().requestTimeoutMs || 10000);
        var requestOptions = Object.assign({
            credentials: 'same-origin',
            headers: {
                'Accept': 'application/json'
            }
        }, options || {});
        var timeoutId = null;

        if (requestOptions.body && !requestOptions.headers['Content-Type']) {
            requestOptions.headers['Content-Type'] = 'application/json';
        }

        if (window.AbortController && timeoutMs > 0) {
            var controller = new AbortController();
            requestOptions.signal = controller.signal;
            timeoutId = window.setTimeout(function () {
                controller.abort();
            }, timeoutMs);
        }

        return fetch(url, requestOptions).then(function (response) {
            return response.text().then(function (text) {
                var body = text ? JSON.parse(text) : {};
                if (!response.ok) {
                    throw new Error(body.detail || body.error || 'GeoAI returned HTTP ' + response.status);
                }
                return body;
            });
        }).catch(function (error) {
            if (error && error.name === 'AbortError') {
                throw new Error('GeoAI did not respond within ' + timeoutMs + ' ms');
            }
            if (error instanceof TypeError) {
                throw new Error('GeoAI is unavailable');
            }
            throw error;
        }).finally(function () {
            if (timeoutId) {
                window.clearTimeout(timeoutId);
            }
        });
    }

    function selectedGeoAiModel() {
        var modelId = geoAiModel ? geoAiModel.value : '';
        return (geoAiModels || []).find(function (model) {
            return model.id === modelId;
        }) || null;
    }

    function workflowUsesPostgis(workflow) {
        var stages = workflow.default_stages || workflow.stages || [];
        return stages.indexOf('load-postgis') >= 0;
    }

    function preferredGeoAiWorkflow(workflows) {
        var postgis = workflows.filter(workflowUsesPostgis);
        var candidates = postgis.length ? postgis : workflows;
        return candidates.find(function (workflow) {
            return String(workflow.id || '').indexOf('new-mexico') >= 0 && workflowUsesPostgis(workflow);
        }) || candidates.find(function (workflow) {
            return workflow.enabled;
        }) || candidates[0] || null;
    }

    function workflowsForSelectedModel() {
        var model = selectedGeoAiModel();
        if (!model) {
            return [];
        }
        var ids = Array.isArray(model.workflow_ids) ? model.workflow_ids : [];
        return (geoAiWorkflows || []).filter(function (workflow) {
            if (ids.length) {
                return ids.indexOf(workflow.id) >= 0;
            }
            return workflow.model_id === model.id;
        });
    }

    function populateGeoAiWorkflows() {
        if (!geoAiWorkflow) {
            return;
        }
        var workflows = workflowsForSelectedModel();
        var preferred = preferredGeoAiWorkflow(workflows);
        geoAiWorkflow.innerHTML = '';

        if (!workflows.length) {
            var emptyOption = document.createElement('option');
            emptyOption.value = '';
            emptyOption.textContent = 'No workflow';
            geoAiWorkflow.appendChild(emptyOption);
            setGeoAiControlsEnabled(false);
            return;
        }

        workflows.forEach(function (workflow) {
            var option = document.createElement('option');
            option.value = workflow.id;
            option.textContent = workflow.name || workflow.id;
            option.title = (workflow.default_stages || workflow.stages || []).join(', ');
            geoAiWorkflow.appendChild(option);
        });
        geoAiWorkflow.value = preferred ? preferred.id : workflows[0].id;
        setGeoAiControlsEnabled(true);
    }

    function populateGeoAiModels(models, workflows) {
        geoAiModels = Array.isArray(models) ? models : [];
        geoAiWorkflows = Array.isArray(workflows) ? workflows : [];
        if (!geoAiModel) {
            return;
        }

        geoAiModel.innerHTML = '';
        if (!geoAiModels.length) {
            var emptyOption = document.createElement('option');
            emptyOption.value = '';
            emptyOption.textContent = 'No models';
            geoAiModel.appendChild(emptyOption);
            if (geoAiWorkflow) {
                geoAiWorkflow.innerHTML = '<option value="">No workflow</option>';
            }
            setGeoAiControlsEnabled(false);
            return;
        }

        geoAiModels.forEach(function (model) {
            var option = document.createElement('option');
            option.value = model.id;
            option.textContent = model.name || model.id;
            option.title = model.description || model.id;
            geoAiModel.appendChild(option);
        });
        populateGeoAiWorkflows();
        setGeoAiControlsEnabled(true);
    }

    function loadGeoAiOptions() {
        var optionsUrl = geoAiConfig().optionsUrl;
        if (!geoAiTools || !config.tools.geoaiRequests) {
            return;
        }
        if (!optionsUrl || !window.fetch) {
            populateGeoAiModels([], []);
            setGeoAiStatus('GeoAI unavailable', true);
            return;
        }

        setGeoAiControlsEnabled(false);
        setGeoAiStatus('Loading models...');
        geoAiFetch(optionsUrl)
            .then(function (payload) {
                populateGeoAiModels(payload.models || [], payload.workflows || []);
                setGeoAiStatus(geoAiModels.length ? 'Ready' : 'No models returned', !geoAiModels.length);
            })
            .catch(function (error) {
                populateGeoAiModels([], []);
                setGeoAiStatus(error.message || 'GeoAI unavailable', true);
            });
    }

    function drawnGeoJson() {
        if (!draw || typeof draw.getAll !== 'function') {
            return null;
        }
        try {
            var featureCollection = draw.getAll();
            var features = featureCollection && featureCollection.features
                ? featureCollection.features.filter(function (feature) {
                    var type = feature && feature.geometry && feature.geometry.type;
                    return type === 'Polygon' || type === 'MultiPolygon';
                })
                : [];
            return features.length
                ? { type: 'FeatureCollection', features: features }
                : null;
        } catch (error) {
            return null;
        }
    }

    function mapBoundsArray() {
        var bounds = map.getBounds();
        return [
            bounds.getWest(),
            bounds.getSouth(),
            bounds.getEast(),
            bounds.getNorth()
        ];
    }

    function extendGeoJsonBounds(coords, bounds) {
        if (!Array.isArray(coords)) {
            return bounds;
        }
        if (coords.length >= 2 && typeof coords[0] === 'number' && typeof coords[1] === 'number') {
            bounds[0] = Math.min(bounds[0], coords[0]);
            bounds[1] = Math.min(bounds[1], coords[1]);
            bounds[2] = Math.max(bounds[2], coords[0]);
            bounds[3] = Math.max(bounds[3], coords[1]);
            return bounds;
        }
        coords.forEach(function (child) {
            extendGeoJsonBounds(child, bounds);
        });
        return bounds;
    }

    function geoJsonBounds(geojson) {
        var bounds = [Infinity, Infinity, -Infinity, -Infinity];
        (geojson.features || []).forEach(function (feature) {
            if (feature.geometry) {
                extendGeoJsonBounds(feature.geometry.coordinates, bounds);
            }
        });
        return Number.isFinite(bounds[0]) ? bounds : null;
    }

    function geoAiMapContext() {
        var center = map.getCenter();
        var aoi = drawnGeoJson();
        var aoiBounds = aoi ? geoJsonBounds(aoi) : null;
        var context = {
            source_app: 'geospatial-status-board',
            bbox: aoiBounds || mapBoundsArray(),
            area_source: aoiBounds ? 'drawn_aoi' : 'map_view',
            map_center: [center.lng, center.lat],
            zoom: Number(map.getZoom().toFixed(2)),
            selected_layer: config.selectedLayer || ''
        };
        if (aoi) {
            context.aoi_geojson = aoi;
        }
        return context;
    }

    function formatGeoAiExtent() {
        var aoi = drawnGeoJson();
        var bounds = aoi ? geoJsonBounds(aoi) : null;
        if (!bounds) {
            bounds = mapBoundsArray();
            aoi = null;
        }
        var prefix = aoi ? 'Drawn AOI' : 'Map view';
        return prefix + ': ' +
            bounds[0].toFixed(3) + ', ' +
            bounds[1].toFixed(3) + ' / ' +
            bounds[2].toFixed(3) + ', ' +
            bounds[3].toFixed(3);
    }

    function updateGeoAiExtent() {
        if (geoAiExtent && map) {
            geoAiExtent.textContent = formatGeoAiExtent();
        }
    }

    function shortRunId(value) {
        return String(value || '').slice(0, 8);
    }

    function geoAiRunError(run) {
        if (run.error) {
            return run.error;
        }
        var failedResult = (run.results || []).find(function (result) {
            return result && result.error;
        });
        return failedResult ? failedResult.error : '';
    }

    function postgisLoadCount(run) {
        return (run.results || []).reduce(function (total, result) {
            if (!result || result.status !== 'succeeded') {
                return total;
            }
            return total + (result.stages || []).reduce(function (stageTotal, stage) {
                if (!stage || stage.stage !== 'load-postgis') {
                    return stageTotal;
                }
                return stageTotal + Number(stage.count || 0);
            }, 0);
        }, 0);
    }

    function runAttemptedPostgisLoad(run) {
        return (run.results || []).some(function (result) {
            return result &&
                result.status === 'succeeded' &&
                (result.stages || []).some(function (stage) {
                    return stage && stage.stage === 'load-postgis';
                });
        });
    }

    function runLoadedPostgis(run) {
        return postgisLoadCount(run) > 0;
    }

    function refreshDetectedRoadsAfterRun(run) {
        var key = 'detectedRoads';
        if (!runLoadedPostgis(run) || !(config.layers || {})[key]) {
            return false;
        }
        layerFilters[key] = run.id || '';
        rememberGeoAiJobFromRun(run);
        loadGeoAiJobs();

        var filter = layerFilterSelect(key);
        if (filter) {
            filter.value = layerFilters[key];
        }

        var checkbox = document.querySelector('[data-layer-kind="internal"][data-layer-key="' + key + '"]');
        if (checkbox) {
            checkbox.checked = true;
        }
        if (internalLayerState[key] && internalLayerState[key].loaded) {
            removeInternalLayer(key);
        }
        loadInternalLayer(key);
        return true;
    }

    function pollGeoAiRun(runId) {
        var statusUrl = (geoAiConfig().runStatusUrlBase || '') + encodeURIComponent(runId);
        if (!statusUrl) {
            return;
        }

        if (geoAiPollTimer) {
            window.clearTimeout(geoAiPollTimer);
            geoAiPollTimer = null;
        }

        geoAiFetch(statusUrl).then(function (run) {
            var status = run.status || 'unknown';
            var terminal = ['succeeded', 'failed', 'cancelled', 'canceled'].indexOf(status) >= 0;
            var message = 'Run ' + shortRunId(run.id || runId) + ': ' + status;
            var errorMessage = geoAiRunError(run);
            if (errorMessage) {
                message += ' - ' + errorMessage;
            }
            setGeoAiStatus(message, status === 'failed');
            if (status === 'failed') {
                setStatus('GeoAI run failed: ' + (errorMessage || shortRunId(run.id || runId)), true);
            } else if (status === 'succeeded') {
                if (refreshDetectedRoadsAfterRun(run)) {
                    setStatus('GeoAI run succeeded; refreshing GeoAI Detections for job ' + shortRunId(run.id || runId));
                } else if (runAttemptedPostgisLoad(run)) {
                    setStatus('GeoAI run succeeded but did not load features for this area: ' + shortRunId(run.id || runId));
                } else {
                    setStatus('GeoAI run succeeded: ' + shortRunId(run.id || runId));
                }
            }
            if (!terminal) {
                geoAiPollTimer = window.setTimeout(function () {
                    pollGeoAiRun(runId);
                }, 3000);
            } else {
                geoAiRunActive = false;
                setGeoAiControlsEnabled(!!geoAiModels.length);
            }
        }).catch(function (error) {
            geoAiRunActive = false;
            setGeoAiControlsEnabled(!!geoAiModels.length);
            setGeoAiStatus(error.message || 'GeoAI status unavailable', true);
        });
    }

    function submitGeoAiRun(event) {
        if (event) {
            event.preventDefault();
        }
        if (!geoAiModel || !geoAiModel.value) {
            setGeoAiStatus('Select a model', true);
            return;
        }
        if (!geoAiWorkflow || !geoAiWorkflow.value) {
            setGeoAiStatus('Select a workflow', true);
            return;
        }

        var payload = {
            request_source: 'external_app',
            submitted_by: 'geospatial-status-board',
            model_id: geoAiModel.value,
            workflow_ids: [geoAiWorkflow.value],
            map_context: geoAiMapContext(),
            notes: 'Submitted from Map View'
        };

        geoAiRunActive = true;
        setGeoAiControlsEnabled(false);
        setGeoAiStatus('Submitting...');
        geoAiFetch(geoAiConfig().runsUrl, {
            method: 'POST',
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(payload)
        }).then(function (run) {
            geoAiCurrentRunId = run.id;
            setStatus('GeoAI run queued: ' + shortRunId(run.id));
            setGeoAiStatus('Queued: ' + shortRunId(run.id));
            pollGeoAiRun(run.id);
        }).catch(function (error) {
            geoAiRunActive = false;
            setGeoAiStatus(error.message || 'GeoAI request failed', true);
            setStatus(error.message || 'GeoAI request failed', true);
        }).finally(function () {
            setGeoAiControlsEnabled(!!geoAiModels.length);
        });
    }

    function configuredZoomLevels() {
        var rawLevels = Array.isArray(config.zoomLevels) ? config.zoomLevels : [];
        var levels = rawLevels.map(function (level) {
            return Number(level);
        }).filter(function (level) {
            return Number.isFinite(level);
        }).sort(function (a, b) {
            return a - b;
        });

        if (!levels.length) {
            for (var level = 3; level <= 18; level++) {
                levels.push(level);
            }
        }
        return levels.filter(function (level, index) {
            return index === 0 || level !== levels[index - 1];
        });
    }

    function zoomLabel(level) {
        return Number.isInteger(level) ? String(level) : level.toFixed(1);
    }

    var zoomLevels = configuredZoomLevels();

    function closestZoomLevel(value) {
        return zoomLevels.reduce(function (closest, level) {
            return Math.abs(level - value) < Math.abs(closest - value) ? level : closest;
        }, zoomLevels[0]);
    }

    function populateZoomLevels() {
        if (!zoomLevelSelect) {
            return;
        }
        zoomLevelSelect.innerHTML = '';
        zoomLevels.forEach(function (level) {
            var option = document.createElement('option');
            option.value = String(level);
            option.textContent = zoomLabel(level);
            zoomLevelSelect.appendChild(option);
        });
    }

    function updateZoomLevelControl() {
        if (!zoomLevelSelect || !zoomLevels.length) {
            return;
        }
        var currentZoom = map.getZoom();
        var selected = closestZoomLevel(currentZoom);
        zoomLevelSelect.value = String(selected);
        if (zoomInButton) {
            zoomInButton.disabled = currentZoom >= zoomLevels[zoomLevels.length - 1] - 0.01;
        }
        if (zoomOutButton) {
            zoomOutButton.disabled = currentZoom <= zoomLevels[0] + 0.01;
        }
    }

    function stepZoom(direction) {
        var currentZoom = map.getZoom();
        var target = direction > 0
            ? zoomLevels.find(function (level) { return level > currentZoom + 0.01; })
            : zoomLevels.slice().reverse().find(function (level) { return level < currentZoom - 0.01; });

        if (target == null) {
            target = closestZoomLevel(currentZoom);
        }
        map.easeTo({ zoom: target });
    }

    function updateNorthArrow() {
        if (northArrowIndicator) {
            northArrowIndicator.style.transform = 'rotate(' + (-map.getBearing()) + 'deg)';
        }
    }

    function layerIdsFor(key) {
        var suffix = safeId(key);
        return ['status-fill-' + suffix, 'status-line-' + suffix, 'status-point-' + suffix];
    }

    function externalSourceIdFor(key) {
        return 'external-source-' + safeId(key);
    }

    function externalLayerIdFor(key) {
        return 'external-layer-' + safeId(key);
    }

    function externalLayerIdsFor(key) {
        var base = externalLayerIdFor(key);
        return [base, base + '-fill', base + '-line', base + '-point'];
    }

    function selectedBasemap() {
        return (config.basemaps || {})[activeBasemapKey] || (config.basemaps || {})[firstKey(config.basemaps)] || {};
    }

    function rasterStyle() {
        var basemap = selectedBasemap();
        var layers = [
            {
                id: backgroundLayerId,
                type: 'background',
                paint: {
                    'background-color': basemap.background || '#183d66'
                }
            }
        ];
        var sources = {};

        if (basemap.tilesUrl) {
            sources[basemapSourceId] = {
                type: 'raster',
                tiles: [basemap.tilesUrl],
                tileSize: 256,
                attribution: basemap.attribution || ''
            };
            layers.push({
                id: basemapLayerId,
                type: 'raster',
                source: basemapSourceId,
                paint: {
                    'raster-opacity': Number(basemap.opacity == null ? 1 : basemap.opacity)
                }
            });
        }

        return {
            version: 8,
            sources: sources,
            layers: layers
        };
    }

    function allInternalRenderLayerIds() {
        return Object.keys(internalLayerState).reduce(function (ids, key) {
            var state = internalLayerState[key];
            if (state && state.loaded) {
                return ids.concat(layerIdsFor(key).filter(function (id) { return map.getLayer(id); }));
            }
            return ids;
        }, []);
    }

    function allExternalRenderLayerIds() {
        return Object.keys(externalLayerState).reduce(function (ids, key) {
            var state = externalLayerState[key];
            if (state && state.loaded) {
                return ids.concat(externalLayerIdsFor(key).filter(function (id) { return map.getLayer(id); }));
            }
            return ids;
        }, []);
    }

    function firstOperationalLayerId() {
        var internalId = allInternalRenderLayerIds().find(function (id) { return map.getLayer(id); });
        if (internalId) {
            return internalId;
        }
        return measureLayerIds.find(function (id) { return map.getLayer(id); });
    }

    function firstMeasureLayerId() {
        return measureLayerIds.find(function (id) { return map.getLayer(id); });
    }

    function applyBasemap(key) {
        if (key && config.basemaps && config.basemaps[key]) {
            activeBasemapKey = key;
        }
        var basemap = selectedBasemap();
        if (map.getLayer(basemapLayerId)) {
            map.removeLayer(basemapLayerId);
        }
        if (map.getSource(basemapSourceId)) {
            map.removeSource(basemapSourceId);
        }
        if (map.getLayer(backgroundLayerId)) {
            map.setPaintProperty(backgroundLayerId, 'background-color', basemap.background || '#183d66');
        }
        if (basemap.tilesUrl) {
            map.addSource(basemapSourceId, {
                type: 'raster',
                tiles: [basemap.tilesUrl],
                tileSize: 256,
                attribution: basemap.attribution || ''
            });
            map.addLayer({
                id: basemapLayerId,
                type: 'raster',
                source: basemapSourceId,
                paint: {
                    'raster-opacity': Number(basemap.opacity == null ? 1 : basemap.opacity)
                }
            }, firstOperationalLayerId());
        }
        updateBasemapCards();
    }

    function updateBasemapCards() {
        var basemap = selectedBasemap();
        if (basemapToggle) {
            basemapToggle.style.setProperty('--basemap-preview', basemap.preview || basemap.background || '#183d66');
            if (basemap.previewImage) {
                basemapToggle.style.setProperty('--basemap-preview-image', cssUrl(basemap.previewImage));
            } else {
                basemapToggle.style.removeProperty('--basemap-preview-image');
            }
        }
        if (basemapToggleLabel) {
            basemapToggleLabel.textContent = basemap.buttonLabel || basemap.title || 'Basemap';
        }
        Array.prototype.forEach.call(document.querySelectorAll('.geo-basemap-card'), function (card) {
            var key = card.getAttribute('data-basemap-key');
            var cardBasemap = (config.basemaps || {})[key] || {};
            if (cardBasemap.previewImage) {
                card.style.setProperty('--basemap-preview-image', cssUrl(cardBasemap.previewImage));
            } else {
                card.style.removeProperty('--basemap-preview-image');
            }
            card.classList.toggle('is-active', key === activeBasemapKey);
        });
    }

    function cqlEquals(field, value) {
        return field + "='" + String(value).replace(/'/g, "''") + "'";
    }

    function buildWfsUrl(key, layer) {
        var url = new URL(config.wfsUrl, window.location.origin);
        url.searchParams.set('service', 'WFS');
        url.searchParams.set('version', '1.0.0');
        url.searchParams.set('request', 'GetFeature');
        url.searchParams.set('typeName', layer.typeName);
        url.searchParams.set('outputFormat', 'application/json');
        url.searchParams.set('srsName', config.defaultSrs || 'EPSG:4326');
        url.searchParams.set('maxFeatures', layer.maxFeatures || config.maxFeatures || 500);

        if (layer.filterField && layerFilterValue(key)) {
            url.searchParams.set('CQL_FILTER', cqlEquals(layer.filterField, layerFilterValue(key)));
        } else if (config.selectedLayer === key && config.filter && config.filter.field && config.filter.value) {
            url.searchParams.set('CQL_FILTER', cqlEquals(config.filter.field, config.filter.value));
        }

        return url.toString();
    }

    function fetchWfsJson(key, layer) {
        var timeoutMs = Number(config.requestTimeoutMs || 5000);
        var requestOptions = { credentials: 'same-origin' };
        var timeoutId = null;

        if (window.AbortController && timeoutMs > 0) {
            var controller = new AbortController();
            requestOptions.signal = controller.signal;
            timeoutId = window.setTimeout(function () {
                controller.abort();
            }, timeoutMs);
        }

        return fetch(buildWfsUrl(key, layer), requestOptions)
            .then(function (response) {
                if (!response.ok) {
                    throw new Error('GeoServer returned HTTP ' + response.status);
                }
                return response.json();
            })
            .catch(function (error) {
                if (error && error.name === 'AbortError') {
                    throw new Error('GeoServer did not respond within ' + timeoutMs + ' ms');
                }
                if (error instanceof TypeError) {
                    throw new Error('GeoServer is unavailable or blocked by CORS');
                }
                throw error;
            })
            .finally(function () {
                if (timeoutId) {
                    window.clearTimeout(timeoutId);
                }
            });
    }

    function escapeHtml(value) {
        return String(value == null ? '' : value)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#039;');
    }

    function popupLabel(key) {
        return String(key || '')
            .replace(/_/g, ' ')
            .replace(/([a-z0-9])([A-Z])/g, '$1 $2')
            .toUpperCase();
    }

    function popupValue(value) {
        return value == null || value === '' ? 'N/A' : value;
    }

    function popupHtml(feature, layer) {
        var properties = feature.properties || {};
        var title = properties[layer.labelField] || properties[layer.idField] || layer.title;
        var popupKeys = (layer.popupFields && layer.popupFields.length ? layer.popupFields : Object.keys(properties));
        var rows = popupKeys.filter(function (key) {
            return key.indexOf('__') !== 0;
        }).slice(0, 12).map(function (key) {
            return '<dt>' + escapeHtml(popupLabel(key)) + '</dt><dd>' + escapeHtml(popupValue(properties[key])) + '</dd>';
        }).join('');

        return '<div class="geo-map-popup-title">' + escapeHtml(title) + '</div><dl class="geo-map-popup">' + rows + '</dl>';
    }

    function placeSearchConfig() {
        return config.placeSearch || {};
    }

    function placeSearchLimit() {
        return Math.max(1, Math.min(Number(placeSearchConfig().resultLimit || 5), 10));
    }

    function placeSearchRadius() {
        return Math.max(100, Math.min(Number(placeSearchConfig().wikipediaRadiusMeters || 10000), 10000));
    }

    function wikipediaTitleUrl(title) {
        return 'https://en.wikipedia.org/wiki/' + encodeURIComponent(String(title || '').replace(/\s+/g, '_'));
    }

    function wikipediaGeoSearchUrl(lngLat) {
        var url = new URL('https://en.wikipedia.org/w/api.php');
        url.searchParams.set('action', 'query');
        url.searchParams.set('list', 'geosearch');
        url.searchParams.set('gscoord', lngLat.lat + '|' + lngLat.lng);
        url.searchParams.set('gsradius', String(placeSearchRadius()));
        url.searchParams.set('gslimit', String(placeSearchLimit()));
        url.searchParams.set('format', 'json');
        url.searchParams.set('origin', '*');
        return url.toString();
    }

    function geonamesWikipediaUrl(lngLat) {
        var username = String(placeSearchConfig().geonamesUsername || '').trim();
        if (!username) {
            return '';
        }
        var url = new URL('https://secure.geonames.org/findNearbyWikipediaJSON');
        url.searchParams.set('lat', lngLat.lat);
        url.searchParams.set('lng', lngLat.lng);
        url.searchParams.set('maxRows', String(placeSearchLimit()));
        url.searchParams.set('username', username);
        return url.toString();
    }

    function normalizeWikipediaResults(payload) {
        return (((payload || {}).query || {}).geosearch || []).map(function (entry) {
            return {
                title: entry.title,
                summary: '',
                distance: entry.dist != null ? Number(entry.dist) : null,
                url: wikipediaTitleUrl(entry.title)
            };
        });
    }

    function normalizeGeoNamesResults(payload) {
        return ((payload || {}).geonames || []).map(function (entry) {
            return {
                title: entry.title || entry.name,
                summary: entry.summary || '',
                distance: entry.distance != null ? Number(entry.distance) * 1000 : null,
                url: entry.wikipediaUrl ? 'https://' + String(entry.wikipediaUrl).replace(/^https?:\/\//, '') : wikipediaTitleUrl(entry.title || entry.name)
            };
        });
    }

    function fetchJson(url) {
        return fetch(url, { credentials: 'omit' }).then(function (response) {
            if (!response.ok) {
                throw new Error('Search returned HTTP ' + response.status);
            }
            return response.json();
        });
    }

    function fetchPlaceResults(lngLat) {
        var geonamesUrl = geonamesWikipediaUrl(lngLat);
        if (geonamesUrl) {
            return fetchJson(geonamesUrl)
                .then(function (payload) {
                    var results = normalizeGeoNamesResults(payload);
                    if (results.length) {
                        return { source: 'GeoNames Wikipedia', results: results };
                    }
                    throw new Error('GeoNames returned no nearby Wikipedia places');
                })
                .catch(function () {
                    return fetchJson(wikipediaGeoSearchUrl(lngLat)).then(function (payload) {
                        return { source: 'Wikipedia GeoSearch', results: normalizeWikipediaResults(payload) };
                    });
                });
        }

        return fetchJson(wikipediaGeoSearchUrl(lngLat)).then(function (payload) {
            return { source: 'Wikipedia GeoSearch', results: normalizeWikipediaResults(payload) };
        });
    }

    function formatPlaceDistance(meters) {
        if (meters == null || Number.isNaN(meters)) {
            return '';
        }
        if (meters >= 1609.344) {
            return (meters / 1609.344).toFixed(1) + ' mi';
        }
        return Math.round(meters) + ' m';
    }

    function placeSearchPopupHtml(payload, lngLat) {
        var results = (payload.results || []).slice(0, placeSearchLimit());
        if (!results.length) {
            return '<div class="geo-map-popup-title">Nearby Places</div><p class="geo-place-search-empty">No nearby Wikipedia places found.</p>';
        }

        var items = results.map(function (result) {
            var distance = formatPlaceDistance(result.distance);
            return '<li><a href="' + escapeHtml(result.url) + '" target="_blank" rel="noopener">' +
                escapeHtml(result.title || 'Untitled place') + '</a>' +
                (distance ? '<span>' + escapeHtml(distance) + '</span>' : '') +
                (result.summary ? '<p>' + escapeHtml(result.summary) + '</p>' : '') +
                '</li>';
        }).join('');

        return '<div class="geo-map-popup-title">Nearby Places</div>' +
            '<div class="geo-place-search-meta">' + escapeHtml(payload.source || 'Wikipedia') +
            ' near ' + lngLat.lat.toFixed(5) + ', ' + lngLat.lng.toFixed(5) + '</div>' +
            '<ol class="geo-place-search-results">' + items + '</ol>';
    }

    function setPlaceSearchMode(active) {
        placeSearchMode = !!active;
        if (placeSearchToggle) {
            placeSearchToggle.classList.toggle('is-active', placeSearchMode);
            placeSearchToggle.setAttribute('aria-pressed', placeSearchMode ? 'true' : 'false');
        }
        if (placeSearchMode) {
            setMeasureMode(false);
            setIncidentCreateMode(false);
            setGeoAiPanelOpen(false);
            map.getCanvas().style.cursor = 'help';
            setStatus('Wikipedia search ready. Click a map location to show nearby places.');
        } else if (map) {
            map.getCanvas().style.cursor = '';
        }
    }

    function showPlaceSearchPopup(lngLat) {
        var popup = new maplibregl.Popup({
            className: 'geo-map-feature-popup geo-place-search-popup',
            maxWidth: '390px'
        })
            .setLngLat(lngLat)
            .setHTML('<div class="geo-map-popup-title">Nearby Places</div><p class="geo-place-search-empty">Searching...</p>')
            .addTo(map);

        fetchPlaceResults(lngLat)
            .then(function (payload) {
                popup.setHTML(placeSearchPopupHtml(payload, lngLat));
                setStatus('Nearby place search complete.');
            })
            .catch(function (error) {
                popup.setHTML('<div class="geo-map-popup-title">Nearby Places</div><p class="geo-place-search-empty">' + escapeHtml(error.message || 'Search failed') + '</p>');
                setStatus('Nearby place search failed: ' + (error.message || 'Search failed'), true);
            });
    }

    function extendBounds(bounds, coordinates, count) {
        if (!coordinates) {
            return count;
        }
        if (typeof coordinates[0] === 'number') {
            bounds.extend(coordinates);
            return count + 1;
        }
        coordinates.forEach(function (entry) {
            count = extendBounds(bounds, entry, count);
        });
        return count;
    }

    function toRadians(value) {
        return value * Math.PI / 180;
    }

    function segmentMeters(a, b) {
        var radius = 6371008.8;
        var lat1 = toRadians(a[1]);
        var lat2 = toRadians(b[1]);
        var deltaLat = toRadians(b[1] - a[1]);
        var deltaLng = toRadians(b[0] - a[0]);
        var h = Math.sin(deltaLat / 2) * Math.sin(deltaLat / 2) +
            Math.cos(lat1) * Math.cos(lat2) * Math.sin(deltaLng / 2) * Math.sin(deltaLng / 2);
        return radius * 2 * Math.atan2(Math.sqrt(h), Math.sqrt(1 - h));
    }

    function lineMeters(coordinates) {
        var total = 0;
        for (var index = 1; index < coordinates.length; index++) {
            total += segmentMeters(coordinates[index - 1], coordinates[index]);
        }
        return total;
    }

    function polygonAreaSqMeters(ring) {
        if (!ring || ring.length < 4) {
            return 0;
        }
        var radius = 6378137;
        var area = 0;
        for (var index = 0; index < ring.length - 1; index++) {
            var current = ring[index];
            var next = ring[index + 1];
            area += toRadians(next[0] - current[0]) *
                (2 + Math.sin(toRadians(current[1])) + Math.sin(toRadians(next[1])));
        }
        return Math.abs(area * radius * radius / 2);
    }

    function featureLengthMeters(feature) {
        var geometry = feature.geometry || {};
        if (geometry.type === 'LineString') {
            return lineMeters(geometry.coordinates || []);
        }
        if (geometry.type === 'MultiLineString') {
            return (geometry.coordinates || []).reduce(function (sum, line) {
                return sum + lineMeters(line);
            }, 0);
        }
        if (geometry.type === 'Polygon') {
            return lineMeters((geometry.coordinates || [[]])[0] || []);
        }
        if (geometry.type === 'MultiPolygon') {
            return (geometry.coordinates || []).reduce(function (sum, polygon) {
                return sum + lineMeters((polygon || [[]])[0] || []);
            }, 0);
        }
        return 0;
    }

    function featureAreaSqMeters(feature) {
        var geometry = feature.geometry || {};
        if (geometry.type === 'Polygon') {
            return polygonAreaSqMeters((geometry.coordinates || [[]])[0] || []);
        }
        if (geometry.type === 'MultiPolygon') {
            return (geometry.coordinates || []).reduce(function (sum, polygon) {
                return sum + polygonAreaSqMeters((polygon || [[]])[0] || []);
            }, 0);
        }
        return 0;
    }

    function formatDistance(meters) {
        if (!meters) {
            return '0 mi';
        }
        var miles = meters / 1609.344;
        var nauticalMiles = meters / 1852;
        var kilometers = meters / 1000;
        if (miles < 0.1) {
            return Math.round(meters * 3.28084) + ' ft';
        }
        return miles.toFixed(2) + ' mi / ' + nauticalMiles.toFixed(2) + ' NM / ' + kilometers.toFixed(2) + ' km';
    }

    function formatArea(squareMeters) {
        if (!squareMeters) {
            return '0 ac';
        }
        var acres = squareMeters / 4046.8564224;
        if (acres < 640) {
            return acres.toFixed(1) + ' ac';
        }
        return (acres / 640).toFixed(2) + ' sq mi';
    }

    function emptyFeatureCollection() {
        return {
            type: 'FeatureCollection',
            features: []
        };
    }

    function ensureMeasureLayers() {
        if (!map.getSource(measureSourceId)) {
            map.addSource(measureSourceId, {
                type: 'geojson',
                data: emptyFeatureCollection()
            });
        }
        if (!map.getLayer('measure-line')) {
            map.addLayer({
                id: 'measure-line',
                type: 'line',
                source: measureSourceId,
                filter: ['==', '$type', 'LineString'],
                paint: {
                    'line-color': '#7dd3fc',
                    'line-width': 3,
                    'line-dasharray': ['literal', [2, 1]]
                }
            });
        }
        if (!map.getLayer('measure-points')) {
            map.addLayer({
                id: 'measure-points',
                type: 'circle',
                source: measureSourceId,
                filter: ['==', '$type', 'Point'],
                paint: {
                    'circle-color': '#38bdf8',
                    'circle-radius': 5,
                    'circle-stroke-color': '#e0f2fe',
                    'circle-stroke-width': 2
                }
            });
        }
    }

    function updateMeasureGraphics() {
        ensureMeasureLayers();
        var features = measurePoints.map(function (point) {
            return {
                type: 'Feature',
                geometry: {
                    type: 'Point',
                    coordinates: point
                },
                properties: {}
            };
        });
        if (measurePoints.length > 1) {
            features.push({
                type: 'Feature',
                geometry: {
                    type: 'LineString',
                    coordinates: measurePoints
                },
                properties: {}
            });
        }
        map.getSource(measureSourceId).setData({
            type: 'FeatureCollection',
            features: features
        });
        measureOutput.textContent = formatDistance(lineMeters(measurePoints));
    }

    function clearMeasure() {
        measurePoints = [];
        updateMeasureGraphics();
    }

    function setMeasureMode(enabled) {
        measureMode = enabled;
        if (measureMode && placeSearchMode) {
            setPlaceSearchMode(false);
        }
        if (measureMode && incidentCreateMode) {
            incidentCreateMode = false;
            if (incidentCreateToggle) {
                incidentCreateToggle.classList.remove('is-active');
                incidentCreateToggle.setAttribute('aria-pressed', 'false');
            }
            setIncidentPanelOpen(false);
            clearIncidentDraft();
        }
        measureToggle.classList.toggle('is-active', measureMode);
        measureToggle.setAttribute('aria-pressed', measureMode ? 'true' : 'false');
        measureToggle.setAttribute('aria-expanded', measureMode ? 'true' : 'false');
        measureToggle.title = measureMode ? 'Stop measuring' : 'Measure distance';
        if (measurePanel) {
            measurePanel.hidden = !measureMode;
        }
        map.getCanvas().style.cursor = measureMode ? 'crosshair' : '';
    }

    function dmsPart(value, positiveSuffix, negativeSuffix) {
        var suffix = value >= 0 ? positiveSuffix : negativeSuffix;
        var absolute = Math.abs(value);
        var degrees = Math.floor(absolute);
        var minutesFloat = (absolute - degrees) * 60;
        var minutes = Math.floor(minutesFloat);
        var seconds = (minutesFloat - minutes) * 60;
        return degrees + ' ' + minutes + ' ' + seconds.toFixed(2) + ' ' + suffix;
    }

    function formatCoordinate(lngLat) {
        var digits = Number(config.coordinateDigits || 6);
        var lat = lngLat.lat.toFixed(digits);
        var lng = lngLat.lng.toFixed(digits);
        var mgrsValue = 'Unavailable';
        if (config.tools.mgrs && window.mgrs && typeof window.mgrs.forward === 'function') {
            mgrsValue = window.mgrs.forward([lngLat.lng, lngLat.lat], Number(config.mgrsAccuracy || 5));
        }
        return {
            latLon: lat + ', ' + lng,
            dms: dmsPart(lngLat.lat, 'N', 'S') + ', ' + dmsPart(lngLat.lng, 'E', 'W'),
            mgrs: mgrsValue
        };
    }

    function updateCoordinateReadout(lngLat) {
        hoverCoordinate = lngLat;
        coordinateOutput.textContent = formatCoordinate(lngLat)[coordinateFormat.value] || '';
    }

    function flashCoordinateCopied() {
        coordinatePanel.classList.add('is-copied');
        window.setTimeout(function () {
            coordinatePanel.classList.remove('is-copied');
        }, 850);
    }

    function copyCoordinateAt(lngLat) {
        var value = formatCoordinate(lngLat)[coordinateFormat.value] || '';
        if (!value) {
            return;
        }
        coordinateOutput.textContent = value;
        if (navigator.clipboard && navigator.clipboard.writeText) {
            navigator.clipboard.writeText(value).then(flashCoordinateCopied).catch(function () {
                setStatus('Clipboard is not available for this browser session.', true);
            });
        }
    }

    function setCoordinateCopyMode(enabled) {
        if (!coordinatePanel || !coordinateClickCopy) {
            return;
        }
        coordinateClickCopy.checked = enabled;
        coordinatePanel.classList.toggle('is-copy-enabled', enabled);
    }

    function populateIncidentDatalist(id, values) {
        var list = document.getElementById(id);
        if (!list) {
            return;
        }
        list.innerHTML = '';
        (values || []).forEach(function (value) {
            var option = document.createElement('option');
            option.value = value;
            list.appendChild(option);
        });
    }

    function populateIncidentLookups() {
        populateIncidentDatalist('geo-incident-event-type-options', incidentLookupOptions.eventTypes);
        populateIncidentDatalist('geo-incident-event-cat-options', incidentLookupOptions.eventCategories);
        populateIncidentDatalist('geo-incident-base-options', incidentLookupOptions.bases);
        populateIncidentDatalist('geo-incident-source-options', incidentLookupOptions.sources);
        populateIncidentDatalist('geo-incident-yes-no-options', incidentLookupOptions.yesNoNa);
    }

    function incidentIconIdFor(eventType) {
        var value = String(eventType || '').toLowerCase();
        if (value.indexOf('weather') !== -1) {
            return 'incident-weather';
        }
        if (value.indexOf('aircraft') !== -1 || value.indexOf('mishap') !== -1) {
            return 'incident-aircraft';
        }
        if (value.indexOf('airfield') !== -1 || value.indexOf('runway') !== -1) {
            return 'incident-airfield';
        }
        if (value.indexOf('facility') !== -1 || value.indexOf('damage') !== -1) {
            return 'incident-facility';
        }
        if (value.indexOf('utility') !== -1 || value.indexOf('power') !== -1 || value.indexOf('energy') !== -1) {
            return 'incident-utility';
        }
        if (value.indexOf('security') !== -1 || value.indexOf('force') !== -1) {
            return 'incident-security';
        }
        return 'incident-default';
    }

    function propertyValue(properties, names) {
        for (var i = 0; i < names.length; i += 1) {
            if (properties[names[i]] != null && properties[names[i]] !== '') {
                return properties[names[i]];
            }
        }
        return '';
    }

    function incidentEventTypeForFeature(feature, layer) {
        var properties = feature.properties || {};
        var iconField = layer && layer.iconField ? layer.iconField : '';
        return propertyValue(properties, [
            iconField,
            'event_type',
            'eventType',
            'EVENT_TYPE',
            'eventtype'
        ]);
    }

    function drawIncidentGlyph(ctx, id, color) {
        ctx.save();
        ctx.lineCap = 'round';
        ctx.lineJoin = 'round';
        ctx.strokeStyle = '#ffffff';
        ctx.fillStyle = '#ffffff';
        ctx.lineWidth = 4;

        if (id === 'incident-weather') {
            ctx.beginPath();
            ctx.arc(28, 33, 8, Math.PI, Math.PI * 2);
            ctx.arc(38, 30, 10, Math.PI, Math.PI * 2);
            ctx.arc(48, 34, 7, Math.PI, Math.PI * 2);
            ctx.lineTo(49, 42);
            ctx.lineTo(24, 42);
            ctx.closePath();
            ctx.fill();
            ctx.fillStyle = color;
            ctx.beginPath();
            ctx.moveTo(39, 42);
            ctx.lineTo(33, 54);
            ctx.lineTo(42, 50);
            ctx.lineTo(37, 60);
            ctx.lineTo(51, 45);
            ctx.closePath();
            ctx.fill();
        } else if (id === 'incident-aircraft') {
            ctx.beginPath();
            ctx.moveTo(36, 17);
            ctx.lineTo(42, 35);
            ctx.lineTo(57, 42);
            ctx.lineTo(57, 48);
            ctx.lineTo(42, 45);
            ctx.lineTo(38, 57);
            ctx.lineTo(34, 57);
            ctx.lineTo(30, 45);
            ctx.lineTo(15, 48);
            ctx.lineTo(15, 42);
            ctx.lineTo(30, 35);
            ctx.closePath();
            ctx.fill();
        } else if (id === 'incident-airfield') {
            ctx.fillRect(33, 17, 6, 42);
            ctx.fillRect(20, 34, 32, 5);
            ctx.fillRect(24, 48, 24, 4);
        } else if (id === 'incident-facility') {
            ctx.beginPath();
            ctx.moveTo(18, 34);
            ctx.lineTo(36, 20);
            ctx.lineTo(54, 34);
            ctx.lineTo(50, 39);
            ctx.lineTo(50, 56);
            ctx.lineTo(22, 56);
            ctx.lineTo(22, 39);
            ctx.closePath();
            ctx.fill();
            ctx.fillStyle = color;
            ctx.fillRect(32, 42, 8, 14);
        } else if (id === 'incident-utility') {
            ctx.beginPath();
            ctx.moveTo(40, 15);
            ctx.lineTo(24, 39);
            ctx.lineTo(36, 39);
            ctx.lineTo(30, 58);
            ctx.lineTo(50, 30);
            ctx.lineTo(38, 30);
            ctx.closePath();
            ctx.fill();
        } else if (id === 'incident-security') {
            ctx.beginPath();
            ctx.moveTo(36, 15);
            ctx.lineTo(54, 23);
            ctx.lineTo(51, 44);
            ctx.quadraticCurveTo(47, 55, 36, 60);
            ctx.quadraticCurveTo(25, 55, 21, 44);
            ctx.lineTo(18, 23);
            ctx.closePath();
            ctx.fill();
            ctx.fillStyle = color;
            ctx.fillRect(34, 28, 4, 20);
            ctx.fillRect(27, 35, 18, 4);
        } else {
            ctx.beginPath();
            ctx.moveTo(36, 17);
            ctx.lineTo(55, 55);
            ctx.lineTo(17, 55);
            ctx.closePath();
            ctx.fill();
            ctx.fillStyle = color;
            ctx.fillRect(34, 30, 4, 15);
            ctx.fillRect(34, 49, 4, 4);
        }
        ctx.restore();
    }

    function createIncidentIconImage(id, color, shape) {
        var canvas = document.createElement('canvas');
        var size = 72;
        canvas.width = size;
        canvas.height = size;
        var ctx = canvas.getContext('2d');
        ctx.clearRect(0, 0, size, size);
        ctx.shadowColor = 'rgba(15, 23, 42, 0.36)';
        ctx.shadowBlur = 8;
        ctx.shadowOffsetY = 4;
        ctx.fillStyle = color;
        ctx.strokeStyle = '#ffffff';
        ctx.lineWidth = 4;

        ctx.beginPath();
        if (shape === 'diamond') {
            ctx.moveTo(36, 4);
            ctx.lineTo(68, 36);
            ctx.lineTo(36, 68);
            ctx.lineTo(4, 36);
            ctx.closePath();
        } else {
            ctx.arc(36, 36, 30, 0, Math.PI * 2);
        }
        ctx.fill();
        ctx.shadowColor = 'transparent';
        ctx.stroke();
        drawIncidentGlyph(ctx, id, color);
        return ctx.getImageData(0, 0, size, size);
    }

    function addIncidentImage(id, color, shape) {
        if (map.hasImage && map.hasImage(id)) {
            return;
        }
        map.addImage(id, createIncidentIconImage(id, color, shape), { pixelRatio: 2 });
    }

    function registerIncidentIcons() {
        addIncidentImage('incident-default', '#b91c1c', 'diamond');
        addIncidentImage('incident-weather', '#2563eb', 'diamond');
        addIncidentImage('incident-airfield', '#d97706', 'diamond');
        addIncidentImage('incident-facility', '#9333ea', 'diamond');
        addIncidentImage('incident-utility', '#16a34a', 'diamond');
        addIncidentImage('incident-security', '#475569', 'diamond');
        addIncidentImage('incident-aircraft', '#dc2626', 'diamond');
        addIncidentImage('incident-draft', '#38bdf8', 'circle');
    }

    function emptyFeatureCollection() {
        return {
            type: 'FeatureCollection',
            features: []
        };
    }

    function ensureIncidentOverlayLayers() {
        if (!map.getSource(incidentDraftSourceId)) {
            map.addSource(incidentDraftSourceId, {
                type: 'geojson',
                data: emptyFeatureCollection()
            });
        }
        if (!map.getLayer(incidentDraftLayerId)) {
            map.addLayer({
                id: incidentDraftLayerId,
                type: 'symbol',
                source: incidentDraftSourceId,
                layout: {
                    'icon-image': 'incident-draft',
                    'icon-size': 0.54,
                    'icon-allow-overlap': true,
                    'icon-ignore-placement': true
                }
            }, firstMeasureLayerId());
        }
        if (!map.getSource(localIncidentSourceId)) {
            map.addSource(localIncidentSourceId, {
                type: 'geojson',
                data: emptyFeatureCollection()
            });
        }
        if (!map.getLayer(localIncidentLayerId)) {
            map.addLayer({
                id: localIncidentLayerId,
                type: 'symbol',
                source: localIncidentSourceId,
                layout: {
                    'icon-image': ['get', '__incidentIcon'],
                    'icon-size': 0.54,
                    'icon-allow-overlap': true,
                    'icon-ignore-placement': true
                }
            }, firstMeasureLayerId());
        }
    }

    function updateIncidentSource(sourceId, features) {
        var source = map.getSource(sourceId);
        if (source) {
            source.setData({
                type: 'FeatureCollection',
                features: features || []
            });
        }
    }

    function clearLocalCreatedIncidents() {
        localIncidentFeatures = [];
        updateIncidentSource(localIncidentSourceId, localIncidentFeatures);
    }

    function clearIncidentDraft() {
        incidentDraft = null;
        updateIncidentSource(incidentDraftSourceId, []);
    }

    function incidentFormElements() {
        return incidentCreateForm ? incidentCreateForm.elements : {};
    }

    function setIncidentFormValue(name, value) {
        var elements = incidentFormElements();
        if (elements[name]) {
            elements[name].value = value == null ? '' : value;
        }
    }

    function setIncidentCreateMode(enabled) {
        incidentCreateMode = !!enabled;
        if (incidentCreateToggle) {
            incidentCreateToggle.classList.toggle('is-active', incidentCreateMode);
            incidentCreateToggle.setAttribute('aria-pressed', incidentCreateMode ? 'true' : 'false');
        }
        if (map && map.getCanvas()) {
            map.getCanvas().classList.toggle('is-placing-incident', incidentCreateMode);
        }
        if (incidentCreateMode) {
            setPlaceSearchMode(false);
            setMeasureMode(false);
            setCoordinateCopyMode(false);
            setStatus('Click the map to place an incident.');
        }
    }

    function setIncidentPanelOpen(open) {
        if (incidentCreatePanel) {
            incidentCreatePanel.hidden = !open;
        }
    }

    function resetIncidentForm() {
        if (incidentCreateForm) {
            incidentCreateForm.reset();
        }
        setIncidentFormValue('sigEvent', 'No');
        setIncidentFormValue('airOpsAffected', 'No');
    }

    function incidentFeatureFromDraft(draft) {
        return {
            type: 'Feature',
            geometry: {
                type: 'Point',
                coordinates: [draft.longitude, draft.latitude]
            },
            properties: {
                __layerKey: 'currentIncidents',
                __incidentIcon: 'incident-draft'
            }
        };
    }

    function placeIncidentDraft(lngLat) {
        var digits = Number(config.coordinateDigits || 6);
        var formatted = formatCoordinate(lngLat);
        incidentDraft = {
            longitude: Number(lngLat.lng.toFixed(digits)),
            latitude: Number(lngLat.lat.toFixed(digits)),
            mgrsCoord: formatted.mgrs === 'Unavailable' ? '' : formatted.mgrs
        };
        resetIncidentForm();
        setIncidentFormValue('longitude', incidentDraft.longitude);
        setIncidentFormValue('latitude', incidentDraft.latitude);
        setIncidentFormValue('mgrsCoord', incidentDraft.mgrsCoord);
        updateIncidentSource(incidentDraftSourceId, [incidentFeatureFromDraft(incidentDraft)]);
        setIncidentPanelOpen(true);
        setIncidentCreateMode(false);
        setStatus('Incident location placed.');
    }

    function incidentPayloadFromForm() {
        var elements = incidentFormElements();
        return {
            incidentId: elements.incidentId ? elements.incidentId.value.trim() : '',
            eventType: elements.eventType ? elements.eventType.value.trim() : '',
            eventCat: elements.eventCat ? elements.eventCat.value.trim() : '',
            eventName: elements.eventName ? elements.eventName.value.trim() : '',
            eventDesc: elements.eventDesc ? elements.eventDesc.value.trim() : '',
            base: elements.base ? elements.base.value.trim() : '',
            sigEvent: elements.sigEvent ? elements.sigEvent.value.trim() : '',
            airOpsAffected: elements.airOpsAffected ? elements.airOpsAffected.value.trim() : '',
            source: elements.source ? elements.source.value.trim() : '',
            mgrsCoord: elements.mgrsCoord ? elements.mgrsCoord.value.trim() : '',
            longitude: elements.longitude ? elements.longitude.value.trim() : '',
            latitude: elements.latitude ? elements.latitude.value.trim() : ''
        };
    }

    function normalizeCreatedIncidentFeature(feature) {
        var properties = Object.assign({}, feature.properties || {});
        properties.__layerKey = 'currentIncidents';
        properties.__incidentIcon = incidentIconIdFor(propertyValue(properties, ['event_type', 'eventType']));
        return {
            type: 'Feature',
            geometry: feature.geometry,
            properties: properties
        };
    }

    function addLocalCreatedIncident(feature) {
        localIncidentFeatures.push(normalizeCreatedIncidentFeature(feature));
        updateIncidentSource(localIncidentSourceId, localIncidentFeatures);
    }

    function ensureCurrentIncidentsLayerRefresh() {
        var key = 'currentIncidents';
        var checkbox = document.querySelector('[data-layer-kind="internal"][data-layer-key="' + key + '"]');
        if (checkbox) {
            checkbox.checked = true;
        }
        if (config.layers && config.layers[key]) {
            if (internalLayerState[key] && internalLayerState[key].loaded) {
                removeInternalLayer(key);
            }
            loadInternalLayer(key);
        }
    }

    function saveIncidentDraft() {
        if (!incidentDraft || !incidentCreateForm) {
            setStatus('Place an incident on the map before saving.', true);
            return;
        }
        if (!incidentCreateForm.checkValidity()) {
            incidentCreateForm.reportValidity();
            return;
        }

        var payload = incidentPayloadFromForm();
        incidentSave.disabled = true;
        setStatus('Saving incident...');

        fetch(incidentCreateUrl, {
            method: 'POST',
            credentials: 'same-origin',
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(payload)
        }).then(function (response) {
            return response.json().then(function (body) {
                if (!response.ok) {
                    throw new Error(body.error || 'Incident could not be saved.');
                }
                return body;
            });
        }).then(function (body) {
            addLocalCreatedIncident(body.feature);
            clearIncidentDraft();
            setIncidentPanelOpen(false);
            setStatus('Incident ' + body.incident.incidentId + ' created.');
            ensureCurrentIncidentsLayerRefresh();
        }).catch(function (error) {
            setStatus(error.message, true);
        }).finally(function () {
            incidentSave.disabled = false;
        });
    }

    function decorateGeoJson(key, geojson) {
        return {
            type: 'FeatureCollection',
            features: (geojson.features || []).map(function (feature) {
                var clone = {
                    type: 'Feature',
                    geometry: feature.geometry,
                    properties: Object.assign({}, feature.properties || {})
                };
                if (feature.id != null && clone.properties.id == null) {
                    clone.properties.id = feature.id;
                }
                clone.properties.__layerKey = key;
                if ((config.layers[key] || {}).iconSet === 'femaIncident') {
                    clone.properties.__incidentIcon = incidentIconIdFor(incidentEventTypeForFeature(clone, config.layers[key]));
                }
                return clone;
            })
        };
    }

    function layerFilterSelect(key) {
        return document.querySelector('[data-layer-filter="' + key + '"]');
    }

    function layerFilterValue(key) {
        var select = layerFilterSelect(key);
        return select ? select.value : (layerFilters[key] || '');
    }

    function filteredLayerData(key, data) {
        var layer = config.layers[key] || {};
        var field = layer.filterField;
        var selected = layerFilterValue(key);
        if (!field || !selected) {
            return data;
        }
        return {
            type: 'FeatureCollection',
            features: (data.features || []).filter(function (feature) {
                var value = feature.properties ? feature.properties[field] : null;
                return String(value == null ? '' : value) === selected;
            })
        };
    }

    function layerFeatureStatus(data, rawData) {
        var count = (data && data.features ? data.features.length : 0);
        var total = (rawData && rawData.features ? rawData.features.length : count);
        if (total !== count) {
            return count + ' of ' + total + ' features';
        }
        return count + ' feature' + (count === 1 ? '' : 's');
    }

    function normalizeLayerFilterOption(option) {
        if (typeof option === 'string') {
            return {
                value: option,
                label: option,
                title: option
            };
        }
        return {
            value: String(option.value || ''),
            label: String(option.label || option.value || ''),
            title: String(option.title || option.value || '')
        };
    }

    function currentLayerFilterOptions(select) {
        if (!select) {
            return [];
        }
        return Array.prototype.slice.call(select.options || []).filter(function (option) {
            return option.value;
        }).map(function (option) {
            return {
                value: option.value,
                label: option.textContent || option.value,
                title: option.title || option.value
            };
        });
    }

    function rawLayerFilterOptions(key, rawData) {
        var layer = config.layers[key] || {};
        var field = layer.filterField;
        var values = [];
        (rawData.features || []).forEach(function (feature) {
            var rawValue = feature.properties ? feature.properties[field] : null;
            var value = String(rawValue == null ? '' : rawValue);
            if (value && values.indexOf(value) < 0) {
                values.push(value);
            }
        });
        return values.sort().map(normalizeLayerFilterOption);
    }

    function setLayerFilterOptions(key, options) {
        var layer = config.layers[key] || {};
        var select = layerFilterSelect(key);
        if (!layer.filterField || !select) {
            return;
        }

        var selected = layerFilters[key] || select.value || '';
        var seen = {};
        var normalized = mergeLayerFilterOptions(options || [], currentLayerFilterOptions(select)).filter(function (option) {
            if (!option.value || seen[option.value]) {
                return false;
            }
            seen[option.value] = true;
            return true;
        });

        select.innerHTML = '';
        var allOption = document.createElement('option');
        allOption.value = '';
        allOption.textContent = layer.filterAllLabel || 'All';
        select.appendChild(allOption);

        normalized.forEach(function (optionValue) {
            var option = document.createElement('option');
            option.value = optionValue.value;
            option.textContent = optionValue.label;
            option.title = optionValue.title;
            select.appendChild(option);
        });

        select.disabled = normalized.length === 0;
        select.value = selected && seen[selected] ? selected : '';
        layerFilters[key] = select.value;
    }

    function populateLayerFilterOptions(key, rawData) {
        var options = (persistedLayerFilterOptions[key] || []).concat(rawLayerFilterOptions(key, rawData || { features: [] }));
        setLayerFilterOptions(key, options);
    }

    function refreshLayerFilterOptions(key) {
        var state = internalLayerState[key] || {};
        populateLayerFilterOptions(key, state.rawData || { features: [] });
    }

    function applyInternalLayerFilter(key) {
        var state = internalLayerState[key];
        if (!state || !state.rawData) {
            return;
        }
        var data = filteredLayerData(key, state.rawData);
        state.data = data;
        var source = map.getSource(sourceIdFor(key));
        if (source && source.setData) {
            source.setData(data);
        }
        updateLayerStatus(key, 'internal', layerFeatureStatus(data, state.rawData));
    }

    function reloadInternalLayerForFilter(key) {
        var checkbox = document.querySelector('[data-layer-kind="internal"][data-layer-key="' + key + '"]');
        if (checkbox && checkbox.checked) {
            var source = map.getSource(sourceIdFor(key));
            if (source && source.setData) {
                source.setData({ type: 'FeatureCollection', features: [] });
            }
            internalLayerState[key] = Object.assign({}, internalLayerState[key] || {}, {
                loading: false,
                requestId: ++internalLayerRequestSeq
            });
            if (internalLayerState[key] && internalLayerState[key].loaded) {
                removeInternalLayer(key);
            }
            loadInternalLayer(key);
            return;
        }
        applyInternalLayerFilter(key);
    }

    function removeInternalLayer(key) {
        layerIdsFor(key).forEach(function (id) {
            if (map.getLayer(id)) {
                map.removeLayer(id);
            }
            delete renderLayerToLayerKey[id];
        });
        if (map.getSource(sourceIdFor(key))) {
            map.removeSource(sourceIdFor(key));
        }
        internalLayerState[key] = Object.assign({}, internalLayerState[key] || {}, {
            loaded: false,
            loading: false,
            rawData: null,
            data: null
        });
        updateLayerStatus(key, 'internal', '');
    }

    function addInternalLayer(key, geojson) {
        var layer = config.layers[key];
        var sourceId = sourceIdFor(key);
        var ids = layerIdsFor(key);
        var rawData = decorateGeoJson(key, geojson);
        populateLayerFilterOptions(key, rawData);
        var data = filteredLayerData(key, rawData);
        removeInternalLayer(key);

        map.addSource(sourceId, {
            type: 'geojson',
            data: data
        });

        map.addLayer({
            id: ids[0],
            type: 'fill',
            source: sourceId,
            filter: ['==', '$type', 'Polygon'],
            paint: {
                'fill-color': layer.color,
                'fill-opacity': 0.42
            }
        }, firstMeasureLayerId());
        map.addLayer({
            id: ids[1],
            type: 'line',
            source: sourceId,
            filter: ['==', '$type', 'LineString'],
            paint: {
                'line-color': layer.color,
                'line-width': 4
            }
        }, firstMeasureLayerId());
        if (layer.iconSet === 'femaIncident') {
            map.addLayer({
                id: ids[2],
                type: 'symbol',
                source: sourceId,
                filter: ['==', '$type', 'Point'],
                layout: {
                    'icon-image': ['get', '__incidentIcon'],
                    'icon-size': 0.54,
                    'icon-allow-overlap': true,
                    'icon-ignore-placement': true
                }
            }, firstMeasureLayerId());
        } else {
            map.addLayer({
                id: ids[2],
                type: 'circle',
                source: sourceId,
                filter: ['==', '$type', 'Point'],
                paint: {
                    'circle-color': layer.color,
                    'circle-radius': 7,
                    'circle-stroke-color': '#dbeafe',
                    'circle-stroke-width': 2
                }
            }, firstMeasureLayerId());
        }

        ids.forEach(function (id) {
            renderLayerToLayerKey[id] = key;
        });
        internalLayerState[key] = {
            loaded: true,
            loading: false,
            rawData: rawData,
            data: data
        };
        if (key === 'currentIncidents') {
            clearLocalCreatedIncidents();
        }
    }

    function loadInternalLayer(key) {
        var layer = config.layers[key];
        if (!layer) {
            return;
        }
        if (!config.wfsUrl) {
            internalLayerState[key] = { loaded: false, loading: false, data: null };
            updateLayerStatus(key, 'internal', 'Unavailable');
            setStatus(layer.title + ': GeoServer WFS URL is not configured.', true);
            return;
        }
        var state = internalLayerState[key] || {};
        if (state.loading) {
            return;
        }
        var requestId = ++internalLayerRequestSeq;
        internalLayerState[key] = Object.assign({}, state, {
            loading: true,
            requestId: requestId
        });
        updateLayerStatus(key, 'internal', 'Loading');
        setStatus('Loading ' + layer.title + ' from GeoServer...');

        fetchWfsJson(key, layer)
            .then(function (geojson) {
                if ((internalLayerState[key] || {}).requestId !== requestId) {
                    return;
                }
                var checkbox = document.querySelector('[data-layer-kind="internal"][data-layer-key="' + key + '"]');
                if (!checkbox || !checkbox.checked) {
                    internalLayerState[key] = { loaded: false, loading: false, data: null };
                    return;
                }
                addInternalLayer(key, geojson);
                var state = internalLayerState[key] || {};
                var statusText = layerFeatureStatus(state.data, state.rawData);
                updateLayerStatus(key, 'internal', statusText);
                setStatus(layer.title + ': ' + statusText + ' loaded.');
            })
            .catch(function (error) {
                if ((internalLayerState[key] || {}).requestId !== requestId) {
                    return;
                }
                internalLayerState[key] = { loaded: false, loading: false, data: null };
                updateLayerStatus(key, 'internal', 'Error');
                setStatus(layer.title + ': ' + error.message + '. Start the local GIS stack or check GeoServer, CORS, layer names, and WFS outputFormat.', true);
            });
    }

    function removeExternalLayer(key) {
        var sourceId = externalSourceIdFor(key);
        externalLayerIdsFor(key).forEach(function (layerId) {
            if (map.getLayer(layerId)) {
                map.removeLayer(layerId);
            }
            delete renderLayerToLayerKey[layerId];
        });
        if (map.getSource(sourceId)) {
            map.removeSource(sourceId);
        }
        externalLayerState[key] = { loaded: false, loading: false, data: null };
        updateLayerStatus(key, 'external', '');
    }

    function addRasterExternalLayer(key, layer) {
        removeExternalLayer(key);
        map.addSource(externalSourceIdFor(key), {
            type: 'raster',
            tiles: [layer.tilesUrl],
            tileSize: 256,
            attribution: layer.attribution || ''
        });
        map.addLayer({
            id: externalLayerIdFor(key),
            type: 'raster',
            source: externalSourceIdFor(key),
            paint: {
                'raster-opacity': Number(layer.opacity == null ? 0.7 : layer.opacity)
            }
        }, firstOperationalLayerId());
        externalLayerState[key] = { loaded: true, loading: false };
        updateLayerStatus(key, 'external', 'On');
    }

    function currentBoundsTokens() {
        var bounds = map.getBounds();
        var west = bounds.getWest().toFixed(5);
        var south = bounds.getSouth().toFixed(5);
        var east = bounds.getEast().toFixed(5);
        var north = bounds.getNorth().toFixed(5);
        return {
            west: west,
            south: south,
            east: east,
            north: north,
            bbox: west + ',' + south + ',' + east + ',' + north,
            bboxLatLon: south + ',' + west + ',' + north + ',' + east
        };
    }

    function externalGeoJsonUrl(layer) {
        var tokens = currentBoundsTokens();
        return String(layer.endpoint || '')
            .replace(/\{west\}/g, tokens.west)
            .replace(/\{south\}/g, tokens.south)
            .replace(/\{east\}/g, tokens.east)
            .replace(/\{north\}/g, tokens.north)
            .replace(/\{bbox\}/g, tokens.bbox)
            .replace(/\{bbox-epsg-4326\}/g, tokens.bbox)
            .replace(/\{bbox-lat-lon\}/g, tokens.bboxLatLon);
    }

    function limitGeoJsonFeatures(geojson, maxFeatures) {
        var limit = Number(maxFeatures || 500);
        var features = Array.isArray(geojson.features) ? geojson.features : [];
        return {
            type: 'FeatureCollection',
            features: features.filter(function (feature) {
                return feature && feature.geometry;
            }).slice(0, limit)
        };
    }

    function addGeoJsonExternalLayer(key, layer, geojson) {
        var sourceId = externalSourceIdFor(key);
        var baseId = externalLayerIdFor(key);
        var ids = [baseId + '-fill', baseId + '-line', baseId + '-point'];
        var data = decorateGeoJson(key, limitGeoJsonFeatures(geojson, layer.maxFeatures));
        var color = layer.color || '#38bdf8';
        removeExternalLayer(key);

        map.addSource(sourceId, {
            type: 'geojson',
            data: data,
            attribution: layer.attribution || ''
        });

        map.addLayer({
            id: ids[0],
            type: 'fill',
            source: sourceId,
            filter: ['==', '$type', 'Polygon'],
            paint: {
                'fill-color': color,
                'fill-opacity': Number(layer.fillOpacity == null ? 0.24 : layer.fillOpacity)
            }
        }, firstMeasureLayerId());
        map.addLayer({
            id: ids[1],
            type: 'line',
            source: sourceId,
            filter: ['==', '$type', 'LineString'],
            paint: {
                'line-color': color,
                'line-width': Number(layer.lineWidth == null ? 2 : layer.lineWidth)
            }
        }, firstMeasureLayerId());
        map.addLayer({
            id: ids[2],
            type: 'circle',
            source: sourceId,
            filter: ['==', '$type', 'Point'],
            paint: {
                'circle-color': color,
                'circle-radius': Number(layer.circleRadius == null ? 5 : layer.circleRadius),
                'circle-opacity': 0.88,
                'circle-stroke-color': '#0f172a',
                'circle-stroke-width': 1.5
            }
        }, firstMeasureLayerId());

        ids.forEach(function (id) {
            renderLayerToLayerKey[id] = key;
        });
        externalLayerState[key] = { loaded: true, loading: false, data: data };
        updateLayerStatus(key, 'external', data.features.length + ' feature' + (data.features.length === 1 ? '' : 's'));
    }

    function openSkyUrl(layer) {
        var bounds = map.getBounds();
        var url = new URL(layer.endpoint);
        url.searchParams.set('lamin', bounds.getSouth().toFixed(4));
        url.searchParams.set('lomin', bounds.getWest().toFixed(4));
        url.searchParams.set('lamax', bounds.getNorth().toFixed(4));
        url.searchParams.set('lomax', bounds.getEast().toFixed(4));
        return url.toString();
    }

    function openSkyGeoJson(data, key, layer) {
        var states = data.states || [];
        var maxFeatures = Number(layer.maxFeatures || 500);
        return {
            type: 'FeatureCollection',
            features: states.filter(function (state) {
                return state && typeof state[5] === 'number' && typeof state[6] === 'number';
            }).slice(0, maxFeatures).map(function (state) {
                return {
                    type: 'Feature',
                    geometry: {
                        type: 'Point',
                        coordinates: [state[5], state[6]]
                    },
                    properties: {
                        __layerKey: key,
                        callsign: String(state[1] || '').trim(),
                        origin_country: state[2],
                        altitude_ft: state[13] == null ? '' : Math.round(Number(state[13]) * 3.28084),
                        velocity_kt: state[9] == null ? '' : Math.round(Number(state[9]) * 1.94384),
                        heading: state[10] == null ? '' : Math.round(Number(state[10])),
                        on_ground: state[8] ? 'Yes' : 'No'
                    }
                };
            })
        };
    }

    function addPointExternalLayer(key, layer, data) {
        removeExternalLayer(key);
        map.addSource(externalSourceIdFor(key), {
            type: 'geojson',
            data: data
        });
        map.addLayer({
            id: externalLayerIdFor(key),
            type: 'circle',
            source: externalSourceIdFor(key),
            paint: {
                'circle-color': layer.color || '#facc15',
                'circle-radius': 4.5,
                'circle-opacity': 0.88,
                'circle-stroke-color': '#0f172a',
                'circle-stroke-width': 1.5
            }
        }, firstMeasureLayerId());
        renderLayerToLayerKey[externalLayerIdFor(key)] = key;
        externalLayerState[key] = { loaded: true, loading: false, data: data };
        updateLayerStatus(key, 'external', data.features.length + ' aircraft');
    }

    function loadOpenSkyLayer(key, layer) {
        externalLayerState[key] = { loaded: false, loading: true };
        updateLayerStatus(key, 'external', 'Loading');
        setStatus('Loading ' + layer.title + '...');
        fetch(openSkyUrl(layer))
            .then(function (response) {
                if (!response.ok) {
                    throw new Error('OpenSky returned HTTP ' + response.status);
                }
                return response.json();
            })
            .then(function (data) {
                var checkbox = document.querySelector('[data-layer-kind="external"][data-layer-key="' + key + '"]');
                if (!checkbox || !checkbox.checked) {
                    externalLayerState[key] = { loaded: false, loading: false };
                    return;
                }
                var geojson = openSkyGeoJson(data, key, layer);
                addPointExternalLayer(key, layer, geojson);
                setStatus(layer.title + ': ' + geojson.features.length + ' aircraft loaded for the current map extent.');
            })
            .catch(function (error) {
                externalLayerState[key] = { loaded: false, loading: false };
                updateLayerStatus(key, 'external', 'Error');
                setStatus(layer.title + ': ' + error.message + '. OpenSky may rate-limit or block browser-origin requests.', true);
            });
    }

    function loadGeoJsonExternalLayer(key, layer) {
        externalLayerState[key] = { loaded: false, loading: true };
        updateLayerStatus(key, 'external', 'Loading');
        setStatus('Loading ' + layer.title + '...');
        fetch(externalGeoJsonUrl(layer))
            .then(function (response) {
                if (!response.ok) {
                    throw new Error('Feed returned HTTP ' + response.status);
                }
                return response.json();
            })
            .then(function (geojson) {
                var checkbox = document.querySelector('[data-layer-kind="external"][data-layer-key="' + key + '"]');
                if (!checkbox || !checkbox.checked) {
                    externalLayerState[key] = { loaded: false, loading: false };
                    return;
                }
                addGeoJsonExternalLayer(key, layer, geojson);
                var count = externalLayerState[key].data.features.length;
                setStatus(layer.title + ': ' + count + ' feature(s) loaded.');
            })
            .catch(function (error) {
                externalLayerState[key] = { loaded: false, loading: false };
                updateLayerStatus(key, 'external', 'Error');
                setStatus(layer.title + ': ' + error.message + '. Check the public feed, CORS, rate limits, and layer configuration.', true);
            });
    }

    function toggleExternalLayer(key, enabled) {
        var layer = config.externalLayers[key];
        if (!layer) {
            return;
        }
        if (!enabled) {
            removeExternalLayer(key);
            return;
        }
        if (layer.kind === 'raster' && layer.tilesUrl) {
            addRasterExternalLayer(key, layer);
            setStatus(layer.title + ' overlay enabled.');
        } else if (layer.kind === 'geojson' && layer.endpoint) {
            loadGeoJsonExternalLayer(key, layer);
        } else if (layer.kind === 'opensky' && layer.endpoint) {
            loadOpenSkyLayer(key, layer);
        } else {
            updateLayerStatus(key, 'external', 'Unavailable');
            setStatus(layer.title + ': ' + (layer.note || 'No public layer endpoint is configured.'), true);
        }
    }

    function fitToFeatures(features) {
        var bounds = new maplibregl.LngLatBounds();
        var coordinateCount = 0;
        features.forEach(function (feature) {
            if (feature.geometry) {
                coordinateCount = extendBounds(bounds, feature.geometry.coordinates, coordinateCount);
            }
        });
        if (coordinateCount > 0) {
            map.fitBounds(bounds, { padding: 70, maxZoom: 15 });
        }
    }

    function fitAllLoadedFeatures() {
        var features = [];
        Object.keys(internalLayerState).forEach(function (key) {
            var state = internalLayerState[key];
            if (state && state.loaded && state.data && state.data.features) {
                features = features.concat(state.data.features);
            }
        });
        Object.keys(externalLayerState).forEach(function (key) {
            var state = externalLayerState[key];
            if (state && state.loaded && state.data && state.data.features) {
                features = features.concat(state.data.features);
            }
        });
        if (features.length) {
            fitToFeatures(features);
        }
    }

    function updateDrawSummary() {
        if (!draw) {
            drawOutput.textContent = 'Unavailable';
            drawTools.hidden = true;
            return;
        }
        var data = draw.getAll();
        var features = data.features || [];
        drawTools.hidden = features.length === 0;
        var totalLength = features.reduce(function (sum, feature) {
            return sum + featureLengthMeters(feature);
        }, 0);
        var totalArea = features.reduce(function (sum, feature) {
            return sum + featureAreaSqMeters(feature);
        }, 0);
        var summary = features.length + ' shape' + (features.length === 1 ? '' : 's');
        if (totalLength) {
            summary += ' | ' + formatDistance(totalLength);
        }
        if (config.tools.drawArea && totalArea) {
            summary += ' | ' + formatArea(totalArea);
        }
        drawOutput.textContent = summary;
    }

    function drawStyles() {
        return [
            {
                id: 'gl-draw-polygon-fill-inactive',
                type: 'fill',
                filter: ['all', ['==', 'active', 'false'], ['==', '$type', 'Polygon'], ['!=', 'mode', 'static']],
                paint: {
                    'fill-color': '#38bdf8',
                    'fill-outline-color': '#7dd3fc',
                    'fill-opacity': 0.18
                }
            },
            {
                id: 'gl-draw-polygon-fill-active',
                type: 'fill',
                filter: ['all', ['==', 'active', 'true'], ['==', '$type', 'Polygon']],
                paint: {
                    'fill-color': '#facc15',
                    'fill-outline-color': '#fde68a',
                    'fill-opacity': 0.22
                }
            },
            {
                id: 'gl-draw-polygon-stroke-inactive',
                type: 'line',
                filter: ['all', ['==', 'active', 'false'], ['==', '$type', 'Polygon'], ['!=', 'mode', 'static']],
                layout: {
                    'line-cap': 'round',
                    'line-join': 'round'
                },
                paint: {
                    'line-color': '#7dd3fc',
                    'line-width': 2
                }
            },
            {
                id: 'gl-draw-polygon-stroke-active',
                type: 'line',
                filter: ['all', ['==', 'active', 'true'], ['==', '$type', 'Polygon']],
                layout: {
                    'line-cap': 'round',
                    'line-join': 'round'
                },
                paint: {
                    'line-color': '#facc15',
                    'line-width': 3
                }
            },
            {
                id: 'gl-draw-line-inactive',
                type: 'line',
                filter: ['all', ['==', 'active', 'false'], ['==', '$type', 'LineString'], ['!=', 'mode', 'static']],
                layout: {
                    'line-cap': 'round',
                    'line-join': 'round'
                },
                paint: {
                    'line-color': '#7dd3fc',
                    'line-width': 3
                }
            },
            {
                id: 'gl-draw-line-active',
                type: 'line',
                filter: ['all', ['==', 'active', 'true'], ['==', '$type', 'LineString']],
                layout: {
                    'line-cap': 'round',
                    'line-join': 'round'
                },
                paint: {
                    'line-color': '#facc15',
                    'line-width': 3
                }
            },
            {
                id: 'gl-draw-point-inactive',
                type: 'circle',
                filter: ['all', ['==', 'active', 'false'], ['==', '$type', 'Point'], ['==', 'meta', 'feature'], ['!=', 'mode', 'static']],
                paint: {
                    'circle-color': '#38bdf8',
                    'circle-radius': 5,
                    'circle-stroke-color': '#e0f2fe',
                    'circle-stroke-width': 2
                }
            },
            {
                id: 'gl-draw-point-active',
                type: 'circle',
                filter: ['all', ['==', 'active', 'true'], ['==', '$type', 'Point'], ['==', 'meta', 'feature']],
                paint: {
                    'circle-color': '#facc15',
                    'circle-radius': 6,
                    'circle-stroke-color': '#fef3c7',
                    'circle-stroke-width': 2
                }
            },
            {
                id: 'gl-draw-vertex',
                type: 'circle',
                filter: ['all', ['==', 'meta', 'vertex'], ['==', '$type', 'Point']],
                paint: {
                    'circle-color': '#f8fafc',
                    'circle-radius': 4,
                    'circle-stroke-color': '#38bdf8',
                    'circle-stroke-width': 2
                }
            },
            {
                id: 'gl-draw-midpoint',
                type: 'circle',
                filter: ['all', ['==', 'meta', 'midpoint'], ['==', '$type', 'Point']],
                paint: {
                    'circle-color': '#0ea5e9',
                    'circle-radius': 3
                }
            }
        ];
    }

    function updateLayerStatus(key, kind, message) {
        var output = document.querySelector('[data-layer-status="' + kind + ':' + key + '"]');
        if (output) {
            output.textContent = message || '';
        }
        layerIssueState[kind + ':' + key] = message === 'Error' || message === 'Unavailable';
        updateStatusIssueCount();
    }

    function groupedEntries(object) {
        var groups = {};
        Object.keys(object || {}).forEach(function (key) {
            var item = object[key];
            var category = item.category || 'Other';
            if (!groups[category]) {
                groups[category] = [];
            }
            groups[category].push({ key: key, item: item });
        });
        return groups;
    }

    function appendLayerRows(container, layers, kind) {
        container.innerHTML = '';
        var groups = groupedEntries(layers);
        Object.keys(groups).forEach(function (category) {
            var group = document.createElement('div');
            group.className = 'geo-layer-group';
            var title = document.createElement('div');
            title.className = 'geo-layer-group-title';
            title.textContent = category;
            group.appendChild(title);

            groups[category].forEach(function (entry) {
                var row = document.createElement('label');
                row.className = 'geo-layer-row';
                row.title = entry.item.note || '';

                var checkbox = document.createElement('input');
                checkbox.type = 'checkbox';
                checkbox.checked = !!entry.item.enabled;
                checkbox.disabled = entry.item.kind === 'unavailable';
                checkbox.setAttribute('data-layer-kind', kind);
                checkbox.setAttribute('data-layer-key', entry.key);

                var swatch = document.createElement('span');
                swatch.className = 'geo-layer-swatch';
                swatch.style.background = entry.item.color || '#38bdf8';

                var label = document.createElement('span');
                label.className = 'geo-layer-label';
                label.textContent = entry.item.title;

                var status = document.createElement('output');
                status.className = 'geo-layer-row-status';
                status.setAttribute('data-layer-status', kind + ':' + entry.key);
                if (entry.item.kind === 'unavailable') {
                    status.textContent = 'Requires provider';
                }

                row.appendChild(checkbox);
                row.appendChild(swatch);
                row.appendChild(label);
                row.appendChild(status);
                group.appendChild(row);

                if (kind === 'internal' && entry.item.filterField) {
                    var filterId = 'geo-layer-filter-' + safeId(entry.key);
                    var filterRow = document.createElement('div');
                    filterRow.className = 'geo-layer-filter';
                    filterRow.setAttribute('data-layer-filter-container', entry.key);

                    var filterLabel = document.createElement('label');
                    filterLabel.setAttribute('for', filterId);
                    filterLabel.textContent = entry.item.filterLabel || entry.item.filterField;

                    var filterSelect = document.createElement('select');
                    filterSelect.id = filterId;
                    filterSelect.disabled = true;
                    filterSelect.setAttribute('data-layer-filter', entry.key);

                    var filterOption = document.createElement('option');
                    filterOption.value = '';
                    filterOption.textContent = entry.item.filterAllLabel || 'All';
                    filterSelect.appendChild(filterOption);

                    filterRow.appendChild(filterLabel);
                    filterRow.appendChild(filterSelect);
                    group.appendChild(filterRow);

                    filterSelect.addEventListener('change', function () {
                        layerFilters[entry.key] = filterSelect.value;
                        reloadInternalLayerForFilter(entry.key);
                    });
                }

                checkbox.addEventListener('change', function () {
                    if (kind === 'internal') {
                        if (checkbox.checked) {
                            loadInternalLayer(entry.key);
                        } else {
                            removeInternalLayer(entry.key);
                        }
                    } else {
                        toggleExternalLayer(entry.key, checkbox.checked);
                    }
                });
            });
            container.appendChild(group);
        });
    }

    function setLayerDrawerOpen(open) {
        layerDrawer.hidden = !open;
        layerToggle.setAttribute('aria-expanded', open ? 'true' : 'false');
        layerToggle.classList.toggle('is-active', open);
    }

    if (!window.maplibregl) {
        setStatus('MapLibre GL JS could not be loaded. Check geo.viewer.mapLibreJsUrl.', true);
        return;
    }

    if (!config.wfsUrl) {
        setStatus('GeoServer WFS URL is not configured.', true);
    }

    populateTopFilterFields();
    setFilterOpen(!!(filterFields && !filterFields.hidden));
    populateZoomLevels();
    viewTools.hidden = !config.tools.fitLayer;
    incidentTools.hidden = !config.tools.createIncidents;
    placeSearchTools.hidden = !config.tools.placeSearch;
    geoAiTools.hidden = !config.tools.geoaiRequests;
    measureTools.hidden = !config.tools.measureDistance;
    drawTools.hidden = true;
    coordinatePanel.hidden = !config.tools.coordinates;
    layerDrawer.hidden = !config.tools.layerList;
    layerToggle.hidden = !config.tools.layerList;
    basemapPicker.hidden = !config.tools.basemapSelector;
    Array.prototype.forEach.call(coordinateFormat.options, function (option) {
        if (option.value === 'dms') {
            option.hidden = !config.tools.dms;
        }
        if (option.value === 'mgrs') {
            option.hidden = !config.tools.mgrs;
        }
    });
    setCoordinateCopyMode(false);
    populateIncidentLookups();

    var map = new maplibregl.Map({
        container: 'geo-map',
        style: rasterStyle(),
        center: config.center || [-106.0, 34.5],
        zoom: config.zoom || 6
    });

    if (config.tools.fullscreen && maplibregl.FullscreenControl) {
        map.addControl(new maplibregl.FullscreenControl(), 'top-right');
    }
    map.addControl(new maplibregl.ScaleControl({ unit: 'imperial' }), 'bottom-left');
    updateZoomLevelControl();
    updateNorthArrow();
    map.on('zoomend', updateZoomLevelControl);
    map.on('zoomend', updateGeoAiExtent);
    map.on('moveend', updateGeoAiExtent);
    map.on('rotate', updateNorthArrow);
    map.on('rotateend', updateNorthArrow);

    appendLayerRows(internalLayerList, config.layers || {}, 'internal');
    appendLayerRows(externalLayerList, config.externalLayers || {}, 'external');
    loadGeoAiJobs();
    setLayerDrawerOpen(false);
    updateBasemapCards();

    map.on('load', function () {
        window.setTimeout(function () {
            map.resize();
        }, 0);
        ensureMeasureLayers();
        registerIncidentIcons();
        ensureIncidentOverlayLayers();

        if (config.tools.drawing && window.MapboxDraw) {
            try {
                if (window.MapboxDraw.constants && window.MapboxDraw.constants.classes) {
                    window.MapboxDraw.constants.classes.CANVAS = 'maplibregl-canvas';
                    window.MapboxDraw.constants.classes.CONTROL_BASE = 'maplibregl-ctrl';
                    window.MapboxDraw.constants.classes.CONTROL_PREFIX = 'maplibregl-ctrl-';
                    window.MapboxDraw.constants.classes.CONTROL_GROUP = 'maplibregl-ctrl-group';
                    window.MapboxDraw.constants.classes.ATTRIBUTION = 'maplibregl-ctrl-attrib';
                }
                draw = new window.MapboxDraw({
                    displayControlsDefault: false,
                    controls: {
                        point: true,
                        line_string: true,
                        polygon: true,
                        trash: true
                    },
                    styles: drawStyles()
                });
                map.addControl(draw, 'bottom-left');
                map.on('draw.create', updateDrawSummary);
                map.on('draw.update', updateDrawSummary);
                map.on('draw.delete', updateDrawSummary);
                map.on('draw.selectionchange', updateDrawSummary);
                map.on('draw.create', updateGeoAiExtent);
                map.on('draw.update', updateGeoAiExtent);
                map.on('draw.delete', updateGeoAiExtent);
                updateDrawSummary();
            } catch (error) {
                drawOutput.textContent = 'Unavailable';
            }
        } else if (config.tools.drawing) {
            drawOutput.textContent = 'Unavailable';
        }

        Object.keys(config.layers || {}).forEach(function (key) {
            var checkbox = document.querySelector('[data-layer-kind="internal"][data-layer-key="' + key + '"]');
            if (checkbox && checkbox.checked) {
                loadInternalLayer(key);
            }
        });
        Object.keys(config.externalLayers || {}).forEach(function (key) {
            var layer = config.externalLayers[key];
            var checkbox = document.querySelector('[data-layer-kind="external"][data-layer-key="' + key + '"]');
            if (checkbox && checkbox.checked && layer.kind !== 'unavailable') {
                toggleExternalLayer(key, true);
            }
        });
        connectGatewayUpdates();
    });

    map.on('click', function (event) {
        if (incidentCreateMode) {
            placeIncidentDraft(event.lngLat);
            return;
        }
        if (placeSearchMode) {
            showPlaceSearchPopup(event.lngLat);
            return;
        }
        if (config.tools.coordinates) {
            updateCoordinateReadout(event.lngLat);
        }
        if (measureMode) {
            measurePoints.push([event.lngLat.lng, event.lngLat.lat]);
            updateMeasureGraphics();
            return;
        }
        if (config.tools.coordinates && coordinateClickCopy && coordinateClickCopy.checked) {
            copyCoordinateAt(event.lngLat);
            return;
        }
        var layerIds = allInternalRenderLayerIds().concat(allExternalRenderLayerIds());
        if (!layerIds.length) {
            return;
        }
        var features = map.queryRenderedFeatures(event.point, { layers: layerIds });
        if (!features.length) {
            return;
        }
        var feature = features[0];
        var key = feature.properties && feature.properties.__layerKey;
        var layer = (config.layers || {})[key] || (config.externalLayers || {})[key];
        if (!layer) {
            return;
        }
        new maplibregl.Popup({
            className: 'geo-map-feature-popup',
            maxWidth: '360px'
        })
            .setLngLat(event.lngLat)
            .setHTML(popupHtml(feature, layer))
            .addTo(map);
    });

    map.on('mousemove', function (event) {
        if (config.tools.coordinates) {
            updateCoordinateReadout(event.lngLat);
        }
        if (measureMode) {
            return;
        }
        if (incidentCreateMode) {
            map.getCanvas().style.cursor = 'crosshair';
            return;
        }
        if (placeSearchMode) {
            map.getCanvas().style.cursor = 'help';
            return;
        }
        var layerIds = allInternalRenderLayerIds().concat(allExternalRenderLayerIds());
        if (!layerIds.length) {
            map.getCanvas().style.cursor = '';
            return;
        }
        var features = map.queryRenderedFeatures(event.point, { layers: layerIds });
        map.getCanvas().style.cursor = features.length ? 'pointer' : '';
    });

    if (layerToggle) {
        layerToggle.addEventListener('click', function () {
            setLayerDrawerOpen(layerDrawer.hidden);
        });
    }
    if (layerClose) {
        layerClose.addEventListener('click', function () {
            setLayerDrawerOpen(false);
        });
    }
    if (statusToggle) {
        statusToggle.addEventListener('click', function () {
            setStatusCollapsed(!statusEl.classList.contains('is-collapsed'));
        });
    }
    if (filterToggle) {
        filterToggle.addEventListener('click', function () {
            setFilterOpen(filterFields.hidden);
        });
    }
    if (filterLayerSelect) {
        filterLayerSelect.addEventListener('change', function () {
            if (filterFieldSelect) {
                filterFieldSelect.setAttribute('data-selected-field', '');
            }
            populateTopFilterFields();
        });
    }
    if (basemapToggle) {
        basemapToggle.addEventListener('click', function () {
            var open = basemapMenu.hidden;
            basemapMenu.hidden = !open;
            basemapToggle.setAttribute('aria-expanded', open ? 'true' : 'false');
        });
    }
    Array.prototype.forEach.call(document.querySelectorAll('.geo-basemap-card'), function (card) {
        card.addEventListener('click', function () {
            applyBasemap(card.getAttribute('data-basemap-key'));
            basemapMenu.hidden = true;
            basemapToggle.setAttribute('aria-expanded', 'false');
        });
    });
    if (zoomInButton) {
        zoomInButton.addEventListener('click', function () {
            stepZoom(1);
        });
    }
    if (zoomOutButton) {
        zoomOutButton.addEventListener('click', function () {
            stepZoom(-1);
        });
    }
    if (zoomLevelSelect) {
        zoomLevelSelect.addEventListener('change', function () {
            map.easeTo({ zoom: Number(zoomLevelSelect.value) });
        });
    }
    if (measureToggle) {
        measureToggle.addEventListener('click', function () {
            setGeoAiPanelOpen(false);
            setPlaceSearchMode(false);
            setMeasureMode(!measureMode);
        });
    }
    if (measureClear) {
        measureClear.addEventListener('click', clearMeasure);
    }
    if (incidentCreateToggle) {
        incidentCreateToggle.addEventListener('click', function () {
            setGeoAiPanelOpen(false);
            setPlaceSearchMode(false);
            setIncidentPanelOpen(false);
            clearIncidentDraft();
            setIncidentCreateMode(!incidentCreateMode);
        });
    }
    if (placeSearchToggle) {
        placeSearchToggle.addEventListener('click', function () {
            setPlaceSearchMode(!placeSearchMode);
        });
    }
    if (incidentCreateClose) {
        incidentCreateClose.addEventListener('click', function () {
            setIncidentPanelOpen(false);
            clearIncidentDraft();
            setIncidentCreateMode(false);
        });
    }
    if (incidentCancel) {
        incidentCancel.addEventListener('click', function () {
            setIncidentPanelOpen(false);
            clearIncidentDraft();
            setIncidentCreateMode(false);
        });
    }
    if (incidentCreateForm) {
        incidentCreateForm.addEventListener('submit', function (event) {
            event.preventDefault();
            saveIncidentDraft();
        });
    }
    if (geoAiToggle) {
        geoAiToggle.addEventListener('click', function () {
            setGeoAiPanelOpen(geoAiPanel.hidden);
        });
    }
    if (geoAiClose) {
        geoAiClose.addEventListener('click', function () {
            setGeoAiPanelOpen(false);
        });
    }
    if (geoAiModel) {
        geoAiModel.addEventListener('change', function () {
            populateGeoAiWorkflows();
            setGeoAiControlsEnabled(!!geoAiModels.length);
        });
    }
    if (geoAiWorkflow) {
        geoAiWorkflow.addEventListener('change', function () {
            setGeoAiControlsEnabled(!!geoAiModels.length);
        });
    }
    if (geoAiForm) {
        geoAiForm.addEventListener('submit', submitGeoAiRun);
    }
    if (fitLayer) {
        fitLayer.addEventListener('click', fitAllLoadedFeatures);
    }
    if (resetNorth) {
        resetNorth.addEventListener('click', function () {
            map.easeTo({ bearing: 0, pitch: 0, duration: 450 });
        });
    }
    if (coordinateFormat) {
        coordinateFormat.addEventListener('change', function () {
            if (hoverCoordinate) {
                updateCoordinateReadout(hoverCoordinate);
            }
        });
    }
    if (coordinateClickCopy) {
        coordinateClickCopy.addEventListener('change', function () {
            setCoordinateCopyMode(coordinateClickCopy.checked);
        });
    }
    window.addEventListener('resize', function () {
        map.resize();
    });
})();
</script>
</body>
</html>
