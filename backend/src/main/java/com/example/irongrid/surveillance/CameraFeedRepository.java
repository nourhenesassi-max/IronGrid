package com.example.irongrid.surveillance;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface CameraFeedRepository extends JpaRepository<CameraFeed, Long> {

    @Override
    @EntityGraph(attributePaths = "dvr")
    List<CameraFeed> findAll();

    @Override
    @EntityGraph(attributePaths = "dvr")
    Optional<CameraFeed> findById(Long id);

    @EntityGraph(attributePaths = "dvr")
    List<CameraFeed> findByDvrIdOrderByChannelAsc(Long dvrId);
}
