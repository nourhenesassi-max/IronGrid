package com.example.irongrid.surveillance.dto;

import java.util.ArrayList;
import java.util.List;

public class CameraDvrRequest {
    private String id;
    private String name;
    private String site;
    private String ipAddress;
    private Integer port;
    private String status;
    private String protocol;
    private String streamProfile;
    private String notes;
    private List<CameraFeedRequest> cameras = new ArrayList<>();

    public String getId() {
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

    public List<CameraFeedRequest> getCameras() {
        return cameras;
    }

    public void setId(String id) {
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

    public void setCameras(List<CameraFeedRequest> cameras) {
        this.cameras = cameras;
    }
}