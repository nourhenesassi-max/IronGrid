package com.example.irongrid.surveillance;

import com.example.irongrid.surveillance.dto.CameraDvrResponse;
import com.example.irongrid.surveillance.dto.CameraFeedResponse;
import com.example.irongrid.surveillance.dto.CameraRecordingResponse;
import org.springframework.stereotype.Component;

import java.util.Comparator;
import java.util.List;
import java.util.Locale;

@Component
public class SurveillanceMapper {

    public CameraDvrResponse toDvrResponse(CameraDvr dvr) {
        CameraDvrResponse response = new CameraDvrResponse();
        response.setId(String.valueOf(dvr.getId()));
        response.setName(dvr.getName());
        response.setSite(dvr.getSite());
        response.setIpAddress(dvr.getIpAddress());
        response.setPort(dvr.getPort());
        response.setStatus(dvr.getStatus());
        response.setProtocol(dvr.getProtocol());
        response.setStreamProfile(dvr.getStreamProfile());
        response.setNotes(dvr.getNotes());
        response.setUpdatedAt(dvr.getUpdatedAt());
        response.setCameras(
                dvr.getCameras()
                        .stream()
                        .sorted(
                                Comparator.comparing(
                                        CameraFeed::getChannel,
                                        Comparator.nullsLast(Integer::compareTo)
                                )
                        )
                        .map(this::toCameraResponse)
                        .toList()
        );
        return response;
    }

    public CameraFeedResponse toCameraResponse(CameraFeed camera) {
        CameraFeedResponse response = new CameraFeedResponse();
        response.setId(String.valueOf(camera.getId()));
        response.setDvrId(camera.getDvr() == null ? null : String.valueOf(camera.getDvr().getId()));
        response.setDvrName(camera.getDvr() == null ? null : camera.getDvr().getName());
        response.setName(camera.getName());
        response.setZone(camera.getZone());
        response.setChannel(camera.getChannel());
        response.setIsOnline(camera.getIsOnline());
        response.setRecordingEnabled(camera.getRecordingEnabled());
        response.setMotionEnabled(camera.getMotionEnabled());
        response.setResolution(camera.getResolution());
        response.setBitrateKbps(camera.getBitrateKbps());
        response.setLatencyMs(camera.getLatencyMs());
        response.setStreamUrl(camera.getStreamUrl());
        response.setArchiveUrl(camera.getArchiveUrl());
        response.setPreviewImageUrl(camera.getPreviewImageUrl());
        response.setStreamType(camera.getStreamType());
        response.setLastHeartbeatAt(camera.getLastHeartbeatAt());
        response.setRecordingsCount(0);
        return response;
    }

    public CameraRecordingResponse toRecordingResponse(CameraRecording recording) {
        CameraRecordingResponse response = new CameraRecordingResponse();
        response.setId(String.valueOf(recording.getId()));
        response.setCameraId(String.valueOf(recording.getCamera().getId()));
        response.setCameraName(recording.getCamera().getName());
        response.setDvrId(String.valueOf(recording.getCamera().getDvr().getId()));
        response.setDvrName(recording.getCamera().getDvr().getName());
        response.setTitle(recording.getTitle());
        response.setTrigger(recording.getTriggerType());
        response.setStartedAt(recording.getStartedAt());
        response.setEndedAt(recording.getEndedAt());
        response.setArchiveUrl(recording.getArchiveUrl());
        response.setSizeBytes(recording.getSizeBytes());
        response.setSizeLabel(formatFileSize(recording.getSizeBytes()));
        return response;
    }

    public String formatFileSize(Long sizeBytes) {
        long bytes = sizeBytes == null ? 0L : sizeBytes;
        if (bytes >= 1024L * 1024L * 1024L) {
            double value = bytes / (1024d * 1024d * 1024d);
            return String.format(Locale.US, "%.1f Go", value);
        }
        if (bytes >= 1024L * 1024L) {
            double value = bytes / (1024d * 1024d);
            return String.format(Locale.US, "%.0f Mo", value);
        }
        if (bytes >= 1024L) {
            double value = bytes / 1024d;
            return String.format(Locale.US, "%.0f Ko", value);
        }
        return bytes + " o";
    }
}
