package com.example.irongrid.message;

import com.example.irongrid.message.dto.ConversationDto;
import com.example.irongrid.message.dto.MessageDto;
import com.example.irongrid.user.User;
import com.example.irongrid.user.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Comparator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

@Service
@Transactional
public class MessageService {

    private final ChatConversationRepository conversationRepository;
    private final ChatMessageRepository messageRepository;
    private final ConversationParticipantRepository participantRepository;
    private final UserRepository userRepository;
    private final String baseUrl;

    private final DateTimeFormatter formatter =
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    public MessageService(
            ChatConversationRepository conversationRepository,
            ChatMessageRepository messageRepository,
            ConversationParticipantRepository participantRepository,
            UserRepository userRepository,
            @Value("${app.base-url:http://127.0.0.1:8080}") String baseUrl
    ) {
        this.conversationRepository = conversationRepository;
        this.messageRepository = messageRepository;
        this.participantRepository = participantRepository;
        this.userRepository = userRepository;
        this.baseUrl = trimTrailingSlash(baseUrl);
    }

    public List<ConversationDto> getMyConversations(String email) {
        User me = getUserByEmail(email);

        return conversationRepository.findAllByUserId(me.getId())
                .stream()
                .sorted(Comparator.comparing(ChatConversation::getUpdatedAt).reversed())
                .map(c -> toConversationDto(c, me))
                .toList();
    }

    public ConversationDto getConversation(String email, Long conversationId) {
        User me = getUserByEmail(email);

        ChatConversation conversation = conversationRepository.findById(conversationId)
                .orElseThrow(() -> new EntityNotFoundException("Conversation introuvable"));

        ensureParticipant(me.getId(), conversationId);

        ConversationParticipant participant = participantRepository
                .findByConversationIdAndUserId(conversationId, me.getId())
                .orElseThrow(() -> new EntityNotFoundException("Participant introuvable"));

        participant.setLastReadAt(LocalDateTime.now());
        participantRepository.save(participant);

        return toConversationDto(conversation, me);
    }

