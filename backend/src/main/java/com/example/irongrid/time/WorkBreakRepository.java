package com.example.irongrid.time;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface WorkBreakRepository extends JpaRepository<WorkBreak, Long> {
    Optional<WorkBreak> findFirstBySessionAndBreakEndIsNullOrderByBreakStartDesc(WorkSession session);
}