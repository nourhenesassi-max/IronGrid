package com.example.irongrid.surveillance;

import com.example.irongrid.surveillance.dto.CameraDvrResponse;
import com.example.irongrid.surveillance.dto.CameraStatusUpdateRequest;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/manager/surveillance/cameras")
public class CameraFeedManagementController {

    private final CameraFeedManagementService service;

    public CameraFeedManagementController(CameraFeedManagementService service) {
        this.service = service;
    }

    @PatchMapping("/{cameraId}/status")
    public CameraDvrResponse updateStatus(
            @PathVariable Long cameraId,
            @RequestBody CameraStatusUpdateRequest request
    ) {
        return service.updateCameraStatus(cameraId, request);
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<Map<String, String>> handleBadRequest(IllegalArgumentException ex) {
        return ResponseEntity.badRequest().body(Map.of("message", ex.getMessage()));
    }

    @ExceptionHandler(EntityNotFoundException.class)
    public ResponseEntity<Map<String, String>> handleNotFound(EntityNotFoundException ex) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", ex.getMessage()));
    }
}
