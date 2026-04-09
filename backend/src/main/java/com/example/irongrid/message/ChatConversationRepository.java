package com.example.irongrid.message;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface ChatConversationRepository extends JpaRepository<ChatConversation, Long> {

    @Query("""
        select distinct c
        from ChatConversation c
        join c.participants p
        where p.user.id = :userId
        order by c.updatedAt desc
    """)
    List<ChatConversation> findAllByUserId(Long userId);

    @Query("""
        select c
        from ChatConversation c
        join c.participants p1
        join c.participants p2
        where c.groupConversation = false
          and p1.user.id = :user1Id
          and p2.user.id = :user2Id
          and (select count(cp) from ConversationParticipant cp where cp.conversation.id = c.id) = 2
    """)
    Optional<ChatConversation> findDirectConversation(Long user1Id, Long user2Id);
}