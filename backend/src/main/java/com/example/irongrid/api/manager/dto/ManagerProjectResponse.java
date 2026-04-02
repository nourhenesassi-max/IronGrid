package com.example.irongrid.api.manager.dto;

import java.util.List;

public class ManagerProjectResponse {

    private Long id;
    private String projectName;
    private String employeeName;
    private String deadline;
    private String priority;
    private String description;
    private List<ManagerTaskResponse> tasks;

    public ManagerProjectResponse(
            Long id,
            String projectName,
            String employeeName,
            String deadline,
            String priority,
            String description,
            List<ManagerTaskResponse> tasks
    ) {
        this.id = id;
        this.projectName = projectName;
        this.employeeName = employeeName;
        this.deadline = deadline;
        this.priority = priority;
        this.description = description;
        this.tasks = tasks;
    }

    public Long getId() {
        return id;
    }

    public String getProjectName() {
        return projectName;
    }

    public String getEmployeeName() {
        return employeeName;
    }

    public String getDeadline() {
        return deadline;
    }

    public String getPriority() {
        return priority;
    }

    public String getDescription() {
        return description;
    }

    public List<ManagerTaskResponse> getTasks() {
        return tasks;
    }
}