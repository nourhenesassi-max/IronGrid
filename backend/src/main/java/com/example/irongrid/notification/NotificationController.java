package com.example.irongrid.notification;

import com.example.irongrid.api.manager.dto.NotificationResponse;
import com.example.irongrid.api.manager.dto.SendNotificationRequest;
import com.example.irongrid.user.User;
import com.example.irongrid.user.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/notifications")
public class NotificationController {

    private final NotificationRepository notificationRepository;
    private final UserRepository userRepository;
    private final NotificationService notificationService;

    public NotificationController(
            NotificationRepository notificationRepository,
            UserRepository userRepository,
            NotificationService notificationService
    ) {
        this.notificationRepository = notificationRepository;
        this.userRepository = userRepository;
        this.notificationService = notificationService;
    }

    @GetMapping
    public List<NotificationResponse> myNotifications() {
        User user = getAuthenticatedUser();

        return notificationRepository.findByReceiver_IdOrderByCreatedAtDesc(user.getId())
                .stream()
                .map(n -> new NotificationResponse(
                        n.getId(),
                        n.getTitle(),
                        n.getContent(),
                        n.getType(),
                        n.isRead(),
                        n.getCreatedAt()
                ))
                .toList();
    }

    @PatchMapping("/{id}/read")
    public ResponseEntity<Void> markAsRead(@PathVariable Long id) {
        User user = getAuthenticatedUser();

        Notification notification = notificationRepository.findByIdAndReceiver_Id(id, user.getId())
                .orElseThrow(() -> new EntityNotFoundException("Notification introuvable"));

        notification.setRead(true);
        notificationRepository.save(notification);

        return ResponseEntity.ok().build();
    }

    @PostMapping("/send")
    public NotificationResponse sendNotification(@RequestBody @Valid SendNotificationRequest request) {
        if (request.getTitle() == null || request.getTitle().isBlank()) {
            throw new IllegalArgumentException("Le titre est obligatoire");
        }
        if (request.getContent() == null || request.getContent().isBlank()) {
            throw new IllegalArgumentException("Le contenu est obligatoire");
        }
        if (request.getType() == null) {
            throw new IllegalArgumentException("Le type est obligatoire");
        }
        if (request.getReceiverId() == null) {
            throw new IllegalArgumentException("Le destinataire est obligatoire");
        }

        Notification notification = notificationService.sendNotificationToEmployee(
                request.getTitle().trim(),
                request.getContent().trim(),
                request.getType(),
                request.getReceiverId()
        );

        return new NotificationResponse(
                notification.getId(),
                notification.getTitle(),
                notification.getContent(),
                notification.getType(),
                notification.isRead(),
                notification.getCreatedAt()
        );
    }

    private User getAuthenticatedUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication == null || authentication.getName() == null || authentication.getName().isBlank()) {
            throw new EntityNotFoundException("Utilisateur non authentifié");
        }

        String email = authentication.getName().trim().toLowerCase();

        return userRepository.findByEmail(email)
                .orElseThrow(() -> new EntityNotFoundException("Utilisateur introuvable: " + email));
    }
}