package com.example.irongrid.surveillance;

import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "camera_recordings")
public class CameraRecording {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 180)
    private String title;

    @Column(nullable = false, length = 80)
    private String triggerType = "manual";

    @Column(nullable = false)
    private LocalDateTime startedAt;

    @Column(nullable = false)
    private LocalDateTime endedAt;

    @Column(length = 1000)
    private String archiveUrl;

    @Column(nullable = false)
    private Long sizeBytes = 0L;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "camera_id", nullable = false)
    private CameraFeed camera;

    public Long getId() {
        return id;
    }

    public String getTitle() {
        return title;
    }

    public String getTriggerType() {
        return triggerType;
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

    public CameraFeed getCamera() {
        return camera;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public void setTriggerType(String triggerType) {
        this.triggerType = triggerType;
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

    public void setCamera(CameraFeed camera) {
        this.camera = camera;
    }
}
