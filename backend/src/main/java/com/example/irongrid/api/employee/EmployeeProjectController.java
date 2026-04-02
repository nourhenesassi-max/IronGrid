package com.example.irongrid.api.employee;

import com.example.irongrid.api.manager.dto.ManagerProjectResponse;
import com.example.irongrid.api.manager.dto.ManagerTaskResponse;
import com.example.irongrid.manager.ManagerProject;
import com.example.irongrid.manager.ManagerProjectService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/employee/projects")
public class EmployeeProjectController {

    private final ManagerProjectService managerProjectService;

    public EmployeeProjectController(ManagerProjectService managerProjectService) {
        this.managerProjectService = managerProjectService;
    }

    @GetMapping
    public List<ManagerProjectResponse> myProjects() {
        return managerProjectService.getEmployeeProjects()
                .stream()
                .map(this::map)
                .toList();
    }

    private ManagerProjectResponse map(ManagerProject project) {
        String managerName = "Manager";

        try {
            String firstName = project.getManager().getFirstName();
            String lastName = project.getManager().getLastName();

            managerName = ((firstName == null ? "" : firstName) + " " +
                    (lastName == null ? "" : lastName)).trim();

            if (managerName.isBlank()) {
                managerName = project.getManager().getEmail();
            }
        } catch (Exception ignored) {
        }

        List<ManagerTaskResponse> tasks = project.getTasks()
                .stream()
                .map(task -> new ManagerTaskResponse(
                        task.getId() != null ? task.getId().toString() : "",
                        task.getTitle() != null ? task.getTitle() : "",
                        task.getDeadline() != null ? task.getDeadline().toString() : "",
                        task.getIsCompleted()
                ))
                .toList();

        return new ManagerProjectResponse(
                project.getId(),
                project.getProjectName() != null ? project.getProjectName() : "",
                managerName,
                project.getDeadline() != null ? project.getDeadline().toString() : "",
                project.getPriority() != null ? project.getPriority() : "",
                project.getDescription() != null ? project.getDescription() : "",
                tasks
        );
    }
}