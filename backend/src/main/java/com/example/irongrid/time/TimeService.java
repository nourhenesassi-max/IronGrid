package com.example.irongrid.time;

import com.example.irongrid.time.dto.StartRequest;
import com.example.irongrid.time.dto.SessionStateResponse;
import com.example.irongrid.time.dto.TimeSummaryResponse;
import com.example.irongrid.user.User;
import com.example.irongrid.user.UserService;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.*;
import java.util.List;

@Service
public class TimeService {

    private final WorkSessionRepository sessionRepo;
    private final WorkBreakRepository breakRepo;
    private final UserService userService;

    public TimeService(WorkSessionRepository sessionRepo,
                       WorkBreakRepository breakRepo,
                       UserService userService) {
        this.sessionRepo = sessionRepo;
        this.breakRepo = breakRepo;
        this.userService = userService;
    }

    private User currentUser(String email) {
        return userService.getByEmailOrThrow(email);
    }

    private SessionStateResponse toResponse(WorkSession s) {
        return new SessionStateResponse(
                s.getId(),
                s.getProject(),
                s.getStatus().name(),
                s.getStartedAt() != null ? s.getStartedAt().toString() : null,
                s.getEndedAt() != null ? s.getEndedAt().toString() : null
        );
    }

    private WorkSession activeSessionOrThrow(User u) {
        return sessionRepo.findFirstByUserAndEndedAtIsNullOrderByStartedAtDesc(u)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.CONFLICT, "No active session"));
    }

    @Transactional
    public SessionStateResponse start(String email, StartRequest req) {
        User u = currentUser(email);

        if (sessionRepo.findFirstByUserAndEndedAtIsNullOrderByStartedAtDesc(u).isPresent()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "A session is already running");
        }

        WorkSession s = new WorkSession();
        s.setUser(u);
        s.setProject(req.project().trim());
        s.setStartedAt(LocalDateTime.now());
        s.setStatus(SessionStatus.RUNNING);

        sessionRepo.save(s);
        return toResponse(s);
    }

    @Transactional
    public SessionStateResponse startBreak(String email) {
        User u = currentUser(email);
        WorkSession s = activeSessionOrThrow(u);

        if (s.getStatus() == SessionStatus.PAUSED) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Already paused");
        }

        WorkBreak b = new WorkBreak();
        b.setSession(s);
        b.setBreakStart(LocalDateTime.now());
        breakRepo.save(b);

        s.setStatus(SessionStatus.PAUSED);
        sessionRepo.save(s);

        return toResponse(s);
    }

    @Transactional
    public SessionStateResponse resume(String email) {
        User u = currentUser(email);
        WorkSession s = activeSessionOrThrow(u);

        WorkBreak openBreak = breakRepo.findFirstBySessionAndBreakEndIsNullOrderByBreakStartDesc(s)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.CONFLICT, "No open break"));

        openBreak.setBreakEnd(LocalDateTime.now());
        breakRepo.save(openBreak);

        s.setStatus(SessionStatus.RUNNING);
        sessionRepo.save(s);

        return toResponse(s);
    }

    @Transactional
    public SessionStateResponse end(String email) {
        User u = currentUser(email);
        WorkSession s = activeSessionOrThrow(u);

        // si pause ouverte, la fermer automatiquement
        breakRepo.findFirstBySessionAndBreakEndIsNullOrderByBreakStartDesc(s)
                .ifPresent(b -> {
                    b.setBreakEnd(LocalDateTime.now());
                    breakRepo.save(b);
                });

        s.setEndedAt(LocalDateTime.now());
        s.setStatus(SessionStatus.ENDED);
        sessionRepo.save(s);

        return toResponse(s);
    }

    @Transactional(readOnly = true)
    public SessionStateResponse state(String email) {
        User u = currentUser(email);

        return sessionRepo.findFirstByUserAndEndedAtIsNullOrderByStartedAtDesc(u)
                .map(this::toResponse)
                .orElse(new SessionStateResponse(
                        null, null, SessionStatus.ENDED.name(), null, null
                ));
    }

    @Transactional(readOnly = true)
    public TimeSummaryResponse summary(String email) {
        User u = currentUser(email);

        LocalDate today = LocalDate.now();
        LocalDate weekStart = today.with(DayOfWeek.MONDAY);

        List<WorkSession> sessions = sessionRepo.findByUserWithBreaks(u);

        long minutesToday = 0;
        long minutesThisWeek = 0;

        for (WorkSession s : sessions) {
            if (s.getStartedAt() == null) continue;

            LocalDate sessionDay = s.getStartedAt().toLocalDate();
            LocalDateTime end = (s.getEndedAt() != null) ? s.getEndedAt() : LocalDateTime.now();

            long gross = Duration.between(s.getStartedAt(), end).toMinutes();

            long breakMinutes = 0;
            if (s.getBreaks() != null) {
                breakMinutes = s.getBreaks().stream()
                        .filter(b -> b.getBreakStart() != null)
                        .mapToLong(b -> {
                            LocalDateTime be = (b.getBreakEnd() != null) ? b.getBreakEnd() : LocalDateTime.now();
                            return Duration.between(b.getBreakStart(), be).toMinutes();
                        })
                        .sum();
            }

            long net = Math.max(0, gross - breakMinutes);

            if (sessionDay.isEqual(today)) minutesToday += net;
            if (!sessionDay.isBefore(weekStart)) minutesThisWeek += net;
        }

        return new TimeSummaryResponse(minutesToday, minutesThisWeek);
    }
}