package com.example.irongrid.surveillance.dto;

import java.util.ArrayList;
import java.util.List;

public class SurveillanceDashboardResponse {
    private List<CameraDvrResponse> dvrs = new ArrayList<>();
    private List<CameraFeedResponse> cameras = new ArrayList<>();
    private List<CameraRecordingResponse> recordings = new ArrayList<>();
    private boolean usingDemoData;
    private boolean providerConfigured;
    private String sourceMessage;

    public List<CameraDvrResponse> getDvrs() {
        return dvrs;
    }

    public List<CameraFeedResponse> getCameras() {
        return cameras;
    }

    public List<CameraRecordingResponse> getRecordings() {
        return recordings;
    }

    public boolean isUsingDemoData() {
        return usingDemoData;
    }

    public boolean isProviderConfigured() {
        return providerConfigured;
    }

    public String getSourceMessage() {
        return sourceMessage;
    }

    public void setDvrs(List<CameraDvrResponse> dvrs) {
        this.dvrs = dvrs;
    }

    public void setCameras(List<CameraFeedResponse> cameras) {
        this.cameras = cameras;
    }

    public void setRecordings(List<CameraRecordingResponse> recordings) {
        this.recordings = recordings;
    }

    public void setUsingDemoData(boolean usingDemoData) {
        this.usingDemoData = usingDemoData;
    }

    public void setProviderConfigured(boolean providerConfigured) {
        this.providerConfigured = providerConfigured;
    }

    public void setSourceMessage(String sourceMessage) {
        this.sourceMessage = sourceMessage;
    }
}
