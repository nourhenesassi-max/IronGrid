package com.example.irongrid.surveillance;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix = "app.surveillance")
public class SurveillanceProperties {

    private String providerName = "database";
    private String liveBaseUrl = "";
    private String archiveBaseUrl = "";

    public String getProviderName() {
        return providerName;
    }

    public void setProviderName(String providerName) {
        this.providerName = providerName;
    }

    public String getLiveBaseUrl() {
        return liveBaseUrl;
    }

    public void setLiveBaseUrl(String liveBaseUrl) {
        this.liveBaseUrl = liveBaseUrl;
    }

    public String getArchiveBaseUrl() {
        return archiveBaseUrl;
    }

    public void setArchiveBaseUrl(String archiveBaseUrl) {
        this.archiveBaseUrl = archiveBaseUrl;
    }

    public boolean isProviderConfigured() {
        return hasText(liveBaseUrl) || hasText(archiveBaseUrl);
    }

    public String getSourceMessage() {
        if (isProviderConfigured()) {
            return "Supervision connectee au fournisseur " + providerName
                    + ". Les DVR, cameras et archives affiches par IronGrid viennent de la base de donnees "
                    + "et se resynchronisent automatiquement avec le backend.";
        }
        return "Backend supervision actif. Les DVR, cameras et archives affiches proviennent de la base "
                + "de donnees IronGrid. Renseigne app.surveillance.live-base-url et/ou "
                + "app.surveillance.archive-base-url puis les vraies URLs/API DVR pour passer aux flux reels.";
    }

    private boolean hasText(String value) {
        return value != null && !value.trim().isEmpty();
    }
}
