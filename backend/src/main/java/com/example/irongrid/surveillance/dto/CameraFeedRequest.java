package com.example.irongrid.surveillance.dto;

import java.time.LocalDateTime;

public class CameraFeedRequest {
    private String id;
    private String name;
    private String zone;
    private Integer channel;
    private Boolean isOnline;
    private Boolean recordingEnabled;
    private Boolean motionEnabled;
    private String resolution;
    private Integer bitrateKbps;
    private Integer latencyMs;
    private String streamUrl;
    private String archiveUrl;
    private String previewImageUrl;
    private String streamType;
    private LocalDateTime lastHeartbeatAt;

    public String getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public String getZone() {
        return zone;
    }

    public Integer getChannel() {
        return channel;
    }

    public Boolean getIsOnline() {
        return isOnline;
    }

    public Boolean getRecordingEnabled() {
        return recordingEnabled;
    }

    public Boolean getMotionEnabled() {
        return motionEnabled;
    }

    public String getResolution() {
        return resolution;
    }

    public Integer getBitrateKbps() {
        return bitrateKbps;
    }

    public Integer getLatencyMs() {
        return latencyMs;
    }

    public String getStreamUrl() {
        return streamUrl;
    }

    public String getArchiveUrl() {
        return archiveUrl;
    }

    public String getPreviewImageUrl() {
        return previewImageUrl;
    }

    public String getStreamType() {
        return streamType;
    }

    public LocalDateTime getLastHeartbeatAt() {
        return lastHeartbeatAt;
    }

    public void setId(String id) {
        this.id = id;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setZone(String zone) {
        this.zone = zone;
    }

    public void setChannel(Integer channel) {
        this.channel = channel;
    }

    public void setIsOnline(Boolean online) {
        isOnline = online;
    }

    public void setRecordingEnabled(Boolean recordingEnabled) {
        this.recordingEnabled = recordingEnabled;
    }

    public void setMotionEnabled(Boolean motionEnabled) {
        this.motionEnabled = motionEnabled;
    }

    public void setResolution(String resolution) {
        this.resolution = resolution;
    }

    public void setBitrateKbps(Integer bitrateKbps) {
        this.bitrateKbps = bitrateKbps;
    }

    public void setLatencyMs(Integer latencyMs) {
        this.latencyMs = latencyMs;
    }

    public void setStreamUrl(String streamUrl) {
        this.streamUrl = streamUrl;
    }

    public void setArchiveUrl(String archiveUrl) {
        this.archiveUrl = archiveUrl;
    }

    public void setPreviewImageUrl(String previewImageUrl) {
        this.previewImageUrl = previewImageUrl;
    }

    public void setStreamType(String streamType) {
        this.streamType = streamType;
    }

    public void setLastHeartbeatAt(LocalDateTime lastHeartbeatAt) {
        this.lastHeartbeatAt = lastHeartbeatAt;
    }
}