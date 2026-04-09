package com.example.irongrid.surveillance;

import com.example.irongrid.security.JwtService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpHeaders;
import org.springframework.test.web.servlet.MockMvc;

import static org.hamcrest.Matchers.greaterThan;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
class SurveillanceApiTests {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private JwtService jwtService;

    @Autowired
    private CameraFeedRepository cameraFeedRepository;

    private String managerToken;

    @BeforeEach
    void setUp() {
        managerToken = jwtService.generateToken(999L, "manager@test.local", "MANAGER");
    }

    @Test
    void dashboardReturnsDvrsCamerasAndRecordings() throws Exception {
        mockMvc.perform(
                        get("/api/manager/surveillance/dashboard")
                                .header(HttpHeaders.AUTHORIZATION, "Bearer " + managerToken)
                )
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.dvrs.length()").value(greaterThan(0)))
                .andExpect(jsonPath("$.cameras.length()").value(greaterThan(0)))
                .andExpect(jsonPath("$.recordings.length()").value(greaterThan(0)))
                .andExpect(jsonPath("$.usingDemoData").value(false))
                .andExpect(jsonPath("$.providerConfigured").value(true));
    }

    @Test
    void cameraRecordingsCanBeFilteredByCamera() throws Exception {
        CameraFeed camera = cameraFeedRepository.findAll()
                .stream()
                .filter(item -> Boolean.TRUE.equals(item.getRecordingEnabled()))
                .findFirst()
                .orElseThrow();

        mockMvc.perform(
                        get("/api/manager/surveillance/cameras/{cameraId}/recordings", camera.getId())
                                .header(HttpHeaders.AUTHORIZATION, "Bearer " + managerToken)
                )
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].cameraId").value(String.valueOf(camera.getId())))
                .andExpect(jsonPath("$[0].archiveUrl").isNotEmpty());
    }

    @Test
    void managerCanToggleCameraStatusAndReceiveUpdatedDvr() throws Exception {
        CameraFeed camera = cameraFeedRepository.findAll()
                .stream()
                .findFirst()
                .orElseThrow();

        mockMvc.perform(
                        patch("/api/manager/surveillance/cameras/{cameraId}/status", camera.getId())
                                .header(HttpHeaders.AUTHORIZATION, "Bearer " + managerToken)
                                .contentType("application/json")
                                .content("""
                                        {
                                          "isOnline": false
                                        }
                                        """)
                )
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(String.valueOf(camera.getDvr().getId())))
                .andExpect(jsonPath("$.cameras.length()").value(greaterThan(0)));

        CameraFeed updatedCamera = cameraFeedRepository.findById(camera.getId())
                .orElseThrow();
        assertFalse(Boolean.TRUE.equals(updatedCamera.getIsOnline()));
    }

    @Test
    void surveillanceEndpointsRequireManagerAuthentication() throws Exception {
        mockMvc.perform(get("/api/manager/surveillance/dashboard"))
                .andExpect(status().isForbidden());
    }
}
