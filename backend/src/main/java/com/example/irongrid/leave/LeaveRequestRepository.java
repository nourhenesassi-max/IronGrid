
package com.example.irongrid.leave;

import com.example.irongrid.user.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;

public interface LeaveRequestRepository extends JpaRepository<LeaveRequest, Long> {

    List<LeaveRequest> findAllByOrderByCreatedAtDesc();

    List<LeaveRequest> findByUserOrderByCreatedAtDesc(User user);

    List<LeaveRequest> findByStatusOrderByCreatedAtDesc(LeaveStatus status);

    // overlap correct: startDate <= requestedEnd AND endDate >= requestedStart
    boolean existsByUserAndStatusInAndStartDateLessThanEqualAndEndDateGreaterThanEqual(
            User user,
            List<LeaveStatus> statuses,
            LocalDate requestedEnd,
            LocalDate requestedStart
    );

    long countByUserAndStatus(User user, LeaveStatus status);

    @Query("""
        select lr
        from LeaveRequest lr
        where lr.user = :user
          and lr.status = com.example.irongrid.leave.LeaveStatus.APPROVED
          and lr.type = :type
          and lr.startDate <= :to
          and lr.endDate >= :from
    """)
    List<LeaveRequest> findApprovedOverlappingPeriod(
            @Param("user") User user,
            @Param("type") LeaveType type,
            @Param("from") LocalDate from,
            @Param("to") LocalDate to
    );
}
