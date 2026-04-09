package com.example.irongrid.api.manager.dto;
import com.example.irongrid.notification.NotificationType;
import java.time.LocalDateTime;
public class NotificationResponse {
    private Long id;
    private String title;
    private String content;
    private NotificationType type;
    private boolean read;
    private LocalDateTime createdAt;
    public NotificationResponse(
            Long id,
            String title,
            String content,
            NotificationType type,
            boolean read,
            LocalDateTime createdAt
    ) {
        this.id = id;
        this.title = title;
        this.content = content;
        this.type = type;
        this.read = read;
        this.createdAt = createdAt;
    }
    public Long getId() {
        return id;}
    public String getTitle() {
        return title;}
    public String getContent() {
        return content;}
    public NotificationType getType() {
        return type;}
    public boolean isRead() {
        return read;}
    public LocalDateTime getCreatedAt() {
        return createdAt;}
}