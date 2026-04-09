package com.example.irongrid.admin;

import com.example.irongrid.admin.dto.AcceptedUserResponse;
import com.example.irongrid.admin.dto.AdminDashboardStatsResponse;
import com.example.irongrid.admin.dto.PendingUserResponse;
import com.example.irongrid.admin.dto.RejectedUserResponse;
import com.example.irongrid.auth.MailService;
import com.example.irongrid.notification.NotificationService;
import com.example.irongrid.user.AccountStatus;
import com.example.irongrid.user.RoleEntity;
import com.example.irongrid.user.RoleRepository;
import com.example.irongrid.user.User;
import com.example.irongrid.user.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Set;

@Service
public class AdminUserApprovalService {

    private static final Set<String> ALLOWED_ASSIGNABLE_ROLES = Set.of(
            "EMPLOYE",
            "MANAGER",
            "RH",
            "FINANCE"
    );

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final MailService mailService;
    private final NotificationService notificationService;

    public AdminUserApprovalService(
            UserRepository userRepository,
            RoleRepository roleRepository,
            MailService mailService,
            NotificationService notificationService
    ) {
        this.userRepository = userRepository;
        this.roleRepository = roleRepository;
        this.mailService = mailService;
        this.notificationService = notificationService;
    }

    public AdminDashboardStatsResponse getDashboardStats() {
        long pendingRequests = userRepository.countByStatus(AccountStatus.PENDING);
        long approvedUsers = userRepository.countByStatus(AccountStatus.APPROVED);
        long rejectedUsers = userRepository.countByStatus(AccountStatus.REJECTED);

        return new AdminDashboardStatsResponse(
                pendingRequests,
                approvedUsers,
                rejectedUsers
        );
    }

    public List<PendingUserResponse> getPendingUsers() {
        return userRepository.findByStatusOrderByIdDesc(AccountStatus.PENDING)
                .stream()
                .map(user -> new PendingUserResponse(
                        user.getId(),
                        user.getFirstName(),
                        user.getLastName(),
                        user.getEmail(),
                        user.getPhone(),
                        user.getAddress(),
                        user.getTeamLabel(),
                        user.getProjectLabel(),
                        user.getStatus().name()
                ))
                .toList();
    }

    public List<AcceptedUserResponse> getApprovedUsers() {
        return userRepository.findByStatusOrderByIdDesc(AccountStatus.APPROVED)
                .stream()
                .map(user -> new AcceptedUserResponse(
                        user.getId(),
                        user.getFirstName(),
                        user.getLastName(),
                        user.getEmail(),
                        user.getPhone(),
                        user.getAddress(),
                        user.getTeamLabel(),
                        user.getProjectLabel(),
                        user.getStatus().name(),
                        user.getRole() != null ? user.getRole().getName() : null
                ))
                .toList();
    }

    public List<RejectedUserResponse> getRejectedUsers() {
        return userRepository.findByStatusOrderByIdDesc(AccountStatus.REJECTED)
                .stream()
                .map(user -> new RejectedUserResponse(
                        user.getId(),
                        user.getFirstName(),
                        user.getLastName(),
                        user.getEmail(),
                        user.getPhone(),
                        user.getAddress(),
                        user.getTeamLabel(),
                        user.getProjectLabel(),
                        user.getStatus().name()
                ))
                .toList();
    }

    public void approveUser(Long userId, String roleName) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Utilisateur introuvable"
                ));

        if (user.getStatus() != AccountStatus.PENDING) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Cet utilisateur n'est plus en attente"
            );
        }

        String normalizedRole = roleName == null ? "" : roleName.trim().toUpperCase();

        if (!ALLOWED_ASSIGNABLE_ROLES.contains(normalizedRole)) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Rôle non autorisé"
            );
        }

        RoleEntity role = roleRepository.findByNameIgnoreCase(normalizedRole)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.BAD_REQUEST,
                        "Rôle introuvable"
                ));

        user.setRole(role);
        user.setStatus(AccountStatus.APPROVED);
        userRepository.save(user);

        if ("EMPLOYE".equalsIgnoreCase(normalizedRole)) {
            notificationService.notifyManagersAboutAcceptedEmployee(user);
        }

        mailService.sendApprovedAccountMail(user);
    }

    public void rejectUser(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Utilisateur introuvable"
                ));

        if (user.getStatus() != AccountStatus.PENDING) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Cet utilisateur n'est plus en attente"
            );
        }

        user.setStatus(AccountStatus.REJECTED);
        userRepository.save(user);

        mailService.sendRejectedAccountMail(user.getEmail(), user.getDisplayName());
    }

    public void deleteAllRejectedUsers() {
        List<User> rejectedUsers =
                userRepository.findByStatusOrderByIdDesc(AccountStatus.REJECTED);

        if (rejectedUsers.isEmpty()) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Aucun utilisateur rejeté à supprimer"
            );
        }

        userRepository.deleteAll(rejectedUsers);
    }
}