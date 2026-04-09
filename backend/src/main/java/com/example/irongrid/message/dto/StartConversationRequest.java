package com.example.irongrid.message.dto;

import jakarta.validation.constraints.NotNull;

public class StartConversationRequest {

    @NotNull
    private Long receiverId;

    public Long getReceiverId() {
        return receiverId;
    }

    public void setReceiverId(Long receiverId) {
        this.receiverId = receiverId;
    }
}