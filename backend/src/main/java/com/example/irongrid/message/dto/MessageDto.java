
package com.example.irongrid.message.dto;

public class MessageDto {

    private Long id;
    private Long senderId;
    private String senderName;
    private String senderRole;
    private String senderAvatarUrl; // ✅ avatar
    private String content;
    private String sentAt;
    private boolean mine;
    private boolean deleted;

    // ✅ REQUIRED for Jackson / serialization
    public MessageDto() {
    }

    public MessageDto(
            Long id,
            Long senderId,
            String senderName,
            String senderRole,
            String senderAvatarUrl,
            String content,
            String sentAt,
            boolean mine,
            boolean deleted
    ) {
        this.id = id;
        this.senderId = senderId;
        this.senderName = senderName;
        this.senderRole = senderRole;
        this.senderAvatarUrl = senderAvatarUrl;
        this.content = content;
        this.sentAt = sentAt;
        this.mine = mine;
        this.deleted = deleted;
    }

    // ✅ Getters

    public Long getId() {
        return id;
    }

    public Long getSenderId() {
        return senderId;
    }

    public String getSenderName() {
        return senderName;
    }

    public String getSenderRole() {
        return senderRole;
    }

    public String getSenderAvatarUrl() {
        return senderAvatarUrl;
    }

    public String getContent() {
        return content;
    }

    public String getSentAt() {
        return sentAt;
    }

    public boolean isMine() {
        return mine;
    }

    public boolean isDeleted() {
        return deleted;
    }

    // ✅ Setters (safe addition, does not break anything)

    public void setId(Long id) {
        this.id = id;
    }

    public void setSenderId(Long senderId) {
        this.senderId = senderId;
    }

    public void setSenderName(String senderName) {
        this.senderName = senderName;
    }

    public void setSenderRole(String senderRole) {
        this.senderRole = senderRole;
    }

    public void setSenderAvatarUrl(String senderAvatarUrl) {
        this.senderAvatarUrl = senderAvatarUrl;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public void setSentAt(String sentAt) {
        this.sentAt = sentAt;
    }

    public void setMine(boolean mine) {
        this.mine = mine;
    }

    public void setDeleted(boolean deleted) {
        this.deleted = deleted;
    }
}
