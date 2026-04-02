package com.example.irongrid.surveillance;

import com.example.irongrid.surveillance.dto.CameraDvrRequest;
import com.example.irongrid.surveillance.dto.CameraFeedRequest;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.List;

@Component
public class SurveillanceSeeder implements CommandLineRunner {

    private final CameraDvrRepository dvrRepository;
    private final CameraDvrService dvrService;
    private final CameraRecordingRepository cameraRecordingRepository;

    public SurveillanceSeeder(
            CameraDvrRepository dvrRepository,
            CameraDvrService dvrService,
            CameraRecordingRepository cameraRecordingRepository
    ) {
        this.dvrRepository = dvrRepository;
        this.dvrService = dvrService;
        this.cameraRecordingRepository = cameraRecordingRepository;
    }

    @Override
    public void run(String... args) {
        if (dvrRepository.count() == 0) {
            dvrService.create(buildDvr(
                    "DVR Ligne Nord",
                    "Usine Centrale - Bloc A",
                    "192.168.10.15",
                    554,
                    "online",
                    "RTSP",
                    "Full HD",
                    "Supervision de la ligne d assemblage et du quai principal.",
                    6
            ));

            dvrService.create(buildDvr(
                    "DVR Quai Logistique",
                    "Entrepot - Quai 2",
                    "192.168.10.41",
                    8554,
                    "degraded",
                    "HLS",
                    "HD",
                    "Une camera exterieure est instable sur les heures de pointe.",
                    4
            ));

            dvrService.create(buildDvr(
                    "DVR Perimetre Sud",
                    "Poste de garde - Sud",
                    "192.168.10.77",
                    554,
                    "offline",
                    "RTSP",
                    "Full HD",
                    "Maintenance reseau planifiee par equipe surete.",
                    5
            ));
        }

        if (cameraRecordingRepository.count() == 0) {
            seedRecordings();
        }
    }

    private CameraDvrRequest buildDvr(
            String name,
            String site,
            String ip,
            int port,
            String status,
            String protocol,
            String profile,
            String notes,
            int cameraCount
    ) {
        CameraDvrRequest dvr = new CameraDvrRequest();
        dvr.setName(name);
        dvr.setSite(site);
        dvr.setIpAddress(ip);
        dvr.setPort(port);
        dvr.setStatus(status);
        dvr.setProtocol(protocol);
        dvr.setStreamProfile(profile);
        dvr.setNotes(notes);
        dvr.setCameras(buildCameras(site, ip, port, protocol, status, cameraCount));
        return dvr;
    }

    private List<CameraFeedRequest> buildCameras(
            String site,
            String ip,
            int port,
            String protocol,
            String status,
            int count
    ) {
        return java.util.stream.IntStream.rangeClosed(1, count)
                .mapToObj(index -> {
                    CameraFeedRequest cam = new CameraFeedRequest();
                    cam.setName("CAM-" + String.format("%02d", index));
                    cam.setZone(zoneFor(site, index));
                    cam.setChannel(index);
                    cam.setIsOnline(isOnline(status, index));
                    cam.setRecordingEnabled(!"offline".equals(status));
                    cam.setMotionEnabled(!"offline".equals(status) && index % 2 == 0);
                    cam.setResolution("1920x1080");
                    cam.setBitrateKbps(isOnline(status, index) ? 1400 + (index * 120) : 0);
                    cam.setLatencyMs(isOnline(status, index) ? 30 + (index * 8) : 0);
                    cam.setStreamUrl(buildLiveUrl(ip, port, index, protocol));
                    cam.setArchiveUrl("http://" + ip + ":" + port + "/archive/camera_" + index + ".m3u8");
                    cam.setPreviewImageUrl("");
                    cam.setStreamType(protocol.toLowerCase());
                    return cam;
                })
                .toList();
    }

    private boolean isOnline(String status, int index) {
        return switch (status) {
            case "online" -> true;
            case "degraded" -> index % 3 != 0;
            default -> false;
        };
    }

    private String buildLiveUrl(String ip, int port, int channel, String protocol) {
        String normalized = protocol == null ? "rtsp" : protocol.trim().toLowerCase();
        if ("hls".equals(normalized)) {
            return "http://" + ip + ":" + port + "/hls/camera_" + channel + ".m3u8";
        }
        if ("http".equals(normalized) || "https".equals(normalized)) {
            return "http://" + ip + ":" + port + "/live/camera_" + channel + ".mp4";
        }
        return "rtsp://" + ip + ":" + port + "/live/ch" + channel;
    }

    private String zoneFor(String site, int index) {
        String[] zones = {
                "Acces principal",
                "Zone de stockage",
                "Couloir technique",
                "Ligne de production",
                "Parking",
                "Salle serveurs",
                "Quai de chargement",
                "Perimetre exterieur"
        };
        return zones[(index - 1) % zones.length] + " - " + site;
    }

    private void seedRecordings() {
        LocalDateTime now = LocalDateTime.now();

        List<CameraRecording> recordings = dvrRepository.findAll()
                .stream()
                .flatMap(dvr -> dvr.getCameras().stream())
                .filter(camera -> Boolean.TRUE.equals(camera.getRecordingEnabled()))
                .flatMap(camera -> java.util.stream.IntStream.range(0, 2).mapToObj(index -> {
                    CameraRecording recording = new CameraRecording();
                    LocalDateTime startedAt = now.minusMinutes(18L + (camera.getChannel() * 7L) + (index * 21L));
                    LocalDateTime endedAt = startedAt.plusMinutes(5L + index * 3L);
                    recording.setTitle(index == 0 ? "Detection mouvement" : "Sequence continue");
                    recording.setTriggerType(index == 0 ? "Mouvement" : "Planification");
                    recording.setStartedAt(startedAt);
                    recording.setEndedAt(endedAt);
                    recording.setArchiveUrl(camera.getArchiveUrl());
                    recording.setSizeBytes(420L * 1024 * 1024 + ((long) camera.getChannel() * 32L * 1024 * 1024));
                    recording.setCamera(camera);
                    return recording;
                }))
                .toList();

        cameraRecordingRepository.saveAll(recordings);
    }
}
