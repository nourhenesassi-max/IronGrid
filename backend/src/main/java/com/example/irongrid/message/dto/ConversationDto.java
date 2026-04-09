package com.example.irongrid.message.dto;

import java.util.List;

public class ConversationDto {

    private Long id;
    private Long contactId;
    private String contactName;
    private String contactRole;
    private String avatarUrl;
    private MessageDto lastMessage;
    private List<MessageDto> messages;

    private boolean group;
    private String groupName;
    private Integer memberCount;

    private boolean hasUnread;
    private int unreadCount;

    // Keeps old calls working
    public ConversationDto(
            Long id,
            Long contactId,
            String contactName,
            String contactRole,
            MessageDto lastMessage,
            List<MessageDto> messages,
            boolean group,
            String groupName,
            Integer memberCount
    ) {
        this(
                id,
                contactId,
                contactName,
                contactRole,
                null,
                lastMessage,
                messages,
                group,
                groupName,
                memberCount,
                0
        );
    }

    // Keeps intermediate calls working
    public ConversationDto(
            Long id,
            Long contactId,
            String contactName,
            String contactRole,
            String avatarUrl,
            MessageDto lastMessage,
            List<MessageDto> messages,
            boolean group,
            String groupName,
            Integer memberCount
    ) {
        this(
                id,
                contactId,
                contactName,
                contactRole,
                avatarUrl,
                lastMessage,
                messages,
                group,
                groupName,
                memberCount,
                0
        );
    }

    // Full constructor
    public ConversationDto(
            Long id,
            Long contactId,
            String contactName,
            String contactRole,
            String avatarUrl,
            MessageDto lastMessage,
            List<MessageDto> messages,
            boolean group,
            String groupName,
            Integer memberCount,
            int unreadCount
    ) {
        this.id = id;
        this.contactId = contactId;
        this.contactName = contactName;
        this.contactRole = contactRole;
        this.avatarUrl = avatarUrl;
        this.lastMessage = lastMessage;
        this.messages = messages;
        this.group = group;
        this.groupName = groupName;
        this.memberCount = memberCount;
        this.unreadCount = unreadCount;
        this.hasUnread = unreadCount > 0;
    }

    public Long getId() {
        return id;
    }

    public Long getContactId() {
        return contactId;
    }

    public String getContactName() {
        return contactName;
    }

    public String getContactRole() {
        return contactRole;
    }

    public String getAvatarUrl() {
        return avatarUrl;
    }

    // Compatibility getter for frontend code using photoUrl
    public String getPhotoUrl() {
        return avatarUrl;
    }

    // Compatibility getter for frontend code using profilePicture
    public String getProfilePicture() {
        return avatarUrl;
    }

    public MessageDto getLastMessage() {
        return lastMessage;
    }

    public List<MessageDto> getMessages() {
        return messages;
    }

    public boolean isGroup() {
        return group;
    }

    public String getGroupName() {
        return groupName;
    }

    public Integer getMemberCount() {
        return memberCount;
    }

    public boolean isHasUnread() {
        return hasUnread;
    }

    public int getUnreadCount() {
        return unreadCount;
    }
}