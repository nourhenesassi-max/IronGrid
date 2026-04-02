package com.example.irongrid.surveillance;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "camera_dvrs")
public class CameraDvr {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String site;

    @Column(nullable = false)
    private String ipAddress;

    @Column(nullable = false)
    private Integer port = 554;

    @Column(nullable = false)
    private String status = "offline";

    @Column(nullable = false)
    private String protocol = "RTSP";

    @Column(nullable = false)
    private String streamProfile = "Full HD";

    @Column(length = 1000)
    private String notes;

    @Column(nullable = false)
    private LocalDateTime updatedAt;

    @OneToMany(
            mappedBy = "dvr",
            cascade = CascadeType.ALL,
            orphanRemoval = true,
            fetch = FetchType.LAZY
    )
    @OrderBy("channel ASC")
    private List<CameraFeed> cameras = new ArrayList<>();

    @PrePersist
    @PreUpdate
    public void touchUpdatedAt() {
        this.updatedAt = LocalDateTime.now();
    }

    public void addCamera(CameraFeed camera) {
        camera.setDvr(this);
        this.cameras.add(camera);
    }

    public void clearCameras() {
        for (CameraFeed camera : cameras) {
            camera.setDvr(null);
        }
        cameras.clear();
    }

    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public String getSite() {
        return site;
    }

    public String getIpAddress() {
        return ipAddress;
    }

    public Integer getPort() {
        return port;
    }

    public String getStatus() {
        return status;
    }

    public String getProtocol() {
        return protocol;
    }

    public String getStreamProfile() {
        return streamProfile;
    }

    public String getNotes() {
        return notes;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public List<CameraFeed> getCameras() {
        return cameras;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setSite(String site) {
        this.site = site;
    }

    public void setIpAddress(String ipAddress) {
        this.ipAddress = ipAddress;
    }

    public void setPort(Integer port) {
        this.port = port;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public void setProtocol(String protocol) {
        this.protocol = protocol;
    }

    public void setStreamProfile(String streamProfile) {
        this.streamProfile = streamProfile;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public void setCameras(List<CameraFeed> cameras) {
        this.cameras = cameras;
    }
}
