package gsb.airport

class AppChromeTagLib {
    static namespace = 'gsb'

    def bannerText = { attrs ->
        String slot = attrs.slot?.toString()
        String defaultText = attrs.defaultText?.toString() ?: ''
        out << html(AppBannerText.textFor(slot, defaultText))
    }

    def renderSecMess = { attrs ->
        out << html(AppBannerText.textFor('securityMessage', attrs.defaultText?.toString() ?: 'Emergency Management'))
    }

    def renderUseMess = { attrs ->
        out << html(AppBannerText.textFor('useMessage', attrs.defaultText?.toString() ?: 'Airport and airfield status dashboard'))
    }

    def renderVerMess = { attrs ->
        out << html(AppBannerText.textFor('versionMessage', attrs.defaultText?.toString() ?: 'GSB'))
    }

    def mapIcon = { attrs ->
        String label = attrs.label?.toString() ?: 'Map'
        out << '<span class="gsb-map-link-icon" aria-hidden="true"></span>' +
            "<span class=\"gsb-map-link-text\">${html(label)}</span>"
    }

    def quickLinks = { attrs ->
        List<AppQuickLink> links = AppQuickLink.activeLinks()
        if (!links) {
            return
        }

        Map<String, List<AppQuickLink>> grouped = links.groupBy { it.category ?: 'Resources' }
        String title = attrs.title?.toString() ?: AppBannerText.textFor('quickLinksTitle', 'Emergency Links')

        out << '<nav class="gsb-quick-links" aria-label="Emergency and GIS links">'
        out << '<details>'
        out << "<summary>${html(title)}</summary>"
        out << '<div class="gsb-quick-links-panel">'
        grouped.each { String category, List<AppQuickLink> categoryLinks ->
            out << '<section class="gsb-quick-links-group">'
            out << "<strong>${html(category)}</strong>"
            out << '<div class="gsb-quick-links-items">'
            categoryLinks.each { AppQuickLink link ->
                String target = link.openInNewWindow ? ' target="_blank" rel="noopener"' : ''
                String titleAttr = link.description ? " title=\"${html(link.description)}\"" : ''
                out << "<a href=\"${html(link.url)}\"${target}${titleAttr}>${html(link.label)}</a>"
            }
            out << '</div></section>'
        }
        out << '</div></details></nav>'
    }

    private static String html(String value) {
        (value ?: '')
            .replace('&', '&amp;')
            .replace('<', '&lt;')
            .replace('>', '&gt;')
            .replace('"', '&quot;')
            .replace("'", '&#39;')
    }
}
