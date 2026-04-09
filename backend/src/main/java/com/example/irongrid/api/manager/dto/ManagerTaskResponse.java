package com.example.irongrid.api.manager.dto;

public class ManagerTaskResponse {

    private String id;
    private String title;
    private String deadline;
    private Boolean isCompleted;

    public ManagerTaskResponse(String id, String title, String deadline, Boolean isCompleted) {
        this.id = id;
        this.title = title;
        this.deadline = deadline;
        this.isCompleted = isCompleted;
    }

    public String getId() {
        return id;
    }

    public String getTitle() {
        return title;
    }

    public String getDeadline() {
        return deadline;
    }

    public Boolean getIsCompleted() {
        return isCompleted;
    }
}