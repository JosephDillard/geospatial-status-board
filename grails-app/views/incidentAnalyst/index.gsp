<!doctype html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>Incident Analyst</title>
    <content tag="hideQuickLinks">true</content>
    <link rel="stylesheet" href="${mapLibreCssUrl}"/>
    <asset:stylesheet src="incident-analyst.css"/>
</head>
<body>
<main class="geo-map-page incident-analyst-page" role="main">
    <section class="geo-map-toolbar incident-analyst-toolbar" aria-label="Incident Analyst controls">
        <div>
            <h1>Incident Analyst</h1>
            <p>Focused incident review for northern New Mexico, from Santa Fe north to the Colorado border.</p>
        </div>
        <div class="incident-analyst-fields" aria-label="Incident analysis settings">
            <div class="geo-map-field">
                <label for="radius">Radius km</label>
                <input id="radius" type="number" min="5" max="250" value="220"/>
            </div>
            <div class="geo-map-field">
                <label>Area</label>
                <output>Santa Fe to Colorado border</output>
            </div>
            <div class="geo-map-field">
                <label>Workflow</label>
                <output id="status">Incident review route</output>
            </div>
        </div>
    </section>

    <section class="incident-analyst-workspace">
        <section class="geo-map-shell" aria-label="Incident Analyst map">
            <div id="geo-map-status" class="geo-map-status" aria-label="Map messages">
                <span id="geo-map-status-message" class="geo-map-status-message" aria-live="polite">Loading map...</span>
            </div>

            <div class="geo-map-thumb-controls" aria-label="Map panels">
                <button id="geo-layer-toggle"
                        type="button"
                        class="geo-map-thumb-button geo-map-drawer-toggle"
                        aria-label="Layers"
                        title="Layers"
                        aria-expanded="false"
                        aria-controls="geo-layer-drawer">
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
                            aria-expanded="false"
                            aria-controls="geo-basemap-menu">
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

            <aside id="geo-layer-drawer" class="geo-layer-drawer" aria-label="Map layers" hidden>
                <div class="geo-layer-drawer-header">
                    <strong>Layers</strong>
                    <button id="geo-layer-close" type="button" class="geo-map-icon-button" aria-label="Hide layers">x</button>
                </div>
                <details open>
                    <summary>Incident Review</summary>
                    <div class="geo-layer-list">
                        <label class="geo-layer-row">
                            <input id="geo-layer-incidents" type="checkbox" checked/>
                            <span class="geo-layer-swatch geo-layer-swatch-incident" aria-hidden="true"></span>
                            <span class="geo-layer-label">Current Incidents</span>
                            <span id="geo-layer-incidents-status" class="geo-layer-row-status">0</span>
                        </label>
                        <label class="geo-layer-row">
                            <input id="geo-layer-assets" type="checkbox" checked/>
                            <span class="geo-layer-swatch geo-layer-swatch-asset" aria-hidden="true"></span>
                            <span class="geo-layer-label">Critical Assets</span>
                            <span id="geo-layer-assets-status" class="geo-layer-row-status">0</span>
                        </label>
                        <label class="geo-layer-row">
                            <input id="geo-layer-support" type="checkbox" checked/>
                            <span class="geo-layer-swatch geo-layer-swatch-support" aria-hidden="true"></span>
                            <span class="geo-layer-label">Nearby Support</span>
                            <span id="geo-layer-support-status" class="geo-layer-row-status">0</span>
                        </label>
                    </div>
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
                            aria-label="Fit incidents"
                            title="Fit incidents">
                        <span aria-hidden="true"></span>
                    </button>
                </div>
                <div id="geo-support-tools" class="geo-support-control">
                    <button id="geo-support-toggle"
                            type="button"
                            class="geo-map-square-button geo-support-toggle"
                            aria-label="Find nearby support"
                            aria-pressed="false"
                            title="Find nearby support">
                        POI
                    </button>
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

            <div id="incident-map" class="geo-map-canvas"></div>
        </section>

        <aside class="analysis-panel" aria-label="Incident panel">
            <section class="summary">
                <h2>Incident Panel</h2>
                <p id="summaryText">Incidents inside the northern New Mexico review area are listed below. Select an incident to zoom the map.</p>
                <div class="risk" id="risk">Risk: none</div>
            </section>

            <section>
                <h2>Risk Breakdown</h2>
                <div id="riskBreakdown" class="scorecard"></div>
            </section>

            <section>
                <h2>Scoring Source</h2>
                <div class="scorecard scoring-note">
                    <p>Current demo scoring is rule-based. Incident severity and asset criticality are fields in the MCP dataset, then converted to numeric scores.</p>
                    <p>Low = 1, medium = 2, high = 3, critical = 4. A +2 bonus applies when the closest incident is within 1 km.</p>
                </div>
            </section>

            <section>
                <h2>Recommended Actions</h2>
                <ul id="actions"></ul>
            </section>

            <section>
                <h2>Nearby Support</h2>
                <div id="supportPois" class="result-list"></div>
            </section>

            <section>
                <h2>Nearby Incidents</h2>
                <div id="incidents" class="result-list"></div>
            </section>

            <section>
                <h2>Nearby Assets</h2>
                <div id="assets" class="result-list"></div>
            </section>
        </aside>
    </section>
</main>

<script>
window.incidentAnalystConfig = ${raw(incidentAnalystConfigJson)};
</script>
<script src="${mapLibreJsUrl}"></script>
<g:if test="${mgrsJsUrl}">
    <script src="${mgrsJsUrl}"></script>
</g:if>
<asset:javascript src="incident-analyst.js"/>
</body>
</html>
