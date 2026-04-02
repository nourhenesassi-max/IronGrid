package com.example.irongrid.api.manager.dto;

import java.util.List;

public class UpdateProjectRequest {

    private String projectName;
    private Long employeeId;
    private String deadline;
    private String priority;
    private String description;
    private List<ManagerTaskRequest> tasks;

    public UpdateProjectRequest() {
    }

    public String getProjectName() {
        return projectName;
    }

    public void setProjectName(String projectName) {
        this.projectName = projectName;
    }

    public Long getEmployeeId() {
        return employeeId;
    }

    public void setEmployeeId(Long employeeId) {
        this.employeeId = employeeId;
    }

    public String getDeadline() {
        return deadline;
    }

    public void setDeadline(String deadline) {
        this.deadline = deadline;
    }

    public String getPriority() {
        return priority;
    }

    public void setPriority(String priority) {
        this.priority = priority;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public List<ManagerTaskRequest> getTasks() {
        return tasks;
    }

    public void setTasks(List<ManagerTaskRequest> tasks) {
        this.tasks = tasks;
    }
}