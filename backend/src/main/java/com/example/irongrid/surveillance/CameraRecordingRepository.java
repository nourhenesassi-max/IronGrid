package com.example.irongrid.surveillance;

import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;

public interface CameraRecordingRepository extends JpaRepository<CameraRecording, Long> {

    @EntityGraph(attributePaths = {"camera", "camera.dvr"})
    @Query("""
            select recording
            from CameraRecording recording
            where (:cameraId is null or recording.camera.id = :cameraId)
              and (:dvrId is null or recording.camera.dvr.id = :dvrId)
              and (:fromDate is null or recording.startedAt >= :fromDate)
              and (:toDate is null or recording.endedAt <= :toDate)
            order by recording.startedAt desc
            """)
    List<CameraRecording> search(
            @Param("cameraId") Long cameraId,
            @Param("dvrId") Long dvrId,
            @Param("fromDate") LocalDateTime fromDate,
            @Param("toDate") LocalDateTime toDate,
            Pageable pageable
    );
}
