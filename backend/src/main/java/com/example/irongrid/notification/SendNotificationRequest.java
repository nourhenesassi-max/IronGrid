package com.example.irongrid.notification;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public class SendNotificationRequest {

    @NotBlank
    private String title;

    @NotBlank
    private String content;

    @NotBlank
    private String type;

    @NotNull
    private Long receiverId;

    public String getTitle() {
        return title;
    }

    public String getContent() {
        return content;
    }

    public String getType() {
        return type;
    }

    public Long getReceiverId() {
        return receiverId;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public void setType(String type) {
        this.type = type;
    }

    public void setReceiverId(Long receiverId) {
        this.receiverId = receiverId;
    }
}