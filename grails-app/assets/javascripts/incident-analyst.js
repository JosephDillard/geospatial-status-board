(function () {
    var config = window.incidentAnalystConfig || {};
    var initialPoint = config.initialPoint || { latitude: 35.6870, longitude: -105.9378 };
    var corridorBounds = config.corridorBounds || [[-107.15, 35.45], [-104.1, 37.08]];
    var supportRadiusM = Number(config.supportRadiusM || 20000);
    var minZoom = Number(config.minZoom || 6);
    var maxZoom = Number(config.maxZoom || 14);
    var activeBasemapKey = config.selectedBasemap || 'osmLight';
    var basemaps = config.basemaps || {
        osmLight: {
            title: 'OpenStreetMap',
            buttonLabel: 'OSM',
            tilesUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            attribution: '(c) OpenStreetMap contributors',
            background: '#dce7f3',
            opacity: 1,
            preview: 'linear-gradient(135deg, #e8f1f5 0%, #cddfb8 50%, #8fb7d3 100%)',
            previewImage: ''
        }
    };

    var referenceLabels = [
        { name: 'Santa Fe', coordinates: [-105.9378, 35.6870] },
        { name: 'Los Alamos', coordinates: [-106.3050, 35.8891] },
        { name: 'Espanola', coordinates: [-106.0806, 35.9911] },
        { name: 'Taos', coordinates: [-105.5733, 36.4070] },
        { name: 'Chama', coordinates: [-106.5791, 36.9037] },
        { name: 'Raton Pass', coordinates: [-104.4389, 36.9028] },
        { name: 'Colorado Border', coordinates: [-105.45, 37.0] }
    ];

    var sourceIds = {
        basemap: 'geo-basemap-source',
        corridor: 'incident-corridor-source',
        labels: 'incident-label-source',
        incidents: 'incident-result-source',
        assets: 'asset-result-source',
        support: 'support-result-source',
        coordinateMarker: 'coordinate-marker-source',
        measure: 'measure-features'
    };

    var layerIds = {
        background: 'geo-basemap-background',
        basemap: 'geo-basemap-raster',
        corridorFill: 'incident-corridor-fill',
        corridorOutline: 'incident-corridor-outline',
        routes: 'incident-response-routes',
        labels: 'incident-reference-labels',
        incidents: 'incident-result-points',
        assets: 'asset-result-points',
        support: 'support-result-points',
        coordinateMarker: 'coordinate-marker-point',
        measureLine: 'measure-line',
        measurePoints: 'measure-points'
    };

    var statusEl = document.getElementById('status');
    var mapStatusEl = document.getElementById('geo-map-status');
    var mapStatusMessage = document.getElementById('geo-map-status-message');
    var summaryText = document.getElementById('summaryText');
    var riskEl = document.getElementById('risk');
    var riskBreakdownEl = document.getElementById('riskBreakdown');
    var actionsEl = document.getElementById('actions');
    var incidentsEl = document.getElementById('incidents');
    var assetsEl = document.getElementById('assets');
    var supportPoisEl = document.getElementById('supportPois');
    var radiusEl = document.getElementById('radius');
    var basemapToggle = document.getElementById('geo-basemap-toggle');
    var basemapToggleLabel = document.getElementById('geo-basemap-toggle-label');
    var basemapMenu = document.getElementById('geo-basemap-menu');
    var layerToggle = document.getElementById('geo-layer-toggle');
    var layerDrawer = document.getElementById('geo-layer-drawer');
    var layerClose = document.getElementById('geo-layer-close');
    var incidentLayerToggle = document.getElementById('geo-layer-incidents');
    var assetLayerToggle = document.getElementById('geo-layer-assets');
    var supportLayerToggle = document.getElementById('geo-layer-support');
    var incidentLayerStatus = document.getElementById('geo-layer-incidents-status');
    var assetLayerStatus = document.getElementById('geo-layer-assets-status');
    var supportLayerStatus = document.getElementById('geo-layer-support-status');
    var zoomIn = document.getElementById('geo-zoom-in');
    var zoomOut = document.getElementById('geo-zoom-out');
    var zoomLevel = document.getElementById('geo-zoom-level');
    var fitLayer = document.getElementById('geo-fit-layer');
    var supportToggle = document.getElementById('geo-support-toggle');
    var measureToggle = document.getElementById('geo-measure-toggle');
    var measurePanel = document.getElementById('geo-measure-panel');
    var measureOutput = document.getElementById('geo-measure-output');
    var measureClear = document.getElementById('geo-measure-clear');
    var resetNorth = document.getElementById('geo-reset-north');
    var northArrowIndicator = document.getElementById('geo-north-arrow-indicator');
    var coordinatePanel = document.getElementById('geo-coordinate-panel');
    var coordinateFormat = document.getElementById('geo-coordinate-format');
    var coordinateOutput = document.getElementById('geo-coordinate-output');
    var coordinateClickCopy = document.getElementById('geo-coordinate-click-copy');

    var map;
    var latestPayload = null;
    var latestSupportPayload = null;
    var hoverCoordinate = null;
    var supportMode = false;
    var measureMode = false;
    var measurePoints = [];

    initBasemapCards();
    populateZoomOptions();
    renderRiskBreakdown({
        risk: { level: 'none', score: 0, incident_score: 0, asset_score: 0, proximity_bonus: 0 },
        nearby_incidents: [],
        nearby_assets: []
    });
    renderSupportPanel(null);

    if (window.maplibregl) {
        map = new maplibregl.Map({
            container: 'incident-map',
            style: rasterStyle(),
            center: [-105.95, 36.24],
            zoom: Number(config.defaultZoom || 7.25),
            minZoom: minZoom,
            maxZoom: maxZoom,
            maxBounds: [[-107.6, 35.2], [-103.75, 37.22]]
        });
        window.incidentAnalystMap = map;

        map.addControl(new maplibregl.ScaleControl({ unit: 'imperial' }), 'bottom-left');

        map.on('load', function () {
            registerMapImages();
            ensureOperationalLayers();
            map.fitBounds(corridorBounds, { padding: 38, duration: 0 });
            updateZoomLevelControl();
            updateNorthArrow();
            setMapStatus(selectedBasemap().title + ' basemap loaded. General map tools are ready.');
            loadIncidentContext();
        });

        map.on('click', handleMapClick);
        map.on('mousemove', function (event) {
            updateCoordinateReadout(event.lngLat);
            if (!measureMode) {
                updateMapCursor(event.point);
            }
        });
        map.on('zoomend', updateZoomLevelControl);
        map.on('rotate', updateNorthArrow);
        map.on('rotateend', updateNorthArrow);
        bindLayerCursor(layerIds.incidents);
        bindLayerCursor(layerIds.assets);
        bindLayerCursor(layerIds.support);
        map.on('error', function (event) {
            var message = event && event.error && event.error.message ? event.error.message : '';
            if (message.toLowerCase().indexOf('tile') >= 0 || message.toLowerCase().indexOf('image') >= 0) {
                setMapStatus(selectedBasemap().title + ' tile request failed. Try another basemap from the picker.', true);
            }
        });
    } else {
        setWorkflowStatus('Map unavailable');
        setMapStatus('MapLibre did not load. Check the configured MapLibre URL and refresh.', true);
    }

    bindEvents();

    function bindEvents() {
        if (radiusEl) {
            radiusEl.addEventListener('change', loadIncidentContext);
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
        if (incidentLayerToggle) {
            incidentLayerToggle.addEventListener('change', function () {
                setLayerVisibility(layerIds.incidents, incidentLayerToggle.checked);
            });
        }
        if (assetLayerToggle) {
            assetLayerToggle.addEventListener('change', function () {
                setLayerVisibility(layerIds.assets, assetLayerToggle.checked);
            });
        }
        if (supportLayerToggle) {
            supportLayerToggle.addEventListener('change', function () {
                setLayerVisibility(layerIds.support, supportLayerToggle.checked);
            });
        }
        if (zoomIn) {
            zoomIn.addEventListener('click', function () {
                map.zoomIn({ duration: 180 });
            });
        }
        if (zoomOut) {
            zoomOut.addEventListener('click', function () {
                map.zoomOut({ duration: 180 });
            });
        }
        if (zoomLevel) {
            zoomLevel.addEventListener('change', function () {
                map.zoomTo(Number(zoomLevel.value), { duration: 180 });
            });
        }
        if (fitLayer) {
            fitLayer.addEventListener('click', fitIncidentContext);
        }
        if (supportToggle) {
            supportToggle.addEventListener('click', function () {
                setSupportMode(supportToggle.getAttribute('aria-pressed') !== 'true');
            });
        }
        if (measureToggle) {
            measureToggle.addEventListener('click', function () {
                setMeasureMode(measureToggle.getAttribute('aria-pressed') !== 'true');
            });
        }
        if (measureClear) {
            measureClear.addEventListener('click', clearMeasure);
        }
        if (resetNorth) {
            resetNorth.addEventListener('click', function () {
                map.rotateTo(0, { duration: 180 });
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
                coordinatePanel.classList.toggle('is-copy-enabled', coordinateClickCopy.checked);
            });
        }
    }

    function bindLayerCursor(layerId) {
        map.on('mouseenter', layerId, function () {
            map.getCanvas().style.cursor = 'pointer';
        });
        map.on('mouseleave', layerId, function () {
            if (!measureMode && !supportMode) {
                map.getCanvas().style.cursor = '';
            }
        });
    }

    function rasterStyle() {
        var basemap = selectedBasemap();
        var sources = {};
        var layers = [{
            id: layerIds.background,
            type: 'background',
            paint: {
                'background-color': basemap.background || '#183d66'
            }
        }];

        if (basemap.tilesUrl) {
            sources[sourceIds.basemap] = {
                type: 'raster',
                tiles: [basemap.tilesUrl],
                tileSize: 256,
                attribution: basemap.attribution || ''
            };
            layers.push({
                id: layerIds.basemap,
                type: 'raster',
                source: sourceIds.basemap,
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

    function selectedBasemap() {
        return basemaps[activeBasemapKey] || basemaps.osmLight || firstMapValue(basemaps) || {};
    }

    function firstMapValue(object) {
        var keys = Object.keys(object || {});
        return keys.length ? object[keys[0]] : null;
    }

    function applyBasemap(key) {
        if (!map || !basemaps[key]) {
            return;
        }
        activeBasemapKey = key;
        var basemap = selectedBasemap();

        if (map.getLayer(layerIds.basemap)) {
            map.removeLayer(layerIds.basemap);
        }
        if (map.getSource(sourceIds.basemap)) {
            map.removeSource(sourceIds.basemap);
        }
        if (map.getLayer(layerIds.background)) {
            map.setPaintProperty(layerIds.background, 'background-color', basemap.background || '#183d66');
        }
        if (basemap.tilesUrl) {
            map.addSource(sourceIds.basemap, {
                type: 'raster',
                tiles: [basemap.tilesUrl],
                tileSize: 256,
                attribution: basemap.attribution || ''
            });
            map.addLayer({
                id: layerIds.basemap,
                type: 'raster',
                source: sourceIds.basemap,
                paint: {
                    'raster-opacity': Number(basemap.opacity == null ? 1 : basemap.opacity)
                }
            }, firstOperationalLayerId());
        }
        setMapStatus(basemap.title + ' basemap selected.');
        updateBasemapCards();
    }

    function firstOperationalLayerId() {
        return [
            layerIds.corridorFill,
            layerIds.corridorOutline,
            layerIds.routes,
            layerIds.labels,
            layerIds.measureLine,
            layerIds.measurePoints,
            layerIds.incidents,
            layerIds.assets,
            layerIds.support,
            layerIds.coordinateMarker
        ].filter(function (id) {
            return map.getLayer(id);
        })[0];
    }

    function registerMapImages() {
        addMapImage('incident-default', createSymbolImage('#b91c1c', '!', 'diamond'));
        addMapImage('incident-weather', createSymbolImage('#2563eb', 'W', 'diamond'));
        addMapImage('incident-facility', createSymbolImage('#9333ea', 'F', 'diamond'));
        addMapImage('incident-utility', createSymbolImage('#16a34a', 'U', 'diamond'));
        addMapImage('incident-security', createSymbolImage('#475569', 'C', 'diamond'));
        addMapImage('incident-relief', createSymbolImage('#0891b2', '+', 'diamond'));
        addMapImage('incident-protection', createSymbolImage('#7f1d1d', 'S', 'diamond'));
        addMapImage('asset-critical-high', createSymbolImage('#1f7a8c', 'H', 'square'));
        addMapImage('asset-critical-medium', createSymbolImage('#0f766e', 'M', 'square'));
        addMapImage('support-fire', createSymbolImage('#ea580c', 'F', 'circle'));
        addMapImage('support-medical', createSymbolImage('#be123c', 'M', 'circle'));
        addMapImage('support-security', createSymbolImage('#475569', 'S', 'circle'));
        addMapImage('support-shelter', createSymbolImage('#2563eb', 'H', 'circle'));
        addMapImage('support-fuel', createSymbolImage('#ca8a04', 'G', 'circle'));
        addMapImage('support-air', createSymbolImage('#7c3aed', 'A', 'circle'));
        addMapImage('support-default', createSymbolImage('#0891b2', 'P', 'circle'));
    }

    function addMapImage(id, imageData) {
        if (typeof map.hasImage === 'function' && map.hasImage(id)) {
            return;
        }
        map.addImage(id, imageData, { pixelRatio: 2 });
    }

    function createSymbolImage(color, label, shape) {
        var canvas = document.createElement('canvas');
        var size = 72;
        var ctx;
        canvas.width = size;
        canvas.height = size;
        ctx = canvas.getContext('2d');
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
        } else if (shape === 'square') {
            roundedRect(ctx, 10, 10, 52, 52, 8);
        } else {
            ctx.arc(36, 36, 28, 0, Math.PI * 2);
        }
        ctx.fill();
        ctx.shadowColor = 'transparent';
        ctx.stroke();
        ctx.fillStyle = '#ffffff';
        ctx.font = 'bold 27px Arial';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.fillText(label, 36, 38);
        return ctx.getImageData(0, 0, size, size);
    }

    function roundedRect(ctx, x, y, width, height, radius) {
        ctx.moveTo(x + radius, y);
        ctx.lineTo(x + width - radius, y);
        ctx.quadraticCurveTo(x + width, y, x + width, y + radius);
        ctx.lineTo(x + width, y + height - radius);
        ctx.quadraticCurveTo(x + width, y + height, x + width - radius, y + height);
        ctx.lineTo(x + radius, y + height);
        ctx.quadraticCurveTo(x, y + height, x, y + height - radius);
        ctx.lineTo(x, y + radius);
        ctx.quadraticCurveTo(x, y, x + radius, y);
        ctx.closePath();
    }

    function ensureOperationalLayers() {
        map.addSource(sourceIds.corridor, corridorGeoJson());
        map.addLayer({
            id: layerIds.corridorFill,
            type: 'fill',
            source: sourceIds.corridor,
            filter: ['==', ['geometry-type'], 'Polygon'],
            paint: {
                'fill-color': '#38bdf8',
                'fill-opacity': 0.06
            }
        });
        map.addLayer({
            id: layerIds.corridorOutline,
            type: 'line',
            source: sourceIds.corridor,
            filter: ['==', ['geometry-type'], 'Polygon'],
            paint: {
                'line-color': '#38bdf8',
                'line-width': 2,
                'line-opacity': 0.7
            }
        });
        map.addLayer({
            id: layerIds.routes,
            type: 'line',
            source: sourceIds.corridor,
            filter: ['==', ['geometry-type'], 'LineString'],
            paint: {
                'line-color': ['match', ['get', 'route'], 'west', '#f59e0b', '#0f172a'],
                'line-width': 3,
                'line-opacity': 0.82,
                'line-dasharray': ['match', ['get', 'route'], 'west', ['literal', [2, 2]], ['literal', [1, 0]]]
            }
        });
        map.addSource(sourceIds.labels, {
            type: 'geojson',
            data: featureCollection(referenceLabels.map(function (label) {
                return {
                    type: 'Feature',
                    geometry: { type: 'Point', coordinates: label.coordinates },
                    properties: { name: label.name }
                };
            }))
        });
        map.addLayer({
            id: layerIds.labels,
            type: 'symbol',
            source: sourceIds.labels,
            layout: {
                'text-field': ['get', 'name'],
                'text-size': 12,
                'text-offset': [0, 1.15],
                'text-anchor': 'top',
                'text-allow-overlap': false
            },
            paint: {
                'text-color': '#0f172a',
                'text-halo-color': 'rgba(255, 255, 255, 0.9)',
                'text-halo-width': 1.5
            }
        });
        map.addSource(sourceIds.measure, emptyFeatureCollectionSource());
        map.addLayer({
            id: layerIds.measureLine,
            type: 'line',
            source: sourceIds.measure,
            filter: ['==', ['geometry-type'], 'LineString'],
            paint: {
                'line-color': '#7dd3fc',
                'line-width': 3,
                'line-dasharray': ['literal', [2, 1]]
            }
        });
        map.addLayer({
            id: layerIds.measurePoints,
            type: 'circle',
            source: sourceIds.measure,
            filter: ['==', ['geometry-type'], 'Point'],
            paint: {
                'circle-color': '#38bdf8',
                'circle-radius': 6,
                'circle-stroke-color': '#e0f2fe',
                'circle-stroke-width': 2
            }
        });
        addSymbolLayer(sourceIds.incidents, layerIds.incidents, ['get', '__incidentIcon'], 1.08);
        addSymbolLayer(sourceIds.assets, layerIds.assets, ['get', '__assetIcon'], 0.95);
        addSymbolLayer(sourceIds.support, layerIds.support, ['get', '__supportIcon'], 0.86);
        map.addSource(sourceIds.coordinateMarker, emptyFeatureCollectionSource());
        map.addLayer({
            id: layerIds.coordinateMarker,
            type: 'circle',
            source: sourceIds.coordinateMarker,
            paint: {
                'circle-radius': ['interpolate', ['linear'], ['zoom'], 6, 7, 12, 13],
                'circle-color': '#fbbf24',
                'circle-stroke-color': '#111827',
                'circle-stroke-width': 2
            }
        });
    }

    function addSymbolLayer(sourceId, layerId, iconImage, iconSize) {
        map.addSource(sourceId, emptyFeatureCollectionSource());
        map.addLayer({
            id: layerId,
            type: 'symbol',
            source: sourceId,
            layout: {
                'icon-image': iconImage,
                'icon-size': iconSize,
                'icon-allow-overlap': true,
                'icon-ignore-placement': true
            }
        });
    }

    function corridorGeoJson() {
        return {
            type: 'geojson',
            data: featureCollection([
                {
                    type: 'Feature',
                    geometry: {
                        type: 'Polygon',
                        coordinates: [[
                            [-107.15, 35.45],
                            [-104.1, 35.45],
                            [-104.1, 37.08],
                            [-107.15, 37.08],
                            [-107.15, 35.45]
                        ]]
                    },
                    properties: { name: 'Northern New Mexico operating area' }
                },
                {
                    type: 'Feature',
                    geometry: {
                        type: 'LineString',
                        coordinates: [
                            [-105.9378, 35.6870],
                            [-106.0806, 35.9911],
                            [-105.5733, 36.4070],
                            [-104.4389, 36.9028]
                        ]
                    },
                    properties: { route: 'north', name: 'Primary northbound response corridor' }
                },
                {
                    type: 'Feature',
                    geometry: {
                        type: 'LineString',
                        coordinates: [
                            [-105.9378, 35.6870],
                            [-106.3050, 35.8891],
                            [-106.5791, 36.9037]
                        ]
                    },
                    properties: { route: 'west', name: 'Western utility patrol corridor' }
                }
            ])
        };
    }

    function emptyFeatureCollectionSource() {
        return {
            type: 'geojson',
            data: featureCollection([])
        };
    }

    function featureCollection(features) {
        return {
            type: 'FeatureCollection',
            features: features || []
        };
    }

    function loadIncidentContext() {
        var radius = Number(radiusEl.value || config.radiusKm || 220);
        var params = new URLSearchParams({
            latitude: String(initialPoint.latitude),
            longitude: String(initialPoint.longitude),
            radius_km: String(radius),
            max_incidents: String(config.maxIncidents || 20)
        });

        setWorkflowStatus('Loading');
        fetch(config.analyzeUrl + '?' + params.toString(), { credentials: 'same-origin' })
            .then(jsonResponse)
            .then(function (payload) {
                latestPayload = payload;
                renderIncidentPanel(payload);
                renderMapContext(payload);
                updateLayerCounts(payload);
                setWorkflowStatus('Ready');
                setMapStatus(payload.incident_count + ' incident(s), ' + payload.asset_count + ' asset(s), ' + payload.risk.level + ' risk.');
            })
            .catch(function (error) {
                setWorkflowStatus('Error');
                setMapStatus(error.message, true);
                summaryText.textContent = error.message;
                clearMapContext();
            });
    }

    function loadSupportContext(latitude, longitude, label) {
        var params = new URLSearchParams({
            latitude: String(latitude),
            longitude: String(longitude),
            radius_m: String(supportRadiusM),
            max_results: '12'
        });

        supportPoisEl.innerHTML = '';
        supportPoisEl.appendChild(renderEmpty('Looking for support within ' + Math.round(supportRadiusM / 1000) + ' km of ' + label + '.'));
        updateSupportCount({ nearby_support: [] });
        setMapStatus('Looking up nearby support around ' + label + '.');

        fetch(config.supportUrl + '?' + params.toString(), { credentials: 'same-origin' })
            .then(jsonResponse)
            .then(function (payload) {
                var suffix = payload.message ? ' Fallback data is shown.' : '';
                renderSupportContext(payload, label);
                setMapStatus(payload.poi_count + ' support point(s) near ' + label + ' from ' + supportSourceLabel(payload) + '.' + suffix);
            })
            .catch(function (error) {
                clearSupportContext();
                supportPoisEl.innerHTML = '';
                supportPoisEl.appendChild(renderEmpty(error.message));
                setMapStatus(error.message, true);
            });
    }

    function jsonResponse(response) {
        return response.json().then(function (payload) {
            if (!response.ok) {
                throw new Error(payload.message || payload.detail || 'Request failed');
            }
            return payload;
        });
    }

    function renderIncidentPanel(payload) {
        summaryText.textContent = payload.operator_summary;
        riskEl.textContent = 'Risk: ' + payload.risk.level + ' (' + payload.risk.score + ')';
        riskEl.className = 'risk ' + payload.risk.level;
        renderRiskBreakdown(payload);

        actionsEl.innerHTML = '';
        (payload.recommended_actions || []).forEach(function (action) {
            var item = document.createElement('li');
            item.textContent = action;
            actionsEl.appendChild(item);
        });

        incidentsEl.innerHTML = '';
        (payload.nearby_incidents || []).forEach(function (incident) {
            incidentsEl.appendChild(renderIncidentItem(incident));
        });
        if (!(payload.nearby_incidents || []).length) {
            incidentsEl.appendChild(renderEmpty('No incidents inside radius.'));
        }

        assetsEl.innerHTML = '';
        (payload.nearby_assets || []).forEach(function (asset) {
            assetsEl.appendChild(renderAssetItem(asset));
        });
        if (!(payload.nearby_assets || []).length) {
            assetsEl.appendChild(renderEmpty('No critical assets inside radius.'));
        }
    }

    function renderSupportPanel(payload, label) {
        var points;
        supportPoisEl.innerHTML = '';
        if (!payload) {
            supportPoisEl.appendChild(renderEmpty('Select an incident or turn on POI mode, then click the map.'));
            return;
        }

        points = payload.nearby_support || [];
        if (!points.length) {
            supportPoisEl.appendChild(renderEmpty('No support points found within ' + Math.round(supportRadiusM / 1000) + ' km of ' + label + '.'));
            return;
        }

        points.forEach(function (poi) {
            supportPoisEl.appendChild(renderSupportItem(poi));
        });
    }

    function renderRiskBreakdown(payload) {
        var risk = payload.risk || {};
        var closestIncident = payload.nearby_incidents && payload.nearby_incidents.length
            ? payload.nearby_incidents[0].distance_km + ' km closest incident'
            : 'No incident proximity bonus';
        var rows = [
            {
                label: 'Incident severity score',
                note: 'Low 1, medium 2, high 3, critical 4 for incidents inside radius.',
                value: Number(risk.incident_score || 0)
            },
            {
                label: 'Asset criticality score',
                note: 'Low 1, medium 2, high 3, critical 4 for nearby assets.',
                value: Number(risk.asset_score || 0)
            },
            {
                label: 'Proximity bonus',
                note: '+2 when the closest incident is within 1 km. ' + closestIncident + '.',
                value: Number(risk.proximity_bonus || 0)
            },
            {
                label: 'Total risk score',
                note: 'High 10+, medium 5-9, low 1-4, none 0.',
                value: Number(risk.score || 0)
            }
        ];

        riskBreakdownEl.innerHTML = '';
        rows.forEach(function (row) {
            var element = document.createElement('div');
            element.className = 'score-row';
            element.innerHTML = '<div><span class="score-label"></span><span class="score-note"></span></div><span class="score-value"></span>';
            element.querySelector('.score-label').textContent = row.label;
            element.querySelector('.score-note').textContent = row.note;
            element.querySelector('.score-value').textContent = row.value;
            riskBreakdownEl.appendChild(element);
        });
    }

    function renderMapContext(payload) {
        setSourceData(sourceIds.incidents, featureCollection((payload.nearby_incidents || []).map(function (incident) {
            return {
                type: 'Feature',
                geometry: { type: 'Point', coordinates: [incident.longitude, incident.latitude] },
                properties: {
                    kind: 'incident',
                    id: incident.incident_id,
                    title: incident.title,
                    summary: incident.summary,
                    severity: incident.severity,
                    status: incident.status,
                    distance_km: incident.distance_km,
                    __incidentIcon: incidentIconForCategory(incident.category)
                }
            };
        })));
        setSourceData(sourceIds.assets, featureCollection((payload.nearby_assets || []).map(function (asset) {
            return {
                type: 'Feature',
                geometry: { type: 'Point', coordinates: [asset.longitude, asset.latitude] },
                properties: {
                    kind: 'asset',
                    id: asset.asset_id,
                    name: asset.name,
                    asset_type: asset.asset_type,
                    criticality: asset.criticality,
                    distance_km: asset.distance_km,
                    __assetIcon: assetIconForCriticality(asset.criticality)
                }
            };
        })));
    }

    function renderSupportContext(payload, label) {
        latestSupportPayload = payload;
        setSourceData(sourceIds.support, featureCollection((payload.nearby_support || []).map(function (poi) {
            return {
                type: 'Feature',
                geometry: { type: 'Point', coordinates: [poi.longitude, poi.latitude] },
                properties: {
                    kind: 'support',
                    id: poi.poi_id,
                    name: poi.name,
                    category: poi.category,
                    distance_km: poi.distance_km,
                    source: poi.source,
                    __supportIcon: supportIconForCategory(poi.category)
                }
            };
        })));
        renderSupportPanel(payload, label);
        updateSupportCount(payload);
    }

    function clearMapContext() {
        setSourceData(sourceIds.incidents, featureCollection([]));
        setSourceData(sourceIds.assets, featureCollection([]));
        clearSupportContext();
        updateLayerCounts({ nearby_incidents: [], nearby_assets: [] });
    }

    function clearSupportContext() {
        latestSupportPayload = null;
        setSourceData(sourceIds.support, featureCollection([]));
        renderSupportPanel(null);
        updateSupportCount(null);
    }

    function setSourceData(sourceId, data) {
        var source;
        if (!map) {
            return;
        }
        source = map.getSource(sourceId);
        if (source) {
            source.setData(data);
        }
    }

    function handleMapClick(event) {
        updateCoordinateReadout(event.lngLat);

        if (measureMode) {
            addMeasurePoint(event.lngLat);
            return;
        }

        if (supportMode) {
            setCoordinateMarker(event.lngLat);
            loadSupportContext(event.lngLat.lat, event.lngLat.lng, 'map point');
            return;
        }

        var feature = firstFeatureAt(event.point, [layerIds.incidents, layerIds.assets, layerIds.support]);
        if (feature) {
            showFeaturePopup(feature, event.lngLat);
            return;
        }

        setCoordinateMarker(event.lngLat);
        if (coordinateClickCopy.checked) {
            copyCoordinateAt(event.lngLat);
        }
    }

    function firstFeatureAt(point, layers) {
        var activeLayers;
        if (!map || !map.isStyleLoaded()) {
            return null;
        }
        activeLayers = layers.filter(function (id) {
            return map.getLayer(id);
        });
        if (!activeLayers.length) {
            return null;
        }
        return map.queryRenderedFeatures(point, { layers: activeLayers })[0] || null;
    }

    function showFeaturePopup(feature, lngLat) {
        new maplibregl.Popup({
            closeButton: true,
            closeOnClick: true,
            className: 'geo-map-feature-popup'
        })
            .setLngLat(lngLat)
            .setHTML(featurePopup(feature.properties))
            .addTo(map);
    }

    function featurePopup(properties) {
        if (properties.kind === 'incident') {
            return incidentPopup(properties);
        }
        if (properties.kind === 'support') {
            return supportPopup(properties);
        }
        return assetPopup(properties);
    }

    function incidentPopup(properties) {
        return '<div class="geo-map-popup-title">' + escapeHtml(properties.title) + '</div>' +
            '<dl class="geo-map-popup">' +
            '<dt>Severity</dt><dd>' + escapeHtml(properties.severity) + '</dd>' +
            '<dt>Status</dt><dd>' + escapeHtml(properties.status) + '</dd>' +
            '<dt>Distance</dt><dd>' + escapeHtml(properties.distance_km) + ' km</dd>' +
            '<dt>Summary</dt><dd>' + escapeHtml(properties.summary) + '</dd>' +
            '</dl>';
    }

    function assetPopup(properties) {
        return '<div class="geo-map-popup-title">' + escapeHtml(properties.name) + '</div>' +
            '<dl class="geo-map-popup">' +
            '<dt>Type</dt><dd>' + escapeHtml(String(properties.asset_type || '').replace('_', ' ')) + '</dd>' +
            '<dt>Criticality</dt><dd>' + escapeHtml(properties.criticality) + '</dd>' +
            '<dt>Distance</dt><dd>' + escapeHtml(properties.distance_km) + ' km</dd>' +
            '</dl>';
    }

    function supportPopup(properties) {
        return '<div class="geo-map-popup-title">' + escapeHtml(properties.name) + '</div>' +
            '<dl class="geo-map-popup">' +
            '<dt>Type</dt><dd>' + escapeHtml(supportCategoryLabel(properties.category)) + '</dd>' +
            '<dt>Source</dt><dd>' + escapeHtml(supportSourceLabel({ source: properties.source })) + '</dd>' +
            '<dt>Distance</dt><dd>' + escapeHtml(properties.distance_km) + ' km</dd>' +
            '</dl>';
    }

    function renderIncidentItem(incident) {
        var element = document.createElement('button');
        element.type = 'button';
        element.className = 'result-item result-item-button';
        element.innerHTML = '<h3></h3><p></p><div class="meta"></div>';
        element.querySelector('h3').textContent = incident.title;
        element.querySelector('p').textContent = incident.summary;
        element.querySelector('.meta').textContent = incident.severity + ' severity - ' + incident.status + ' - ' + incident.distance_km + ' km';
        element.addEventListener('click', function () {
            zoomToIncident(incident.incident_id);
        });
        return element;
    }

    function renderAssetItem(asset) {
        var element = document.createElement('article');
        element.className = 'result-item';
        element.innerHTML = '<h3></h3><p></p><div class="meta"></div>';
        element.querySelector('h3').textContent = asset.name;
        element.querySelector('p').textContent = String(asset.asset_type || '').replace('_', ' ');
        element.querySelector('.meta').textContent = asset.criticality + ' criticality - ' + asset.distance_km + ' km';
        return element;
    }

    function renderSupportItem(poi) {
        var element = document.createElement('button');
        element.type = 'button';
        element.className = 'result-item result-item-button';
        element.innerHTML = '<h3></h3><p></p><div class="meta"></div>';
        element.querySelector('h3').textContent = poi.name;
        element.querySelector('p').textContent = supportCategoryLabel(poi.category);
        element.querySelector('.meta').textContent = poi.distance_km + ' km - ' + supportSourceLabel({ source: poi.source });
        element.addEventListener('click', function () {
            zoomToSupport(poi.poi_id);
        });
        return element;
    }

    function renderEmpty(message) {
        var element = document.createElement('div');
        element.className = 'result-item';
        element.textContent = message;
        return element;
    }

    function zoomToIncident(incidentId) {
        var incident;
        if (!latestPayload) {
            return;
        }
        incident = (latestPayload.nearby_incidents || []).filter(function (item) {
            return item.incident_id === incidentId;
        })[0];
        if (!incident) {
            return;
        }
        map.flyTo({
            center: [incident.longitude, incident.latitude],
            zoom: Math.max(11, map.getZoom()),
            essential: true
        });
        new maplibregl.Popup({
            className: 'geo-map-feature-popup',
            closeOnClick: true
        })
            .setLngLat([incident.longitude, incident.latitude])
            .setHTML(incidentPopup({
                title: incident.title,
                severity: incident.severity,
                status: incident.status,
                distance_km: incident.distance_km,
                summary: incident.summary
            }))
            .addTo(map);
        setCoordinateMarker({ lng: incident.longitude, lat: incident.latitude });
        loadSupportContext(incident.latitude, incident.longitude, incident.title);
        setMapStatus('Zoomed to ' + incident.title + '.');
    }

    function zoomToSupport(poiId) {
        var poi;
        if (!latestSupportPayload) {
            return;
        }
        poi = (latestSupportPayload.nearby_support || []).filter(function (item) {
            return item.poi_id === poiId;
        })[0];
        if (!poi) {
            return;
        }
        map.flyTo({
            center: [poi.longitude, poi.latitude],
            zoom: Math.max(12, map.getZoom()),
            essential: true
        });
        new maplibregl.Popup({
            className: 'geo-map-feature-popup',
            closeOnClick: true
        })
            .setLngLat([poi.longitude, poi.latitude])
            .setHTML(supportPopup({
                name: poi.name,
                category: poi.category,
                source: poi.source,
                distance_km: poi.distance_km
            }))
            .addTo(map);
        setMapStatus('Zoomed to ' + poi.name + '.');
    }

    function setLayerDrawerOpen(open) {
        layerDrawer.hidden = !open;
        layerToggle.classList.toggle('is-active', open);
        layerToggle.setAttribute('aria-expanded', open ? 'true' : 'false');
    }

    function setLayerVisibility(layerId, visible) {
        if (!map || !map.getLayer(layerId)) {
            return;
        }
        map.setLayoutProperty(layerId, 'visibility', visible ? 'visible' : 'none');
    }

    function updateLayerCounts(payload) {
        incidentLayerStatus.textContent = String((payload.nearby_incidents || []).length);
        assetLayerStatus.textContent = String((payload.nearby_assets || []).length);
        updateSupportCount(latestSupportPayload);
    }

    function updateSupportCount(payload) {
        supportLayerStatus.textContent = String(((payload || {}).nearby_support || []).length);
    }

    function incidentIconForCategory(category) {
        var value = String(category || '').toLowerCase();
        if (value.indexOf('weather') >= 0) {
            return 'incident-weather';
        }
        if (value.indexOf('utility') >= 0) {
            return 'incident-utility';
        }
        if (value.indexOf('transport') >= 0) {
            return 'incident-facility';
        }
        if (value.indexOf('communication') >= 0) {
            return 'incident-security';
        }
        if (value.indexOf('disaster') >= 0 || value.indexOf('relief') >= 0) {
            return 'incident-relief';
        }
        if (value.indexOf('force') >= 0 || value.indexOf('protection') >= 0 || value.indexOf('security') >= 0) {
            return 'incident-protection';
        }
        return 'incident-default';
    }

    function assetIconForCriticality(criticality) {
        return String(criticality || '').toLowerCase() === 'high' ? 'asset-critical-high' : 'asset-critical-medium';
    }

    function supportIconForCategory(category) {
        var value = String(category || '').toLowerCase();
        if (value === 'fire') {
            return 'support-fire';
        }
        if (value === 'medical') {
            return 'support-medical';
        }
        if (value === 'security') {
            return 'support-security';
        }
        if (value === 'shelter') {
            return 'support-shelter';
        }
        if (value === 'fuel') {
            return 'support-fuel';
        }
        if (value === 'air') {
            return 'support-air';
        }
        return 'support-default';
    }

    function supportCategoryLabel(category) {
        var labels = {
            air: 'Aviation support',
            fire: 'Fire / emergency response',
            fuel: 'Fuel access',
            medical: 'Medical support',
            security: 'Security / law enforcement',
            shelter: 'Shelter / assembly',
            support: 'Operational support'
        };
        return labels[String(category || '').toLowerCase()] || labels.support;
    }

    function supportSourceLabel(payload) {
        return payload && payload.source === 'openstreetmap_overpass' ? 'OpenStreetMap' : 'local fallback';
    }

    function fitIncidentContext() {
        var coordinates = [];
        if (latestPayload) {
            (latestPayload.nearby_incidents || []).forEach(function (incident) {
                coordinates.push([incident.longitude, incident.latitude]);
            });
            (latestPayload.nearby_assets || []).forEach(function (asset) {
                coordinates.push([asset.longitude, asset.latitude]);
            });
        }
        if (latestSupportPayload) {
            (latestSupportPayload.nearby_support || []).forEach(function (poi) {
                coordinates.push([poi.longitude, poi.latitude]);
            });
        }
        if (!coordinates.length) {
            map.fitBounds(corridorBounds, { padding: 38, duration: 250 });
            return;
        }
        var bounds = coordinates.reduce(function (acc, coordinate) {
            return acc.extend(coordinate);
        }, new maplibregl.LngLatBounds(coordinates[0], coordinates[0]));
        map.fitBounds(bounds, { padding: 72, maxZoom: 11, duration: 300 });
    }

    function populateZoomOptions() {
        var zoom;
        zoomLevel.innerHTML = '';
        for (zoom = minZoom; zoom <= maxZoom; zoom += 1) {
            var option = document.createElement('option');
            option.value = String(zoom);
            option.textContent = String(zoom);
            zoomLevel.appendChild(option);
        }
    }

    function updateZoomLevelControl() {
        if (!map) {
            return;
        }
        zoomLevel.value = String(Math.round(map.getZoom()));
    }

    function updateNorthArrow() {
        if (!map || !northArrowIndicator) {
            return;
        }
        northArrowIndicator.style.transform = 'rotate(' + (-map.getBearing()) + 'deg)';
    }

    function setSupportMode(enabled) {
        supportMode = enabled;
        if (supportMode && measureMode) {
            setMeasureMode(false);
        }
        supportToggle.classList.toggle('is-active', supportMode);
        supportToggle.setAttribute('aria-pressed', supportMode ? 'true' : 'false');
        supportToggle.title = supportMode ? 'Stop finding support' : 'Find nearby support';
        map.getCanvas().style.cursor = supportMode ? 'crosshair' : '';
        setMapStatus(supportMode ? 'POI support mode active. Click the map to find nearby support.' : 'POI support mode off.');
    }

    function setMeasureMode(enabled) {
        measureMode = enabled;
        if (measureMode && supportMode) {
            setSupportMode(false);
        }
        measureToggle.classList.toggle('is-active', measureMode);
        measureToggle.setAttribute('aria-pressed', measureMode ? 'true' : 'false');
        measureToggle.setAttribute('aria-expanded', measureMode ? 'true' : 'false');
        measureToggle.title = measureMode ? 'Stop measuring' : 'Measure distance';
        measurePanel.hidden = !measureMode;
        map.getCanvas().style.cursor = measureMode ? 'crosshair' : '';
        setMapStatus(measureMode ? 'Measure mode active. Click points on the map.' : 'Measure mode off.');
    }

    function addMeasurePoint(lngLat) {
        measurePoints.push([lngLat.lng, lngLat.lat]);
        updateMeasureGraphics();
    }

    function updateMeasureGraphics() {
        var features = measurePoints.map(function (point) {
            return {
                type: 'Feature',
                geometry: { type: 'Point', coordinates: point },
                properties: {}
            };
        });
        if (measurePoints.length > 1) {
            features.push({
                type: 'Feature',
                geometry: { type: 'LineString', coordinates: measurePoints },
                properties: {}
            });
        }
        setSourceData(sourceIds.measure, featureCollection(features));
        measureOutput.textContent = formatDistance(lineMeters(measurePoints));
    }

    function clearMeasure() {
        measurePoints = [];
        updateMeasureGraphics();
    }

    function lineMeters(points) {
        var meters = 0;
        var i;
        for (i = 1; i < points.length; i += 1) {
            meters += distanceMeters(points[i - 1], points[i]);
        }
        return meters;
    }

    function distanceMeters(a, b) {
        var earthRadius = 6371008.8;
        var lat1 = toRadians(a[1]);
        var lat2 = toRadians(b[1]);
        var deltaLat = toRadians(b[1] - a[1]);
        var deltaLon = toRadians(b[0] - a[0]);
        var haversine = Math.sin(deltaLat / 2) * Math.sin(deltaLat / 2) +
            Math.cos(lat1) * Math.cos(lat2) * Math.sin(deltaLon / 2) * Math.sin(deltaLon / 2);
        return earthRadius * 2 * Math.atan2(Math.sqrt(haversine), Math.sqrt(1 - haversine));
    }

    function formatDistance(meters) {
        var miles = meters / 1609.344;
        if (miles < 0.1) {
            return Math.round(meters * 3.28084) + ' ft';
        }
        return miles.toFixed(2) + ' mi';
    }

    function toRadians(value) {
        return value * Math.PI / 180;
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
        var lat = lngLat.lat.toFixed(6);
        var lng = lngLat.lng.toFixed(6);
        var mgrsValue = 'Unavailable';
        if (window.mgrs && typeof window.mgrs.forward === 'function') {
            mgrsValue = window.mgrs.forward([lngLat.lng, lngLat.lat], 5);
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

    function setCoordinateMarker(lngLat) {
        setSourceData(sourceIds.coordinateMarker, featureCollection([
            {
                type: 'Feature',
                geometry: { type: 'Point', coordinates: [lngLat.lng, lngLat.lat] },
                properties: {}
            }
        ]));
    }

    function copyCoordinateAt(lngLat) {
        var value = formatCoordinate(lngLat)[coordinateFormat.value] || '';
        if (!navigator.clipboard) {
            setMapStatus('Coordinate copy was blocked by the browser.', true);
            return;
        }
        navigator.clipboard.writeText(value)
            .then(function () {
                flashCoordinateCopied();
                setMapStatus('Copied ' + coordinateFormat.value.toUpperCase() + ' coordinate.');
            })
            .catch(function () {
                setMapStatus('Coordinate copy was blocked by the browser.', true);
            });
    }

    function flashCoordinateCopied() {
        coordinatePanel.classList.add('is-copied');
        window.setTimeout(function () {
            coordinatePanel.classList.remove('is-copied');
        }, 850);
    }

    function updateMapCursor(point) {
        if (supportMode) {
            map.getCanvas().style.cursor = 'crosshair';
            return;
        }
        var feature = firstFeatureAt(point, [layerIds.incidents, layerIds.assets, layerIds.support]);
        map.getCanvas().style.cursor = feature ? 'pointer' : '';
    }

    function setWorkflowStatus(message) {
        statusEl.textContent = message;
    }

    function setMapStatus(message, isError) {
        mapStatusMessage.textContent = message;
        mapStatusEl.className = isError ? 'geo-map-status geo-map-status-error' : 'geo-map-status';
    }

    function initBasemapCards() {
        updateBasemapCards();
        Array.prototype.forEach.call(document.querySelectorAll('.geo-basemap-card'), function (card) {
            var basemap = basemaps[card.getAttribute('data-basemap-key')] || selectedBasemap();
            card.style.setProperty('--basemap-preview', basemap.preview);
            if (basemap.previewImage) {
                card.style.setProperty('--basemap-preview-image', cssUrl(basemap.previewImage));
            }
        });
    }

    function updateBasemapCards() {
        var basemap = selectedBasemap();
        basemapToggleLabel.textContent = basemap.buttonLabel || basemap.title || 'Basemap';
        basemapToggle.style.setProperty('--basemap-preview', basemap.preview || basemap.background || '#183d66');
        if (basemap.previewImage) {
            basemapToggle.style.setProperty('--basemap-preview-image', cssUrl(basemap.previewImage));
        }
        Array.prototype.forEach.call(document.querySelectorAll('.geo-basemap-card'), function (card) {
            card.classList.toggle('is-active', card.getAttribute('data-basemap-key') === activeBasemapKey);
        });
    }

    function cssUrl(value) {
        return 'url("' + String(value).replace(/"/g, '\\"') + '")';
    }

    function escapeHtml(value) {
        return String(value == null ? '' : value)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#039;');
    }
})();
