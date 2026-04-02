package com.example.irongrid.surveillance.dto;

import java.time.LocalDateTime;

public class CameraRecordingResponse {
    private String id;
    private String cameraId;
    private String cameraName;
    private String dvrId;
    private String dvrName;
    private String title;
    private String trigger;
    private LocalDateTime startedAt;
    private LocalDateTime endedAt;
    private String archiveUrl;
    private Long sizeBytes;
    private String sizeLabel;

    public String getId() {
        return id;
    }

    public String getCameraId() {
        return cameraId;
    }

    public String getCameraName() {
        return cameraName;
    }

    public String getDvrId() {
        return dvrId;
    }

    public String getDvrName() {
        return dvrName;
    }

    public String getTitle() {
        return title;
    }

    public String getTrigger() {
        return trigger;
    }

    public LocalDateTime getStartedAt() {
        return startedAt;
    }

    public LocalDateTime getEndedAt() {
        return endedAt;
    }

    public String getArchiveUrl() {
        return archiveUrl;
    }

    public Long getSizeBytes() {
        return sizeBytes;
    }

    public String getSizeLabel() {
        return sizeLabel;
    }

    public void setId(String id) {
        this.id = id;
    }

    public void setCameraId(String cameraId) {
        this.cameraId = cameraId;
    }

    public void setCameraName(String cameraName) {
        this.cameraName = cameraName;
    }

    public void setDvrId(String dvrId) {
        this.dvrId = dvrId;
    }

    public void setDvrName(String dvrName) {
        this.dvrName = dvrName;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public void setTrigger(String trigger) {
        this.trigger = trigger;
    }

    public void setStartedAt(LocalDateTime startedAt) {
        this.startedAt = startedAt;
    }

    public void setEndedAt(LocalDateTime endedAt) {
        this.endedAt = endedAt;
    }

    public void setArchiveUrl(String archiveUrl) {
        this.archiveUrl = archiveUrl;
    }

    public void setSizeBytes(Long sizeBytes) {
        this.sizeBytes = sizeBytes;
    }

    public void setSizeLabel(String sizeLabel) {
        this.sizeLabel = sizeLabel;
    }
}
