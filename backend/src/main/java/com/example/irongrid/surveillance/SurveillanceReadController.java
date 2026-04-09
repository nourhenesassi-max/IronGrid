package com.example.irongrid.surveillance;

import com.example.irongrid.surveillance.dto.CameraFeedResponse;
import com.example.irongrid.surveillance.dto.CameraRecordingResponse;
import com.example.irongrid.surveillance.dto.SurveillanceDashboardResponse;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/manager/surveillance")
public class SurveillanceReadController {

    private final SurveillanceReadService surveillanceReadService;

    public SurveillanceReadController(SurveillanceReadService surveillanceReadService) {
        this.surveillanceReadService = surveillanceReadService;
    }

    @GetMapping("/dashboard")
    public SurveillanceDashboardResponse getDashboard(
            @RequestParam(defaultValue = "24") int recordingsLimit
    ) {
        return surveillanceReadService.getDashboard(recordingsLimit);
    }

    @GetMapping("/cameras")
    public List<CameraFeedResponse> getCameras() {
        return surveillanceReadService.getAllCameras();
    }

    @GetMapping("/cameras/{cameraId}")
    public CameraFeedResponse getCamera(@PathVariable Long cameraId) {
        return surveillanceReadService.getCamera(cameraId);
    }

    @GetMapping("/cameras/{cameraId}/recordings")
    public List<CameraRecordingResponse> getCameraRecordings(
            @PathVariable Long cameraId,
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
            LocalDateTime fromDate,
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
            LocalDateTime toDate,
            @RequestParam(defaultValue = "30") int limit
    ) {
        return surveillanceReadService.getCameraRecordings(cameraId, fromDate, toDate, limit);
    }

    @GetMapping("/recordings")
    public List<CameraRecordingResponse> getRecordings(
            @RequestParam(required = false) Long cameraId,
            @RequestParam(required = false) Long dvrId,
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
            LocalDateTime fromDate,
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
            LocalDateTime toDate,
            @RequestParam(defaultValue = "30") int limit
    ) {
        return surveillanceReadService.getRecordings(cameraId, dvrId, fromDate, toDate, limit);
    }

    @ExceptionHandler(EntityNotFoundException.class)
    public ResponseEntity<Map<String, String>> handleNotFound(EntityNotFoundException ex) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", ex.getMessage()));
    }
}
