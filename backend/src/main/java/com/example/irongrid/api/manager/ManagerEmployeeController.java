package com.example.irongrid.api.manager;

import com.example.irongrid.user.AccountStatus;
import com.example.irongrid.user.User;
import com.example.irongrid.user.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/users")
public class ManagerEmployeeController {

    private final UserRepository userRepository;

    public ManagerEmployeeController(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @GetMapping("/employees")
    public List<Map<String, Object>> getEmployees(Authentication authentication) {
        System.out.println("Authenticated user = " + authentication.getName());

        User manager = userRepository.findByEmail(authentication.getName().trim().toLowerCase())
                .orElseThrow(() -> new EntityNotFoundException("Manager introuvable"));

        String managerRole = manager.getRole() == null || manager.getRole().getName() == null
                ? ""
                : manager.getRole().getName().trim().toLowerCase();

        System.out.println("Manager email = " + manager.getEmail());
        System.out.println("Manager role = " + managerRole);

        if (!"manager".equals(managerRole)) {
            throw new AccessDeniedException("Accès refusé");
        }

        return userRepository.findByStatusOrderByIdDesc(AccountStatus.APPROVED)
                .stream()
                .filter(user -> user.getRole() != null
                        && user.getRole().getName() != null
                        && "employe".equalsIgnoreCase(user.getRole().getName()))
                .map(user -> {
                    Map<String, Object> item = new HashMap<>();

                    final String firstName = user.getFirstName() == null ? "" : user.getFirstName();
                    final String lastName = user.getLastName() == null ? "" : user.getLastName();
                    final String name = buildDisplayName(user);

                    item.put("id", user.getId());
                    item.put("firstName", firstName);
                    item.put("lastName", lastName);
                    item.put("email", user.getEmail() == null ? "" : user.getEmail());
                    item.put("name", name);
                    item.put("teamLabel", user.getTeamLabel() == null ? "" : user.getTeamLabel());
                    item.put("projectLabel", user.getProjectLabel() == null ? "" : user.getProjectLabel());
                    item.put("role", "EMPLOYE");
                    item.put("avatarUrl", user.getAvatarUrl() == null ? "" : user.getAvatarUrl());

                    return item;
                })
                .toList();
    }

    @DeleteMapping("/employees/{employeeId}")
    public ResponseEntity<Void> deleteEmployee(
            @PathVariable Long employeeId,
            Authentication authentication
    ) {
        User manager = userRepository.findByEmail(authentication.getName().trim().toLowerCase())
                .orElseThrow(() -> new EntityNotFoundException("Manager introuvable"));

        String managerRole = manager.getRole() == null || manager.getRole().getName() == null
                ? ""
                : manager.getRole().getName().trim().toLowerCase();

        if (!"manager".equals(managerRole)) {
            throw new AccessDeniedException("Accès refusé");
        }

        User employee = userRepository.findById(employeeId)
                .orElseThrow(() -> new EntityNotFoundException("Employé introuvable"));

        if (employee.getRole() == null || employee.getRole().getName() == null
                || !"employe".equalsIgnoreCase(employee.getRole().getName())) {
            throw new AccessDeniedException("Suppression autorisée uniquement pour un employé");
        }

        userRepository.delete(employee);

        return ResponseEntity.noContent().build();
    }

    private String buildDisplayName(User user) {
        if (user.getName() != null && !user.getName().trim().isEmpty()) {
            return user.getName().trim();
        }

        String firstName = user.getFirstName() == null ? "" : user.getFirstName().trim();
        String lastName = user.getLastName() == null ? "" : user.getLastName().trim();
        String fullName = (firstName + " " + lastName).trim();

        return fullName;
    }
}