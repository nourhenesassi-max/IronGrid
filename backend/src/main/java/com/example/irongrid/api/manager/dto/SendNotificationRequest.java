package com.example.irongrid.api.manager.dto;
import com.example.irongrid.notification.NotificationType;
public class SendNotificationRequest {
    private String title;
    private String content;
    private NotificationType type;
    private Long receiverId;
    public String getTitle() {
        return title;}
    public void setTitle(String title) {
        this.title = title;}
    public String getContent() {
        return content;}
    public void setContent(String content) {
        this.content = content;}
    public NotificationType getType() {
        return type;}
    public void setType(NotificationType type) {
        this.type = type;}
    public Long getReceiverId() {
        return receiverId;}
    public void setReceiverId(Long receiverId) {
        this.receiverId = receiverId;}
}