    public ConversationDto startConversation(String email, Long receiverId) {
        User me = getUserByEmail(email);

        User receiver = userRepository.findById(receiverId)
                .orElseThrow(() -> new EntityNotFoundException("Destinataire introuvable"));

        if (me.getId().equals(receiver.getId())) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Impossible de discuter avec vous-même"
            );
        }

        return conversationRepository.findDirectConversation(me.getId(), receiver.getId())
                .map(c -> toConversationDto(c, me))
                .orElseGet(() -> {
                    ChatConversation conversation = new ChatConversation();
                    conversation.setGroupConversation(false);
                    conversation.setGroupName(null);

                    ChatConversation saved = conversationRepository.save(conversation);

                    ConversationParticipant p1 = new ConversationParticipant(saved, me);
                    ConversationParticipant p2 = new ConversationParticipant(saved, receiver);

                    participantRepository.save(p1);
                    participantRepository.save(p2);

                    saved.getParticipants().add(p1);
                    saved.getParticipants().add(p2);
                    saved.touch();

                    return toConversationDto(saved, me);
                });
    }

    public ConversationDto createGroupConversation(String email, String groupName, List<Long> memberIds) {
        User me = getUserByEmail(email);

        String cleanGroupName = groupName == null ? "" : groupName.trim();
        if (cleanGroupName.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Nom du groupe requis");
        }

        if (memberIds == null || memberIds.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Le groupe doit contenir des membres");
        }

        Set<Long> uniqueIds = new LinkedHashSet<>(memberIds);
        uniqueIds.remove(me.getId());

        if (uniqueIds.isEmpty()) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Le groupe doit contenir au moins un autre utilisateur"
            );
        }

        ChatConversation conversation = new ChatConversation();
        conversation.setGroupConversation(true);
        conversation.setGroupName(cleanGroupName);

        ChatConversation saved = conversationRepository.save(conversation);

        ConversationParticipant meParticipant = new ConversationParticipant(saved, me);
        participantRepository.save(meParticipant);
        saved.getParticipants().add(meParticipant);

        for (Long id : uniqueIds) {
            User user = userRepository.findById(id)
                    .orElseThrow(() -> new EntityNotFoundException("Utilisateur introuvable: " + id));

            ConversationParticipant participant = new ConversationParticipant(saved, user);
            participantRepository.save(participant);
            saved.getParticipants().add(participant);
        }

        saved.touch();

        return toConversationDto(saved, me);
    }

    public MessageDto sendMessage(String email, Long conversationId, String content) {
        User me = getUserByEmail(email);

        ChatConversation conversation = conversationRepository.findById(conversationId)
                .orElseThrow(() -> new EntityNotFoundException("Conversation introuvable"));

        ensureParticipant(me.getId(), conversationId);

        String cleanContent = content == null ? "" : content.trim();
        if (cleanContent.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Le message ne peut pas être vide");
        }

        ChatMessage message = new ChatMessage(conversation, me, cleanContent);
        ChatMessage savedMessage = messageRepository.save(message);

        conversation.getMessages().add(savedMessage);
        conversation.touch();

        return toMessageDto(savedMessage, me);
    }

    public void deleteConversation(String email, Long conversationId) {
        User me = getUserByEmail(email);

        ChatConversation conversation = conversationRepository.findById(conversationId)
                .orElseThrow(() -> new EntityNotFoundException("Conversation introuvable"));

        ensureParticipant(me.getId(), conversationId);

        conversationRepository.delete(conversation);
    }

    public void deleteMessage(String email, Long conversationId, Long messageId) {
        User me = getUserByEmail(email);

        ChatMessage message = messageRepository.findById(messageId)
                .orElseThrow(() -> new EntityNotFoundException("Message introuvable"));

        if (!message.getConversation().getId().equals(conversationId)) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Message incorrect pour cette conversation"
            );
        }

        ensureParticipant(me.getId(), conversationId);

        if (!message.getSender().getId().equals(me.getId())) {
            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    "Vous ne pouvez supprimer que vos messages"
            );
        }

        if (message.isDeleted()) {
            return;
        }

        message.markDeleted();
        message.getConversation().touch();
    }

    private User getUserByEmail(String email) {
        return userRepository.findByEmail(email == null ? "" : email.trim().toLowerCase())
                .orElseThrow(() -> new EntityNotFoundException("Utilisateur introuvable"));
    }

    private void ensureParticipant(Long userId, Long conversationId) {
        boolean exists = participantRepository.existsByConversationIdAndUserId(conversationId, userId);
        if (!exists) {
            throw new AccessDeniedException("Accès refusé à cette conversation");
        }
    }

    private ConversationDto toConversationDto(ChatConversation conversation, User me) {
        List<MessageDto> messages = conversation.getMessages()
                .stream()
                .sorted(Comparator.comparing(ChatMessage::getSentAt))
                .map(m -> toMessageDto(m, me))
                .toList();

        MessageDto lastMessage = messages.isEmpty() ? null : messages.get(messages.size() - 1);

        ConversationParticipant meParticipant = conversation.getParticipants()
                .stream()
                .filter(p -> p.getUser() != null && p.getUser().getId().equals(me.getId()))
                .findFirst()
                .orElse(null);

        LocalDateTime lastReadAt = meParticipant != null ? meParticipant.getLastReadAt() : null;

        int unreadCount = (int) conversation.getMessages()
                .stream()
                .filter(m -> m.getSender() != null && !m.getSender().getId().equals(me.getId()))
                .filter(m -> !m.isDeleted())
                .filter(m -> lastReadAt == null || m.getSentAt().isAfter(lastReadAt))
                .count();

        if (conversation.isGroupConversation()) {
            return new ConversationDto(
                    conversation.getId(),
                    null,
                    conversation.getGroupName(),
                    "Groupe",
                    null,
                    lastMessage,
                    messages,
                    true,
                    conversation.getGroupName(),
                    conversation.getParticipants().size(),
                    unreadCount
            );
        }

        User other = conversation.getParticipants()
                .stream()
                .map(ConversationParticipant::getUser)
                .filter(u -> !u.getId().equals(me.getId()))
                .findFirst()
                .orElse(me);

        return new ConversationDto(
                conversation.getId(),
                other.getId(),
                other.getDisplayName(),
                displayRole(other),
                resolveAvatarUrl(other),
                lastMessage,
                messages,
                false,
                null,
                2,
                unreadCount
        );
    }

    private MessageDto toMessageDto(ChatMessage message, User me) {
        User sender = message.getSender();

        return new MessageDto(
                message.getId(),
                sender.getId(),
                sender.getDisplayName(),
                displayRole(sender),
                resolveAvatarUrl(sender),
                message.getContent(),
                message.getSentAt().format(formatter),
                sender.getId().equals(me.getId()),
                message.isDeleted()
        );
    }

    private String resolveAvatarUrl(User user) {
        if (user == null) {
            return null;
        }

        String directAvatar = cleanAvatar(user.getAvatarUrl());
        if (directAvatar != null) {
            return buildFullUrl(directAvatar);
        }

        if (user.getId() == null) {
            return null;
        }

        return userRepository.findById(user.getId())
                .map(User::getAvatarUrl)
                .map(this::cleanAvatar)
                .map(this::buildFullUrl)
                .orElse(null);
    }

    private String cleanAvatar(String avatarUrl) {
        if (avatarUrl == null) {
            return null;
        }

        String value = avatarUrl.trim();
        if (value.isEmpty() || value.equalsIgnoreCase("null")) {
            return null;
        }

        return value;
    }

    private String buildFullUrl(String avatarUrl) {
        if (avatarUrl == null) {
            return null;
        }

        String value = avatarUrl.trim();
        if (value.isEmpty()) {
            return null;
        }

        if (value.startsWith("http://") || value.startsWith("https://")) {
            return value;
        }

        if (value.startsWith("/")) {
            return baseUrl + value;
        }

        return baseUrl + "/" + value;
    }

    private String trimTrailingSlash(String value) {
        if (value == null || value.isBlank()) {
            return "http://127.0.0.1:8080";
        }

        String trimmed = value.trim();
        while (trimmed.endsWith("/")) {
            trimmed = trimmed.substring(0, trimmed.length() - 1);
        }

        return trimmed.isEmpty() ? "http://127.0.0.1:8080" : trimmed;
    }

    private String displayRole(User user) {
        String role = user.getRole() != null ? user.getRole().getName() : "";
        if (role == null) return "";

        return switch (role.toLowerCase()) {
            case "employe" -> "Employé";
            case "rh" -> "RH";
            case "manager" -> "Manager";
            case "finance" -> "Finance";
            case "it" -> "IT";
            case "admin" -> "Admin";
            default -> role;
        };
    }
}
