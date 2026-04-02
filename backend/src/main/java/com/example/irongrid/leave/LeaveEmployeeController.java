package com.example.irongrid.leave;

import com.example.irongrid.leave.dto.CreateLeaveRequest;
import com.example.irongrid.leave.dto.LeaveResponse;
import com.example.irongrid.leave.dto.LeaveStatsResponse;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/leave")
public class LeaveEmployeeController {

    private final LeaveService leaveService;

    public LeaveEmployeeController(LeaveService leaveService) {
        this.leaveService = leaveService;
    }

    @PostMapping
    public ResponseEntity<LeaveResponse> create(
            Authentication auth,
            @Valid @RequestBody CreateLeaveRequest req
    ) {
        System.out.println("POST /api/leave user=" + (auth != null ? auth.getName() : "null"));
        return ResponseEntity.status(201).body(leaveService.create(auth.getName(), req));
    }

    @GetMapping("/mine")
    public List<LeaveResponse> mine(Authentication auth) {
        System.out.println("GET /api/leave/mine user=" + (auth != null ? auth.getName() : "null"));
        return leaveService.myRequests(auth.getName());
    }

    @PostMapping("/{id}/cancel")
    public LeaveResponse cancel(Authentication auth, @PathVariable Long id) {
        System.out.println("POST /api/leave/" + id + "/cancel user=" + (auth != null ? auth.getName() : "null"));
        return leaveService.cancel(auth.getName(), id);
    }

    @GetMapping("/stats")
    public LeaveStatsResponse stats(Authentication auth) {
        System.out.println("GET /api/leave/stats user=" + (auth != null ? auth.getName() : "null"));
        return leaveService.stats(auth.getName());
    }
}