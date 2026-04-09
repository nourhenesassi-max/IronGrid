package com.example.irongrid.admin;

import com.example.irongrid.admin.dto.AcceptedUserResponse;
import com.example.irongrid.admin.dto.AdminDashboardStatsResponse;
import com.example.irongrid.admin.dto.ApproveUserRequest;
import com.example.irongrid.admin.dto.PendingUserResponse;
import com.example.irongrid.admin.dto.RejectedUserResponse;
import com.example.irongrid.auth.dto.MessageResponse;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin")
public class AdminUserApprovalController {

    private final AdminUserApprovalService service;

    public AdminUserApprovalController(AdminUserApprovalService service) {
        this.service = service;
    }

    @GetMapping("/dashboard-stats")
    public AdminDashboardStatsResponse getDashboardStats() {
        return service.getDashboardStats();
    }

    @GetMapping("/pending-users")
    public List<PendingUserResponse> getPendingUsers() {
        return service.getPendingUsers();
    }

    @GetMapping("/approved-users")
    public List<AcceptedUserResponse> getApprovedUsers() {
        return service.getApprovedUsers();
    }

    @GetMapping("/rejected-users")
    public List<RejectedUserResponse> getRejectedUsers() {
        return service.getRejectedUsers();
    }

    @PostMapping("/users/{id}/approve")
    public MessageResponse approveUser(
            @PathVariable Long id,
            @Valid @RequestBody ApproveUserRequest request
    ) {
        service.approveUser(id, request.role());
        return new MessageResponse("Utilisateur approuvé avec succès");
    }

    @PostMapping("/users/{id}/reject")
    public MessageResponse rejectUser(@PathVariable Long id) {
        service.rejectUser(id);
        return new MessageResponse("Utilisateur rejeté avec succès");
    }

    @DeleteMapping("/rejected-users")
    public MessageResponse deleteRejectedUsers() {
        service.deleteAllRejectedUsers();
        return new MessageResponse("Tous les utilisateurs rejetés ont été supprimés");
    }
}