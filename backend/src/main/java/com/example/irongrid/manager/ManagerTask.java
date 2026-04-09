package com.example.irongrid.manager;

import jakarta.persistence.*;

import java.time.LocalDate;

@Entity
@Table(name = "manager_tasks")
public class ManagerTask {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String title;

    private LocalDate deadline;

    @Column(name = "is_completed", nullable = false)
    private boolean isCompleted = false;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "project_id")
    private ManagerProject project;

    public ManagerTask() {
        this.isCompleted = false;
    }

    public ManagerTask(String title) {
        this.title = title;
        this.isCompleted = false;
    }

    @PrePersist
    public void prePersist() {
        this.isCompleted = this.isCompleted;
    }

    public Long getId() {
        return id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public LocalDate getDeadline() {
        return deadline;
    }

    public void setDeadline(LocalDate deadline) {
        this.deadline = deadline;
    }

    public boolean isCompleted() {
        return isCompleted;
    }

    public boolean getIsCompleted() {
        return isCompleted;
    }

    public void setCompleted(boolean completed) {
        this.isCompleted = completed;
    }

    public void setIsCompleted(boolean completed) {
        this.isCompleted = completed;
    }

    public ManagerProject getProject() {
        return project;
    }

    public void setProject(ManagerProject project) {
        this.project = project;
    }
}