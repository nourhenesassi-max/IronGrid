package com.example.irongrid.leave;

import com.example.irongrid.leave.dto.DecisionRequest;
import com.example.irongrid.leave.dto.LeaveResponse;
import jakarta.validation.Valid;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/manager/leaves")
public class LeaveManagerController {

    private final LeaveService leaveService;

    public LeaveManagerController(LeaveService leaveService) {
        this.leaveService = leaveService;
    }

    @GetMapping
    public List<LeaveResponse> requests(
            @RequestParam(required = false) String status
    ) {
        return leaveService.requestsForManager(status);
    }

    @GetMapping("/pending")
    public List<LeaveResponse> pending() {
        return leaveService.pendingForManager();
    }

    @PostMapping("/{id}/approve")
    public LeaveResponse approve(
            Authentication auth,
            @PathVariable Long id,
            @Valid @RequestBody(required = false) DecisionRequest req
    ) {
        return leaveService.approve(auth.getName(), id, req);
    }

    @PostMapping("/{id}/reject")
    public LeaveResponse reject(
            Authentication auth,
            @PathVariable Long id,
            @Valid @RequestBody(required = false) DecisionRequest req
    ) {
        return leaveService.reject(auth.getName(), id, req);
    }
}