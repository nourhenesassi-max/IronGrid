package com.example.irongrid.message;

import com.example.irongrid.user.User;
import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(
    name = "conversation_participants",
    uniqueConstraints = {
        @UniqueConstraint(columnNames = {"conversation_id", "user_id"})
    }
)
public class ConversationParticipant {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    @JoinColumn(name = "conversation_id", nullable = false)
    private ChatConversation conversation;

    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "last_read_at")
    private LocalDateTime lastReadAt;

    public ConversationParticipant() {
    }

    public ConversationParticipant(ChatConversation conversation, User user) {
        this.conversation = conversation;
        this.user = user;
    }

    public Long getId() {
        return id;
    }

    public ChatConversation getConversation() {
        return conversation;
    }

    public User getUser() {
        return user;
    }

    public LocalDateTime getLastReadAt() {
        return lastReadAt;
    }

    public void setConversation(ChatConversation conversation) {
        this.conversation = conversation;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public void setLastReadAt(LocalDateTime lastReadAt) {
        this.lastReadAt = lastReadAt;
    }
}