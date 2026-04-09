package com.example.irongrid.time;

import com.example.irongrid.user.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface WorkSessionRepository extends JpaRepository<WorkSession, Long> {

    Optional<WorkSession> findFirstByUserAndEndedAtIsNullOrderByStartedAtDesc(User user);

    @Query("""
        select distinct s
        from WorkSession s
        left join fetch s.breaks b
        where s.user = :user
    """)
    List<WorkSession> findByUserWithBreaks(@Param("user") User user);
}