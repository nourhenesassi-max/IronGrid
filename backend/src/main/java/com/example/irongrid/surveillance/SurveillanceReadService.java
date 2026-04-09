package com.example.irongrid.surveillance;

import com.example.irongrid.surveillance.dto.CameraFeedResponse;
import com.example.irongrid.surveillance.dto.CameraRecordingResponse;
import com.example.irongrid.surveillance.dto.SurveillanceDashboardResponse;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@Transactional(readOnly = true)
public class SurveillanceReadService {

    private final CameraDvrRepository dvrRepository;
    private final CameraFeedRepository cameraFeedRepository;
    private final CameraRecordingRepository cameraRecordingRepository;
    private final SurveillanceMapper mapper;
    private final SurveillanceProperties surveillanceProperties;

    public SurveillanceReadService(
            CameraDvrRepository dvrRepository,
            CameraFeedRepository cameraFeedRepository,
            CameraRecordingRepository cameraRecordingRepository,
            SurveillanceMapper mapper,
            SurveillanceProperties surveillanceProperties
    ) {
        this.dvrRepository = dvrRepository;
        this.cameraFeedRepository = cameraFeedRepository;
        this.cameraRecordingRepository = cameraRecordingRepository;
        this.mapper = mapper;
        this.surveillanceProperties = surveillanceProperties;
    }

    public SurveillanceDashboardResponse getDashboard(int recordingsLimit) {
        List<CameraDvr> dvrs = dvrRepository.findAll();
        List<CameraFeedResponse> cameras = dvrs.stream()
                .flatMap(dvr -> dvr.getCameras().stream())
                .map(mapper::toCameraResponse)
                .toList();

        List<CameraRecordingResponse> recordings = cameraRecordingRepository.search(
                        null,
                        null,
                        null,
                        null,
                        PageRequest.of(0, sanitizeLimit(recordingsLimit, 24, 80))
                )
                .stream()
                .map(mapper::toRecordingResponse)
                .toList();

        SurveillanceDashboardResponse response = new SurveillanceDashboardResponse();
        response.setDvrs(dvrs.stream().map(mapper::toDvrResponse).toList());
        response.setCameras(cameras);
        response.setRecordings(recordings);
        response.setUsingDemoData(false);
        response.setProviderConfigured(surveillanceProperties.isProviderConfigured());
        response.setSourceMessage(surveillanceProperties.getSourceMessage());
        return response;
    }

    public List<CameraFeedResponse> getAllCameras() {
        return cameraFeedRepository.findAll()
                .stream()
                .map(mapper::toCameraResponse)
                .toList();
    }

    public CameraFeedResponse getCamera(Long cameraId) {
        CameraFeed camera = cameraFeedRepository.findById(cameraId)
                .orElseThrow(() -> new EntityNotFoundException("Camera introuvable: " + cameraId));
        return mapper.toCameraResponse(camera);
    }

    public List<CameraRecordingResponse> getCameraRecordings(
            Long cameraId,
            LocalDateTime fromDate,
            LocalDateTime toDate,
            int limit
    ) {
        return getRecordings(cameraId, null, fromDate, toDate, limit);
    }

    public List<CameraRecordingResponse> getRecordings(
            Long cameraId,
            Long dvrId,
            LocalDateTime fromDate,
            LocalDateTime toDate,
            int limit
    ) {
        return cameraRecordingRepository.search(
                        cameraId,
                        dvrId,
                        fromDate,
                        toDate,
                        PageRequest.of(0, sanitizeLimit(limit, 30, 200))
                )
                .stream()
                .map(mapper::toRecordingResponse)
                .toList();
    }

    private int sanitizeLimit(int value, int fallback, int max) {
        if (value <= 0) {
            return fallback;
        }
        return Math.min(value, max);
    }
}
