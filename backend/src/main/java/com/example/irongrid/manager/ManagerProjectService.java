package com.example.irongrid.manager;

import com.example.irongrid.api.manager.dto.AssignProjectRequest;
import com.example.irongrid.api.manager.dto.ManagerTaskRequest;
import com.example.irongrid.api.manager.dto.UpdateProjectRequest;
import com.example.irongrid.notification.NotificationService;
import com.example.irongrid.user.User;
import com.example.irongrid.user.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Service
public class ManagerProjectService {

    private final ManagerProjectRepository managerProjectRepository;
    private final UserRepository userRepository;
    private final NotificationService notificationService;

    public ManagerProjectService(
            ManagerProjectRepository managerProjectRepository,
            UserRepository userRepository,
            NotificationService notificationService
    ) {
        this.managerProjectRepository = managerProjectRepository;
        this.userRepository = userRepository;
        this.notificationService = notificationService;
    }

    public ManagerProject assignProject(AssignProjectRequest request) {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();

        User manager = userRepository.findByEmail(email)
                .orElseThrow(() -> new EntityNotFoundException("Manager introuvable"));

        User employee = userRepository.findById(request.getEmployeeId())
                .orElseThrow(() -> new EntityNotFoundException("Employé introuvable"));

        ManagerProject project = new ManagerProject();
        project.setProjectName(request.getProjectName());
        project.setDeadline(LocalDate.parse(request.getDeadline()));
        project.setPriority(request.getPriority());
        project.setDescription(request.getDescription() != null ? request.getDescription() : "");
        project.setManager(manager);
        project.setEmployee(employee);

        if (request.getTasks() != null) {
            for (ManagerTaskRequest taskRequest : request.getTasks()) {
                if (taskRequest.getTitle() != null && !taskRequest.getTitle().isBlank()) {
                    ManagerTask task = new ManagerTask();
                    task.setTitle(taskRequest.getTitle());

                    if (taskRequest.getDeadline() != null && !taskRequest.getDeadline().isBlank()) {
                        task.setDeadline(LocalDate.parse(taskRequest.getDeadline()));
                    }

                    task.setIsCompleted(Boolean.TRUE.equals(taskRequest.getIsCompleted()));
                    project.addTask(task);
                }
            }
        }

        ManagerProject saved = managerProjectRepository.save(project);

        notificationService.createProjectAssignedNotification(
                manager,
                employee,
                saved.getProjectName()
        );

        return saved;
    }

    @Transactional
    public ManagerProject updateProject(Long projectId, UpdateProjectRequest request) {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();

        User manager = userRepository.findByEmail(email)
                .orElseThrow(() -> new EntityNotFoundException("Manager introuvable"));

        ManagerProject project = managerProjectRepository
                .findByIdAndManagerId(projectId, manager.getId())
                .orElseThrow(() -> new EntityNotFoundException("Projet introuvable"));

        User employee = userRepository.findById(request.getEmployeeId())
                .orElseThrow(() -> new EntityNotFoundException("Employé introuvable"));

        project.setProjectName(request.getProjectName());
        project.setDeadline(LocalDate.parse(request.getDeadline()));
        project.setPriority(request.getPriority());
        project.setDescription(request.getDescription() != null ? request.getDescription() : "");
        project.setEmployee(employee);

        project.getTasks().clear();

        if (request.getTasks() != null) {
            for (ManagerTaskRequest taskRequest : request.getTasks()) {
                if (taskRequest.getTitle() != null && !taskRequest.getTitle().isBlank()) {
                    ManagerTask task = new ManagerTask();
                    task.setTitle(taskRequest.getTitle());

                    if (taskRequest.getDeadline() != null && !taskRequest.getDeadline().isBlank()) {
                        task.setDeadline(LocalDate.parse(taskRequest.getDeadline()));
                    }

                    task.setIsCompleted(Boolean.TRUE.equals(taskRequest.getIsCompleted()));
                    project.addTask(task);
                }
            }
        }

        ManagerProject savedProject = managerProjectRepository.saveAndFlush(project);

        notificationService.createProjectUpdatedNotification(
                manager,
                employee,
                savedProject.getProjectName()
        );

        return savedProject;
    }

    public List<ManagerProject> getManagerProjects() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();

        User manager = userRepository.findByEmail(email)
                .orElseThrow(() -> new EntityNotFoundException("Manager introuvable"));

        return managerProjectRepository.findByManagerId(manager.getId());
    }

    public List<ManagerProject> getEmployeeProjects() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();

        User employee = userRepository.findByEmail(email)
                .orElseThrow(() -> new EntityNotFoundException("Employé introuvable"));

        return managerProjectRepository.findByEmployeeId(employee.getId());
    }

    public void deleteProject(Long projectId) {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();

        User manager = userRepository.findByEmail(email)
                .orElseThrow(() -> new EntityNotFoundException("Manager introuvable"));

        ManagerProject project = managerProjectRepository
                .findByIdAndManagerId(projectId, manager.getId())
                .orElseThrow(() -> new EntityNotFoundException("Projet introuvable"));

        managerProjectRepository.delete(project);
    }
}