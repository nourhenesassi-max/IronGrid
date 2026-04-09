package com.example.irongrid.notification;

import com.example.irongrid.user.User;
import com.example.irongrid.user.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final UserRepository userRepository;

    public NotificationService(
            NotificationRepository notificationRepository,
            UserRepository userRepository
    ) {
        this.notificationRepository = notificationRepository;
        this.userRepository = userRepository;
    }

    public Notification createProjectAssignedNotification(User manager, User employee, String projectName) {
        Notification notification = new Notification();
        notification.setSender(manager);
        notification.setReceiver(employee);
        notification.setType(NotificationType.PROJECT_ASSIGNED);
        notification.setTitle("Nouveau projet assigné");
        notification.setContent("Le manager vous a assigné le projet : " + projectName);
        notification.setRead(false);
        return notificationRepository.save(notification);
    }

    public Notification createProjectUpdatedNotification(User manager, User employee, String projectName) {
        Notification notification = new Notification();
        notification.setSender(manager);
        notification.setReceiver(employee);
        notification.setType(NotificationType.PROJECT_UPDATED);
        notification.setTitle("Projet mis à jour");
        notification.setContent("Le manager a mis à jour le projet : " + projectName);
        notification.setRead(false);
        return notificationRepository.save(notification);
    }

    public Notification sendNotificationToEmployee(
            String title,
            String content,
            NotificationType type,
            Long receiverId
    ) {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();

        User sender = userRepository.findByEmail(email)
                .orElseThrow(() -> new EntityNotFoundException("Utilisateur expéditeur introuvable"));

        User receiver = userRepository.findById(receiverId)
                .orElseThrow(() -> new EntityNotFoundException("Destinataire introuvable"));

        Notification notification = new Notification();
        notification.setTitle(title);
        notification.setContent(content);
        notification.setType(type);
        notification.setRead(false);
        notification.setSender(sender);
        notification.setReceiver(receiver);

        return notificationRepository.save(notification);
    }

    public void notifyManagersAboutAcceptedEmployee(User employee) {
        List<User> managers = userRepository.findApprovedManagersByTeamLabel(employee.getTeamLabel());

        for (User manager : managers) {
            Notification notification = new Notification();
            notification.setSender(employee);
            notification.setReceiver(manager);
            notification.setType(NotificationType.NEW_EMPLOYEE_ACCEPTED);
            notification.setTitle("Nouvel employé dans l'équipe");
            notification.setContent(employee.getDisplayName() + " a rejoint votre équipe");
            notification.setRead(false);
            notificationRepository.save(notification);
        }
    }
}