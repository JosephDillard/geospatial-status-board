(function () {
    var page = document.querySelector('.incident-analyst-page');
    if (!page) {
        return;
    }

    var api = null;
    var config = {};
    var selectedIncident = null;
    var supportSourceId = 'incident-analyst-support-source';
    var supportLayerId = 'incident-analyst-support-points';
    var supportFeatures = [];
    var assetLayerKeys = [
        'airportStatus',
        'currentSIT',
        'airfieldSurfaceStatus',
        'engineerAssets',
        'fireFightingAssets',
        'utilityStatus',
        'navaid'
    ];

    var summaryText = document.getElementById('summaryText');
    var riskEl = document.getElementById('risk');
    var riskBreakdownEl = document.getElementById('riskBreakdown');
    var selectedIncidentEl = document.getElementById('selectedIncident');
    var actionsEl = document.getElementById('actions');
    var supportPoisEl = document.getElementById('supportPois');
    var incidentsEl = document.getElementById('incidents');

    bindWindowEvents();
    if (window.geoStatusBoardMap) {
        bindMapApi(window.geoStatusBoardMap);
    }

    function bindWindowEvents() {
        window.addEventListener('geoStatusBoard:apiReady', function (event) {
            bindMapApi(event.detail);
        });
        window.addEventListener('geoStatusBoard:ready', function (event) {
            bindMapApi(event.detail);
            renderFromSharedMap();
        });
        window.addEventListener('geoStatusBoard:currentIncidentsUpdated', function (event) {
            renderFromSharedMap(event.detail && event.detail.features);
        });
        window.addEventListener('geoStatusBoard:featureSelected', function (event) {
            var detail = event.detail || {};
            if (detail.key === 'currentIncidents' && detail.feature) {
                selectIncident(detail.feature, true);
            }
        });
    }

    function bindMapApi(nextApi) {
        if (!nextApi || !nextApi.map) {
            return;
        }
        api = nextApi;
        config = nextApi.incidentAnalystConfig || (nextApi.config || {}).incidentAnalyst || {};
        if (api.map.loaded && api.map.loaded()) {
            ensureSupportLayer();
        } else if (api.map.on) {
            api.map.on('load', ensureSupportLayer);
        }
        renderFromSharedMap();
    }

    function renderFromSharedMap(features) {
        if (!api) {
            renderEmpty('Waiting for the shared map to finish loading.');
            return;
        }
        var incidents = features || api.getCurrentIncidentFeatures();
        var assets = currentAssetFeatures();
        var analysis = analyzeIncidents(incidents, assets);

        renderSummary(analysis);
        renderRiskBreakdown(analysis);
        renderActions(analysis);
        renderIncidentList(incidents);
        if (!selectedIncident) {
            renderSelectedIncident(null);
        }
    }

    function renderEmpty(message) {
        if (summaryText) {
            summaryText.textContent = message;
        }
        if (riskEl) {
            riskEl.className = 'risk none';
            riskEl.textContent = 'Risk: none';
        }
        if (riskBreakdownEl) {
            riskBreakdownEl.innerHTML = '';
        }
        if (incidentsEl) {
            incidentsEl.textContent = '';
        }
    }

    function analyzeIncidents(incidents, assets) {
        var scoredIncidents = incidents.map(function (feature) {
            return {
                feature: feature,
                score: incidentSeverityScore(feature),
                title: incidentTitle(feature)
            };
        }).sort(function (a, b) {
            return b.score - a.score;
        });

        var assetScore = assetCriticalityScore(assets);
        var highestIncidentScore = scoredIncidents.length ? scoredIncidents[0].score : 0;
        var incidentCountBonus = Math.min(4, Math.floor(scoredIncidents.length / 2));
        var total = highestIncidentScore + assetScore.score + incidentCountBonus;
        var level = total >= 11 ? 'high' : total >= 6 ? 'medium' : scoredIncidents.length ? 'low' : 'none';

        return {
            incidents: incidents,
            assets: assets,
            scoredIncidents: scoredIncidents,
            incidentScore: highestIncidentScore,
            assetScore: assetScore.score,
            assetReason: assetScore.reason,
            incidentCountBonus: incidentCountBonus,
            total: total,
            level: level
        };
    }

    function currentAssetFeatures() {
        if (!api || !api.getLayerFeatures) {
            return [];
        }
        return assetLayerKeys.reduce(function (features, key) {
            return features.concat(api.getLayerFeatures(key) || []);
        }, []);
    }

    function propertyValue(properties, names) {
        var i;
        for (i = 0; i < names.length; i += 1) {
            if (properties[names[i]] != null && properties[names[i]] !== '') {
                return String(properties[names[i]]);
            }
        }
        return '';
    }

    function normalizedProperties(feature) {
        return feature && feature.properties ? feature.properties : {};
    }

    function incidentTitle(feature) {
        var properties = normalizedProperties(feature);
        return propertyValue(properties, ['event_name', 'eventName', 'EVENT_NAME', 'incident_id', 'incidentId', 'INCIDENT_ID']) || 'Current incident';
    }

    function incidentDescription(feature) {
        var properties = normalizedProperties(feature);
        return propertyValue(properties, ['event_desc', 'eventDesc', 'EVENT_DESC']) || 'No description provided.';
    }

    function incidentMeta(feature) {
        var properties = normalizedProperties(feature);
        var pieces = [
            propertyValue(properties, ['workflow_status', 'workflowStatus', 'WORKFLOW_STATUS']),
            propertyValue(properties, ['event_type', 'eventType', 'EVENT_TYPE']),
            propertyValue(properties, ['event_cat', 'eventCat', 'EVENT_CAT'])
        ].filter(Boolean);
        return pieces.join(' - ') || 'Current incident';
    }

    function incidentRecordId(feature) {
        var properties = normalizedProperties(feature);
        return propertyValue(properties, ['id', 'OBJECTID_1', 'objectid_1', 'objectId', 'objectid']);
    }

    function incidentSeverityScore(feature) {
        var properties = normalizedProperties(feature);
        var eventType = propertyValue(properties, ['event_type', 'eventType', 'EVENT_TYPE']).toLowerCase();
        var eventCat = propertyValue(properties, ['event_cat', 'eventCat', 'EVENT_CAT']).toLowerCase();
        var workflow = propertyValue(properties, ['workflow_status', 'workflowStatus', 'WORKFLOW_STATUS']).toLowerCase();
        var sigEvent = propertyValue(properties, ['sig_event', 'sigEvent', 'SIG_EVENT']).toLowerCase();
        var airOps = propertyValue(properties, ['air_ops_affected', 'airOpsAffected', 'AIR_OPS_AFFECTED']).toLowerCase();
        var text = [eventType, eventCat].join(' ');
        var score = 1;

        if (/cyber|security|force|uxo|suspicious|hazard|fire|smoke|aircraft|mishap|severe|utility|closure/.test(text)) {
            score += 3;
        } else if (/road|access|medical|communications|fuel|weather/.test(text)) {
            score += 2;
        }
        if (sigEvent === 'yes' || sigEvent === 'true') {
            score += 2;
        }
        if (airOps === 'yes' || airOps === 'true') {
            score += 1;
        }
        if (/new|active|open|in progress|triage/.test(workflow)) {
            score += 1;
        }
        if (/closed|resolved|archive/.test(workflow)) {
            score -= 2;
        }

        return Math.max(0, Math.min(score, 10));
    }

    function assetCriticalityScore(assets) {
        var best = 0;
        var reason = assets.length ? 'Loaded asset layers reviewed.' : 'No enabled asset layer features are loaded.';
        assets.forEach(function (feature) {
            var properties = normalizedProperties(feature);
            var values = Object.keys(properties).map(function (key) {
                return String(properties[key] || '').toLowerCase();
            }).join(' ');
            var score = 1;
            if (/critical|mission|closed|down|outage|damaged|failed|unavailable/.test(values)) {
                score = 4;
            } else if (/high|limited|degraded|warning|affected/.test(values)) {
                score = 3;
            } else if (/medium|partial|caution/.test(values)) {
                score = 2;
            }
            if (score > best) {
                best = score;
                reason = 'Highest loaded asset signal scored ' + score + ' from status/criticality fields.';
            }
        });
        return { score: best, reason: reason };
    }

    function renderSummary(analysis) {
        if (summaryText) {
            summaryText.textContent = analysis.incidents.length + ' current incident(s) and ' +
                analysis.assets.length + ' loaded asset feature(s) are being reviewed from the shared map layers.';
        }
        if (riskEl) {
            riskEl.className = 'risk ' + analysis.level;
            riskEl.textContent = 'Risk: ' + analysis.level + ' (' + analysis.total + ')';
        }
    }

    function renderRiskBreakdown(analysis) {
        if (!riskBreakdownEl) {
            return;
        }
        riskBreakdownEl.innerHTML = [
            scoreRow('Incident severity', analysis.incidentScore, 'Highest current-incident score from type, category, workflow, significant event, and operations fields.'),
            scoreRow('Asset criticality', analysis.assetScore, analysis.assetReason),
            scoreRow('Incident density', analysis.incidentCountBonus, 'Adds up to 4 points when multiple current incidents are loaded.'),
            scoreRow('Total', analysis.total, 'High >= 11, medium >= 6, low > 0.')
        ].join('');
    }

    function scoreRow(label, value, note) {
        return '<div class="score-row">' +
            '<div><span class="score-label">' + escapeHtml(label) + '</span>' +
            '<span class="score-note">' + escapeHtml(note) + '</span></div>' +
            '<span class="score-value">' + escapeHtml(value) + '</span>' +
            '</div>';
    }

    function renderActions(analysis) {
        if (!actionsEl) {
            return;
        }
        actionsEl.innerHTML = '';
        var items = [];
        if (analysis.level === 'high') {
            items.push('Open the Kanban board and assign immediate review ownership.');
            items.push('Use the LLM widget with the current map extent for response notes.');
            items.push('Use Wiki or nearby support lookup to verify local context.');
        } else if (analysis.level === 'medium') {
            items.push('Review the table for stale workflow states and missing descriptions.');
            items.push('Check nearby support before moving the incident on the board.');
        } else if (analysis.level === 'low') {
            items.push('Validate plotted location and keep workflow status current.');
        } else {
            items.push('Enable or refresh Current Incidents to begin review.');
        }

        items.forEach(function (item) {
            var li = document.createElement('li');
            li.textContent = item;
            actionsEl.appendChild(li);
        });
    }

    function renderIncidentList(incidents) {
        if (!incidentsEl) {
            return;
        }
        incidentsEl.innerHTML = '';
        if (!incidents.length) {
            incidentsEl.textContent = 'No current incidents are loaded. Check GeoServer or create an incident from the map.';
            return;
        }

        incidents.slice(0, Number(config.maxIncidents || 20)).forEach(function (feature) {
            var button = document.createElement('button');
            button.type = 'button';
            button.className = 'result-item result-item-button';
            button.innerHTML = '<h3>' + escapeHtml(incidentTitle(feature)) + '</h3>' +
                '<p>' + escapeHtml(incidentDescription(feature)) + '</p>' +
                '<div class="meta">' + escapeHtml(incidentMeta(feature)) + ' - severity ' + incidentSeverityScore(feature) + '</div>';
            button.addEventListener('click', function () {
                selectIncident(feature, false);
            });
            incidentsEl.appendChild(button);
        });
    }

    function renderSelectedIncident(feature) {
        if (!selectedIncidentEl) {
            return;
        }
        if (!feature) {
            selectedIncidentEl.textContent = 'Select an incident from the map or list.';
            return;
        }
        var id = incidentRecordId(feature);
        var links = [];
        if (id && config.showUrlBase) {
            links.push('<a href="' + escapeHtml(String(config.showUrlBase).replace(/\/$/, '') + '/' + encodeURIComponent(id)) + '">Open incident</a>');
        }
        if (config.tableUrl) {
            links.push('<a href="' + escapeHtml(config.tableUrl) + '">Table</a>');
        }
        if (config.boardUrl) {
            links.push('<a href="' + escapeHtml(config.boardUrl) + '">Kanban</a>');
        }
        selectedIncidentEl.innerHTML = '<h3>' + escapeHtml(incidentTitle(feature)) + '</h3>' +
            '<p>' + escapeHtml(incidentDescription(feature)) + '</p>' +
            '<div class="meta">' + escapeHtml(incidentMeta(feature)) + '</div>' +
            '<div class="incident-analyst-action-row">' + links.join('') + '</div>';
    }

    function selectIncident(feature, fromMapClick) {
        selectedIncident = feature;
        renderSelectedIncident(feature);
        if (!fromMapClick && api) {
            if (api.focusIncidentFeature) {
                api.focusIncidentFeature(feature);
            }
            if (api.showFeaturePopup) {
                api.showFeaturePopup(feature, 'currentIncidents');
            }
        }
        fetchSupportForIncident(feature);
    }

    function fetchSupportForIncident(feature) {
        var coordinate = api && api.featureLngLat ? api.featureLngLat(feature) : null;
        if (!coordinate || !config.supportUrl || !window.fetch) {
            renderSupport([], 'Nearby support requires a point incident and the support bridge.');
            return;
        }

        var url = new URL(config.supportUrl, window.location.href);
        url.searchParams.set('latitude', String(coordinate.lat));
        url.searchParams.set('longitude', String(coordinate.lng));
        url.searchParams.set('radius_m', String(config.supportRadiusM || 20000));
        url.searchParams.set('max_results', '8');

        if (supportPoisEl) {
            supportPoisEl.textContent = 'Searching nearby support...';
        }

        fetch(url.toString(), {
            method: 'GET',
            credentials: 'same-origin',
            headers: { 'Accept': 'application/json' }
        }).then(function (response) {
            return response.json().then(function (body) {
                if (!response.ok) {
                    throw new Error(body.message || 'Support lookup failed.');
                }
                return body;
            });
        }).then(function (body) {
            renderSupport(body.nearby_support || [], body.message || body.source || '');
        }).catch(function (error) {
            renderSupport([], error.message);
        });
    }

    function renderSupport(points, message) {
        updateSupportLayer(points);
        if (!supportPoisEl) {
            return;
        }
        supportPoisEl.innerHTML = '';
        if (message) {
            var note = document.createElement('p');
            note.className = 'score-note';
            note.textContent = message;
            supportPoisEl.appendChild(note);
        }
        if (!points.length) {
            if (!message) {
                supportPoisEl.textContent = 'No nearby support points found.';
            }
            return;
        }
        points.forEach(function (point) {
            var button = document.createElement('button');
            button.type = 'button';
            button.className = 'result-item result-item-button';
            button.innerHTML = '<h3>' + escapeHtml(point.name || 'Support point') + '</h3>' +
                '<p>' + escapeHtml(point.category || 'support') + '</p>' +
                '<div class="meta">' + escapeHtml(point.distance_km || 0) + ' km - ' + escapeHtml(point.source || 'support') + '</div>';
            button.addEventListener('click', function () {
                zoomToSupport(point);
            });
            supportPoisEl.appendChild(button);
        });
    }

    function ensureSupportLayer() {
        if (!api || !api.map || !api.map.getSource) {
            return;
        }
        if (!api.map.getSource(supportSourceId)) {
            api.map.addSource(supportSourceId, {
                type: 'geojson',
                data: emptyFeatureCollection()
            });
        }
        if (!api.map.getLayer(supportLayerId)) {
            api.map.addLayer({
                id: supportLayerId,
                type: 'circle',
                source: supportSourceId,
                paint: {
                    'circle-color': '#ea580c',
                    'circle-radius': 7,
                    'circle-stroke-color': '#fff7ed',
                    'circle-stroke-width': 2
                }
            });
        }
    }

    function updateSupportLayer(points) {
        supportFeatures = (points || []).map(function (point) {
            return {
                type: 'Feature',
                geometry: {
                    type: 'Point',
                    coordinates: [Number(point.longitude), Number(point.latitude)]
                },
                properties: {
                    name: point.name,
                    category: point.category,
                    distance_km: point.distance_km,
                    source: point.source
                }
            };
        }).filter(function (feature) {
            return Number.isFinite(feature.geometry.coordinates[0]) && Number.isFinite(feature.geometry.coordinates[1]);
        });
        ensureSupportLayer();
        if (api && api.map && api.map.getSource && api.map.getSource(supportSourceId)) {
            api.map.getSource(supportSourceId).setData({
                type: 'FeatureCollection',
                features: supportFeatures
            });
        }
    }

    function zoomToSupport(point) {
        if (!api || !api.map) {
            return;
        }
        var lng = Number(point.longitude);
        var lat = Number(point.latitude);
        if (!Number.isFinite(lng) || !Number.isFinite(lat)) {
            return;
        }
        api.map.easeTo({
            center: [lng, lat],
            zoom: Math.max(api.map.getZoom(), 14),
            duration: 450,
            essential: true
        });
    }

    function emptyFeatureCollection() {
        return {
            type: 'FeatureCollection',
            features: []
        };
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
