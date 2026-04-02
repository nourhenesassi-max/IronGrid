package com.example.irongrid.user;

import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@RestController
public class UserMessageController {

    private final UserRepository userRepository;

    public UserMessageController(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @GetMapping("/api/users/messageable")
    public List<UserSummaryDto> getMessageableUsers(Authentication authentication) {
        User me = userRepository.findByEmail(authentication.getName().trim().toLowerCase())
                .orElseThrow(() -> new RuntimeException("Utilisateur introuvable"));

        String myRole = me.getRole() == null || me.getRole().getName() == null
                ? ""
                : me.getRole().getName().trim().toLowerCase();

        List<User> users = switch (myRole) {
            case "employe" -> {
                List<User> result = new ArrayList<>();
                result.addAll(
                        userRepository.findMessageableUsers(
                                List.of("employe", "rh", "manager"),
                                me.getId()
                        )
                );
                yield result;
            }
            case "manager" -> {
                List<User> result = new ArrayList<>();
                result.addAll(userRepository.findApprovedEmployeesByTeamLabel(me.getTeamLabel()));
                result.addAll(userRepository.findApprovedRhUsers());
                result.removeIf(u -> u.getId().equals(me.getId()));
                yield result;
            }
            case "admin" -> {
                List<User> result = new ArrayList<>();
                result.addAll(
                        userRepository.findMessageableUsers(
                                List.of("employe", "rh", "manager", "admin"),
                                me.getId()
                        )
                );
                yield result;
            }
            default -> throw new AccessDeniedException("Ce rôle ne peut pas utiliser cette liste");
        };

        Map<Long, User> uniqueUsers = new LinkedHashMap<>();
        for (User user : users) {
            uniqueUsers.put(user.getId(), user);
        }

        return uniqueUsers.values().stream()
                .sorted(Comparator.comparing(User::getDisplayName, String.CASE_INSENSITIVE_ORDER))
                .map(u -> new UserSummaryDto(
                        u.getId(),
                        u.getDisplayName(),
                        formatRole(u.getRole() == null ? "" : u.getRole().getName()),
                        u.getEmail(),
                        u.getAvatarUrl() // ✅ added
                ))
                .toList();
    }

    private String formatRole(String role) {
        String r = role == null ? "" : role.trim().toLowerCase();
        return switch (r) {
            case "employe" -> "Employé";
            case "rh" -> "RH";
            case "manager" -> "Manager";
            case "finance" -> "Finance";
            case "it" -> "IT";
            case "admin" -> "Admin";
            default -> role;
        };
    }
}