package com.example.irongrid.api.manager;

import com.example.irongrid.api.manager.dto.AssignProjectRequest;
import com.example.irongrid.api.manager.dto.ManagerProjectResponse;
import com.example.irongrid.api.manager.dto.ManagerTaskResponse;
import com.example.irongrid.api.manager.dto.UpdateProjectRequest;
import com.example.irongrid.manager.ManagerProject;
import com.example.irongrid.manager.ManagerProjectService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/manager/projects")
public class ManagerProjectController {

    private final ManagerProjectService managerProjectService;

    public ManagerProjectController(ManagerProjectService managerProjectService) {
        this.managerProjectService = managerProjectService;
    }

    @PostMapping
    public ManagerProjectResponse assignProject(@RequestBody AssignProjectRequest request) {
        ManagerProject project = managerProjectService.assignProject(request);
        return map(project);
    }

    @PutMapping("/{id}")
    public ManagerProjectResponse updateProject(
            @PathVariable Long id,
            @RequestBody UpdateProjectRequest request
    ) {
        ManagerProject project = managerProjectService.updateProject(id, request);
        return map(project);
    }

    @GetMapping
    public List<ManagerProjectResponse> myProjects() {
        return managerProjectService.getManagerProjects()
                .stream()
                .map(this::map)
                .toList();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteProject(@PathVariable Long id) {
        managerProjectService.deleteProject(id);
        return ResponseEntity.noContent().build();
    }

    private ManagerProjectResponse map(ManagerProject project) {
        String employeeName = buildEmployeeName(project);

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
                employeeName,
                project.getDeadline() != null ? project.getDeadline().toString() : "",
                project.getPriority() != null ? project.getPriority() : "",
                project.getDescription() != null ? project.getDescription() : "",
                tasks
        );
    }

    private String buildEmployeeName(ManagerProject project) {
        try {
            String firstName = project.getEmployee().getFirstName();
            String lastName = project.getEmployee().getLastName();

            if ((firstName == null || firstName.isBlank()) &&
                (lastName == null || lastName.isBlank())) {
                return project.getEmployee().getEmail();
            }

            return ((firstName == null ? "" : firstName) + " " +
                    (lastName == null ? "" : lastName)).trim();
        } catch (Exception e) {
            return "Employé";
        }
    }
}