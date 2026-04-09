
package com.example.irongrid.notification;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface NotificationRepository extends JpaRepository<Notification, Long> {
    List<Notification> findByReceiver_IdOrderByCreatedAtDesc(Long receiverId);
    Optional<Notification> findByIdAndReceiver_Id(Long id, Long receiverId);

    void deleteBySender_Id(Long senderId);
    void deleteByReceiver_Id(Long receiverId);
}
