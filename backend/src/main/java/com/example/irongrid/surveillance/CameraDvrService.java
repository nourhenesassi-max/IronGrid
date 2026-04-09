package com.example.irongrid.surveillance;

import com.example.irongrid.surveillance.dto.CameraDvrRequest;
import com.example.irongrid.surveillance.dto.CameraDvrResponse;
import com.example.irongrid.surveillance.dto.CameraFeedRequest;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
@Transactional
public class CameraDvrService {

    private final CameraDvrRepository dvrRepository;
    private final SurveillanceMapper mapper;

    public CameraDvrService(CameraDvrRepository dvrRepository, SurveillanceMapper mapper) {
        this.dvrRepository = dvrRepository;
        this.mapper = mapper;
    }

    @Transactional(readOnly = true)
    public List<CameraDvrResponse> getAll() {
        return dvrRepository.findAll()
                .stream()
                .map(mapper::toDvrResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public CameraDvrResponse getOne(Long id) {
        CameraDvr dvr = dvrRepository.findWithCamerasById(id)
                .orElseThrow(() -> new EntityNotFoundException("DVR introuvable: " + id));
        return mapper.toDvrResponse(dvr);
    }

    public CameraDvrResponse create(CameraDvrRequest request) {
        validateRequest(request);

        CameraDvr dvr = new CameraDvr();
        applyDvrFields(dvr, request);
        syncCameras(dvr, request.getCameras());
        dvr.setStatus(resolveDvrStatus(dvr, request.getStatus()));

        CameraDvr saved = dvrRepository.save(dvr);
        return mapper.toDvrResponse(saved);
    }

    public CameraDvrResponse update(Long id, CameraDvrRequest request) {
        validateRequest(request);

        CameraDvr dvr = dvrRepository.findWithCamerasById(id)
                .orElseThrow(() -> new EntityNotFoundException("DVR introuvable: " + id));

        applyDvrFields(dvr, request);
        syncCameras(dvr, request.getCameras());
        dvr.setStatus(resolveDvrStatus(dvr, request.getStatus()));

        CameraDvr saved = dvrRepository.save(dvr);
        return mapper.toDvrResponse(saved);
    }

    public void delete(Long id) {
        CameraDvr dvr = dvrRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("DVR introuvable: " + id));
        dvrRepository.delete(dvr);
    }

    private void validateRequest(CameraDvrRequest request) {
        if (request == null) {
            throw new IllegalArgumentException("Le corps de la requete est obligatoire.");
        }
        if (isBlank(request.getName())) {
            throw new IllegalArgumentException("Le nom du DVR est obligatoire.");
        }
        if (isBlank(request.getSite())) {
            throw new IllegalArgumentException("Le site du DVR est obligatoire.");
        }
        if (isBlank(request.getIpAddress())) {
            throw new IllegalArgumentException("L adresse IP est obligatoire.");
        }
        if (request.getPort() == null || request.getPort() < 1 || request.getPort() > 65535) {
            throw new IllegalArgumentException("Le port doit etre entre 1 et 65535.");
        }
    }

    private void applyDvrFields(CameraDvr dvr, CameraDvrRequest request) {
        dvr.setName(request.getName().trim());
        dvr.setSite(request.getSite().trim());
        dvr.setIpAddress(request.getIpAddress().trim());
        dvr.setPort(request.getPort());
        dvr.setProtocol(defaultIfBlank(request.getProtocol(), "RTSP"));
        dvr.setStreamProfile(defaultIfBlank(request.getStreamProfile(), "Full HD"));
        dvr.setNotes(request.getNotes() == null ? "" : request.getNotes().trim());
        dvr.setUpdatedAt(LocalDateTime.now());
    }

    private void syncCameras(CameraDvr dvr, List<CameraFeedRequest> requests) {
        List<CameraFeedRequest> cameraRequests =
                requests == null ? new ArrayList<>() : requests;

        Map<Long, CameraFeed> existingById = new LinkedHashMap<>();
        for (CameraFeed camera : dvr.getCameras()) {
            if (camera.getId() != null) {
                existingById.put(camera.getId(), camera);
            }
        }

        List<CameraFeed> retainedCameras = new ArrayList<>();

        for (int i = 0; i < cameraRequests.size(); i++) {
            CameraFeedRequest request = cameraRequests.get(i);
            CameraFeed camera = resolveCamera(existingById, request.getId());
            applyCameraRequest(camera, request, i);
            retainedCameras.add(camera);
        }

        List<CameraFeed> currentCameras = new ArrayList<>(dvr.getCameras());
        for (CameraFeed camera : currentCameras) {
            if (!retainedCameras.contains(camera)) {
                camera.setDvr(null);
                dvr.getCameras().remove(camera);
            }
        }

        for (CameraFeed camera : retainedCameras) {
            if (!dvr.getCameras().contains(camera)) {
                dvr.addCamera(camera);
            }
        }

        dvr.getCameras().sort(
                Comparator.comparing(
                        CameraFeed::getChannel,
                        Comparator.nullsLast(Integer::compareTo)
                )
        );
    }

    private CameraFeed resolveCamera(Map<Long, CameraFeed> existingById, String requestId) {
        Long parsedId = parseLong(requestId);
        if (parsedId != null) {
            CameraFeed existing = existingById.remove(parsedId);
            if (existing != null) {
                return existing;
            }
        }
        return new CameraFeed();
    }

    private void applyCameraRequest(CameraFeed camera, CameraFeedRequest request, int index) {
        boolean isOnline = request.getIsOnline() != null && request.getIsOnline();
        camera.setName(defaultIfBlank(request.getName(), "CAM-" + String.format("%02d", index + 1)));
        camera.setZone(defaultIfBlank(request.getZone(), "Zone " + (index + 1)));
        camera.setChannel(request.getChannel() == null ? index + 1 : request.getChannel());
        camera.setIsOnline(isOnline);
        camera.setRecordingEnabled(
                request.getRecordingEnabled() != null ? request.getRecordingEnabled() : isOnline
        );
        camera.setMotionEnabled(request.getMotionEnabled() != null && request.getMotionEnabled());
        camera.setResolution(defaultIfBlank(request.getResolution(), "1920x1080"));
        camera.setBitrateKbps(request.getBitrateKbps() == null ? 0 : request.getBitrateKbps());
        camera.setLatencyMs(request.getLatencyMs() == null ? (isOnline ? 45 : 0) : request.getLatencyMs());
        camera.setStreamUrl(nullToEmpty(request.getStreamUrl()));
        camera.setArchiveUrl(nullToEmpty(request.getArchiveUrl()));
        camera.setPreviewImageUrl(nullToEmpty(request.getPreviewImageUrl()));
        camera.setStreamType(defaultIfBlank(request.getStreamType(), "rtsp").toLowerCase());
        camera.setLastHeartbeatAt(
                request.getLastHeartbeatAt() != null ? request.getLastHeartbeatAt() : LocalDateTime.now()
        );
    }

    private String resolveDvrStatus(CameraDvr dvr, String fallbackStatus) {
        if (dvr.getCameras().isEmpty()) {
            return normalizeStatus(fallbackStatus);
        }

        long onlineCount = dvr.getCameras()
                .stream()
                .filter(camera -> Boolean.TRUE.equals(camera.getIsOnline()))
                .count();

        if (onlineCount == 0) {
            return "offline";
        }
        if (onlineCount == dvr.getCameras().size()) {
            return "online";
        }
        return "degraded";
    }

    private String normalizeStatus(String status) {
        String value = defaultIfBlank(status, "offline").trim().toLowerCase();
        return switch (value) {
            case "online", "degraded", "offline" -> value;
            default -> "offline";
        };
    }

    private String defaultIfBlank(String value, String fallback) {
        return isBlank(value) ? fallback : value.trim();
    }

    private String nullToEmpty(String value) {
        return value == null ? "" : value.trim();
    }

    private Long parseLong(String value) {
        if (isBlank(value)) {
            return null;
        }
        try {
            return Long.parseLong(value.trim());
        } catch (NumberFormatException ignored) {
            return null;
        }
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}
