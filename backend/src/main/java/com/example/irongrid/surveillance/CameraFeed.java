package com.example.irongrid.surveillance;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "camera_feeds")
public class CameraFeed {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String zone;

    @Column(nullable = false)
    private Integer channel;

    @Column(nullable = false)
    private Boolean isOnline = false;

    @Column(nullable = false)
    private Boolean recordingEnabled = false;

    @Column(nullable = false)
    private Boolean motionEnabled = false;

    @Column(nullable = false)
    private String resolution = "1920x1080";

    @Column(nullable = false)
    private Integer bitrateKbps = 0;

    @Column(nullable = false)
    private Integer latencyMs = 0;

    @Column(length = 1000)
    private String streamUrl;

    @Column(length = 1000)
    private String archiveUrl;

    @Column(length = 1000)
    private String previewImageUrl;

    @Column(nullable = false)
    private String streamType = "rtsp";

    @Column(nullable = false)
    private LocalDateTime lastHeartbeatAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "dvr_id", nullable = false)
    private CameraDvr dvr;

    @OneToMany(
            mappedBy = "camera",
            cascade = CascadeType.ALL,
            orphanRemoval = true,
            fetch = FetchType.LAZY
    )
    private List<CameraRecording> recordings = new ArrayList<>();

    @PrePersist
    public void initHeartbeat() {
        if (this.lastHeartbeatAt == null) {
            this.lastHeartbeatAt = LocalDateTime.now();
        }
    }

    public Long getId() {
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

    public CameraDvr getDvr() {
        return dvr;
    }

    public List<CameraRecording> getRecordings() {
        return recordings;
    }

    public void setId(Long id) {
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

    public void setDvr(CameraDvr dvr) {
        this.dvr = dvr;
    }

    public void setRecordings(List<CameraRecording> recordings) {
        this.recordings = recordings;
    }

    public void addRecording(CameraRecording recording) {
        recording.setCamera(this);
        this.recordings.add(recording);
    }

    public void clearRecordings() {
        for (CameraRecording recording : recordings) {
            recording.setCamera(null);
        }
        recordings.clear();
    }
}
