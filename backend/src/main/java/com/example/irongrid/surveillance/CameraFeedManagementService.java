package com.example.irongrid.surveillance;

import com.example.irongrid.surveillance.dto.CameraDvrResponse;
import com.example.irongrid.surveillance.dto.CameraStatusUpdateRequest;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@Transactional
public class CameraFeedManagementService {

    private final CameraFeedRepository cameraFeedRepository;
    private final CameraDvrRepository cameraDvrRepository;
    private final SurveillanceMapper mapper;

    public CameraFeedManagementService(
            CameraFeedRepository cameraFeedRepository,
            CameraDvrRepository cameraDvrRepository,
            SurveillanceMapper mapper
    ) {
        this.cameraFeedRepository = cameraFeedRepository;
        this.cameraDvrRepository = cameraDvrRepository;
        this.mapper = mapper;
    }

    public CameraDvrResponse updateCameraStatus(Long cameraId, CameraStatusUpdateRequest request) {
        if (request == null || request.getIsOnline() == null) {
            throw new IllegalArgumentException("Le statut en ligne de la camera est obligatoire.");
        }

        CameraFeed camera = cameraFeedRepository.findById(cameraId)
                .orElseThrow(() -> new EntityNotFoundException("Camera introuvable: " + cameraId));

        boolean isOnline = request.getIsOnline();
        camera.setIsOnline(isOnline);
        camera.setRecordingEnabled(isOnline);
        camera.setLatencyMs(isOnline ? resolveLatency(camera) : 0);
        camera.setLastHeartbeatAt(LocalDateTime.now());

        CameraDvr dvr = camera.getDvr();
        dvr.setStatus(resolveDvrStatus(dvr));
        dvr.setUpdatedAt(LocalDateTime.now());

        CameraDvr saved = cameraDvrRepository.save(dvr);
        return mapper.toDvrResponse(saved);
    }

    private int resolveLatency(CameraFeed camera) {
        Integer latencyMs = camera.getLatencyMs();
        if (latencyMs != null && latencyMs > 0) {
            return latencyMs;
        }
        int channel = camera.getChannel() == null ? 1 : camera.getChannel();
        return 42 + Math.max(channel - 1, 0) * 6;
    }

    private String resolveDvrStatus(CameraDvr dvr) {
        if (dvr.getCameras().isEmpty()) {
            return "offline";
        }

        long onlineCount = dvr.getCameras()
                .stream()
                .filter(item -> Boolean.TRUE.equals(item.getIsOnline()))
                .count();

        if (onlineCount == 0) {
            return "offline";
        }
        if (onlineCount == dvr.getCameras().size()) {
            return "online";
        }
        return "degraded";
    }
}
