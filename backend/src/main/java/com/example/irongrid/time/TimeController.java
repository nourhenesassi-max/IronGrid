package com.example.irongrid.time;

import com.example.irongrid.time.dto.StartRequest;
import com.example.irongrid.time.dto.SessionStateResponse;
import com.example.irongrid.time.dto.TimeSummaryResponse;
import jakarta.validation.Valid;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/time")
public class TimeController {

    private final TimeService timeService;

    public TimeController(TimeService timeService) {
        this.timeService = timeService;
    }

    @PostMapping("/start")
    public SessionStateResponse start(Authentication auth, @Valid @RequestBody StartRequest req) {
        return timeService.start(auth.getName(), req);
    }

    @PostMapping("/break/start")
    public SessionStateResponse startBreak(Authentication auth) {
        return timeService.startBreak(auth.getName());
    }

    @PostMapping("/break/resume")
    public SessionStateResponse resume(Authentication auth) {
        return timeService.resume(auth.getName());
    }

    @PostMapping("/end")
    public SessionStateResponse end(Authentication auth) {
        return timeService.end(auth.getName());
    }

    @GetMapping("/summary")
    public TimeSummaryResponse summary(Authentication auth) {
        return timeService.summary(auth.getName());
    }

    @GetMapping("/state")
    public SessionStateResponse state(Authentication auth) {
        return timeService.state(auth.getName());
    }
}