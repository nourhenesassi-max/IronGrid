package com.example.irongrid.leave;

import com.example.irongrid.leave.dto.CreateLeaveRequest;
import com.example.irongrid.leave.dto.DecisionRequest;
import com.example.irongrid.leave.dto.LeaveResponse;
import com.example.irongrid.leave.dto.LeaveStatsResponse;
import com.example.irongrid.notification.NotificationService;
import com.example.irongrid.notification.NotificationType;
import com.example.irongrid.user.User;
import com.example.irongrid.user.UserService;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;

@Service
public class LeaveService {

    private final LeaveRequestRepository leaveRepo;
    private final UserService userService;
    private final NotificationService notificationService;

    public LeaveService(
            LeaveRequestRepository leaveRepo,
            UserService userService,
            NotificationService notificationService
    ) {
        this.leaveRepo = leaveRepo;
        this.userService = userService;
        this.notificationService = notificationService;
    }

    private User currentUser(String email) {
        return userService.getByEmailOrThrow(email);
    }

    private LeaveResponse toResponse(LeaveRequest r) {
        return new LeaveResponse(
                r.getId(),
                r.getUser() != null ? r.getUser().getId() : null,
                r.getUser() != null ? r.getUser().getEmail() : null,
                r.getUser() != null ? r.getUser().getName() : null,
                r.getType().name(),
                r.getStartDate().toString(),
                r.getEndDate().toString(),
                r.getReason(),
                r.getStatus().name(),
                r.getCreatedAt() != null ? r.getCreatedAt().toString() : null,
                r.getDecidedAt() != null ? r.getDecidedAt().toString() : null,
                r.getDecidedBy() != null ? r.getDecidedBy().getEmail() : null,
                r.getManagerComment()
        );
    }

    @Transactional
    public LeaveResponse create(String employeeEmail, CreateLeaveRequest req) {
        User employee = currentUser(employeeEmail);

        if (req.endDate().isBefore(req.startDate())) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "La date de fin doit être après la date de début"
            );
        }

        boolean overlap = leaveRepo.existsByUserAndStatusInAndStartDateLessThanEqualAndEndDateGreaterThanEqual(
                employee,
                List.of(LeaveStatus.PENDING, LeaveStatus.APPROVED),
                req.endDate(),
                req.startDate()
        );

        if (overlap) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "Une demande de congé existe déjà sur cette période"
            );
        }

        LeaveRequest r = new LeaveRequest();
        r.setUser(employee);
        r.setType(req.type());
        r.setStartDate(req.startDate());
        r.setEndDate(req.endDate());
        r.setReason(req.reason());
        r.setStatus(LeaveStatus.PENDING);
        r.setCreatedAt(LocalDateTime.now());

        leaveRepo.saveAndFlush(r);

        return toResponse(r);
    }

    @Transactional(readOnly = true)
    public List<LeaveResponse> myRequests(String employeeEmail) {
        User employee = currentUser(employeeEmail);
        return leaveRepo.findByUserOrderByCreatedAtDesc(employee)
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional
    public LeaveResponse cancel(String employeeEmail, Long requestId) {
        User employee = currentUser(employeeEmail);

        LeaveRequest r = leaveRepo.findById(requestId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Demande introuvable"));

        if (!r.getUser().getId().equals(employee.getId())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Accès interdit");
        }

        if (r.getStatus() != LeaveStatus.PENDING) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "Seule une demande en attente peut être annulée"
            );
        }

        r.setStatus(LeaveStatus.CANCELLED);
        leaveRepo.save(r);

        return toResponse(r);
    }

    @Transactional(readOnly = true)
    public LeaveStatsResponse stats(String employeeEmail) {
        User employee = currentUser(employeeEmail);

        LocalDate yearStart = LocalDate.now().withDayOfYear(1);
        LocalDate yearEnd = LocalDate.now().withMonth(12).withDayOfMonth(31);

        int annualUsed = computeUsedDays(employee, LeaveType.ANNUAL, yearStart, yearEnd);
        int sickUsed = computeUsedDays(employee, LeaveType.SICK, yearStart, yearEnd);

        long pending = leaveRepo.countByUserAndStatus(employee, LeaveStatus.PENDING);

        return new LeaveStatsResponse(
                annualUsed,
                sickUsed,
                (int) pending
        );
    }

    private int computeUsedDays(User user, LeaveType type, LocalDate from, LocalDate to) {
        List<LeaveRequest> approved = leaveRepo.findApprovedOverlappingPeriod(user, type, from, to);

        int used = 0;

        for (LeaveRequest lr : approved) {
            LocalDate effectiveStart = lr.getStartDate().isBefore(from) ? from : lr.getStartDate();
            LocalDate effectiveEnd = lr.getEndDate().isAfter(to) ? to : lr.getEndDate();

            long days = ChronoUnit.DAYS.between(effectiveStart, effectiveEnd) + 1;
            used += (int) Math.max(0, days);
        }

        return used;
    }

    @Transactional(readOnly = true)
    public List<LeaveResponse> requestsForManager(String status) {
        List<LeaveRequest> requests;

        if (status == null || status.isBlank()) {
            requests = leaveRepo.findAllByOrderByCreatedAtDesc();
        } else {
            LeaveStatus parsedStatus;
            try {
                parsedStatus = LeaveStatus.valueOf(status.toUpperCase());
            } catch (IllegalArgumentException e) {
                throw new ResponseStatusException(
                        HttpStatus.BAD_REQUEST,
                        "Statut invalide"
                );
            }

            requests = leaveRepo.findByStatusOrderByCreatedAtDesc(parsedStatus);
        }

        return requests.stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<LeaveResponse> pendingForManager() {
        return leaveRepo.findByStatusOrderByCreatedAtDesc(LeaveStatus.PENDING)
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional
    public LeaveResponse approve(String managerEmail, Long requestId, DecisionRequest req) {
        return decide(managerEmail, requestId, LeaveStatus.APPROVED, req);
    }

    @Transactional
    public LeaveResponse reject(String managerEmail, Long requestId, DecisionRequest req) {
        return decide(managerEmail, requestId, LeaveStatus.REJECTED, req);
    }

    private LeaveResponse decide(String managerEmail, Long requestId, LeaveStatus decision, DecisionRequest req) {
        User manager = currentUser(managerEmail);

        LeaveRequest r = leaveRepo.findById(requestId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Demande introuvable"));

        if (r.getStatus() != LeaveStatus.PENDING) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "Cette demande n'est plus en attente"
            );
        }

        r.setStatus(decision);
        r.setDecidedBy(manager);
        r.setDecidedAt(LocalDateTime.now());
        r.setManagerComment(req != null ? req.managerComment() : null);

        leaveRepo.save(r);

        User employee = r.getUser();

        String title;
        String content;
        NotificationType type;

        if (decision == LeaveStatus.APPROVED) {
            title = "Demande de congé approuvée";
            content = "Votre demande de congé du " + r.getStartDate()
                    + " au " + r.getEndDate() + " a été approuvée.";
            type = NotificationType.LEAVE_APPROVED;
        } else {
            title = "Demande de congé refusée";
            content = "Votre demande de congé a été refusée"
                    + ((r.getManagerComment() != null && !r.getManagerComment().isBlank())
                    ? ". Motif : " + r.getManagerComment()
                    : ".");
            type = NotificationType.LEAVE_REJECTED;
        }

        notificationService.sendNotificationToEmployee(
                title,
                content,
                type,
                employee.getId()
        );

        return toResponse(r);
    }
}