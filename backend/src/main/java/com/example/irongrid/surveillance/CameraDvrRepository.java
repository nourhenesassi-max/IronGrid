package com.example.irongrid.surveillance;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface CameraDvrRepository extends JpaRepository<CameraDvr, Long> {

    @Override
    @EntityGraph(attributePaths = "cameras")
    List<CameraDvr> findAll();

    @EntityGraph(attributePaths = "cameras")
    Optional<CameraDvr> findWithCamerasById(Long id);
}
