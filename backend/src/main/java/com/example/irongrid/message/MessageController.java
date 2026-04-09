package com.example.irongrid.message;

import com.example.irongrid.message.dto.ConversationDto;
import com.example.irongrid.message.dto.CreateGroupConversationRequest;
import com.example.irongrid.message.dto.MessageDto;
import com.example.irongrid.message.dto.SendMessageRequest;
import com.example.irongrid.message.dto.StartConversationRequest;
import jakarta.validation.Valid;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/messages")
public class MessageController {

    private final MessageService messageService;

    public MessageController(MessageService messageService) {
        this.messageService = messageService;
    }

    @GetMapping("/conversations")
    public List<ConversationDto> getMyConversations(Authentication authentication) {
        return messageService.getMyConversations(authentication.getName());
    }

    @GetMapping("/conversations/{conversationId}")
    public ConversationDto getConversation(
            @PathVariable Long conversationId,
            Authentication authentication
    ) {
        return messageService.getConversation(authentication.getName(), conversationId);
    }

    @PostMapping("/conversations")
    public ConversationDto startConversation(
            @Valid @RequestBody StartConversationRequest request,
            Authentication authentication
    ) {
        return messageService.startConversation(
                authentication.getName(),
                request.getReceiverId()
        );
    }

    @PostMapping("/groups")
    public ConversationDto createGroupConversation(
            @Valid @RequestBody CreateGroupConversationRequest request,
            Authentication authentication
    ) {
        return messageService.createGroupConversation(
                authentication.getName(),
                request.getGroupName(),
                request.getMemberIds()
        );
    }

    @PostMapping("/conversations/{conversationId}/messages")
    public MessageDto sendMessage(
            @PathVariable Long conversationId,
            @Valid @RequestBody SendMessageRequest request,
            Authentication authentication
    ) {
        return messageService.sendMessage(
                authentication.getName(),
                conversationId,
                request.getContent()
        );
    }

    @DeleteMapping("/conversations/{conversationId}")
    public void deleteConversation(
            @PathVariable Long conversationId,
            Authentication authentication
    ) { 
        messageService.deleteConversation(authentication.getName(), conversationId);
    }

    @DeleteMapping("/conversations/{conversationId}/messages/{messageId}")
    public void deleteMessage(
            @PathVariable Long conversationId,
            @PathVariable Long messageId,
            Authentication authentication
    ) {
        messageService.deleteMessage(authentication.getName(), conversationId, messageId);
    }
}