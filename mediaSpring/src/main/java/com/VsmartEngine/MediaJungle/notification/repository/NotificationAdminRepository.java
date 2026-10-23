package com.VsmartEngine.MediaJungle.notification.repository;

import java.time.LocalDate;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.VsmartEngine.MediaJungle.notification.NotificationAdmin;

@Repository
public interface NotificationAdminRepository extends JpaRepository<NotificationAdmin,Long>{
	
	@Query("SELECT nu.notificationId FROM NotificationAdmin nu WHERE nu.adminid = :adminId AND nu.is_read = :isRead")
	  List<Long> findUnreadNotificationIdsByUserId(Long adminId, Boolean isRead);
	 
	 @Query("SELECT nu.notificationId FROM NotificationAdmin nu WHERE nu.adminid = :adminId AND (nu.datetonotify = :today OR nu.datetonotify IS NULL)")
	 List<Long> findNotificationIdsByadminId(Long adminId, LocalDate today);
	 
//	 @Query("SELECT nu FROM NotificationAdmin nu WHERE nu.adminid = :adminId AND nu.notificationId = :notificationId")
//	  NotificationAdmin findbyuserIdNotificationId(Long adminId, Long notificationId);
	 
	 @Query("SELECT nu FROM NotificationAdmin nu WHERE nu.adminid = :adminId AND nu.notificationId = :notificationId")
	 NotificationAdmin findbyuserIdNotificationId(@Param("adminId") Long adminId, @Param("notificationId") Long notificationId);

	 
	
	 @Query("SELECT COUNT(nu) FROM NotificationAdmin nu  WHERE( nu.adminid = :adminId AND nu.is_read = :isRead) AND (nu.datetonotify = :today OR nu.datetonotify IS NULL)")
	 Long CountUnreadNotificationOftheUser(Long adminId, Boolean isRead ,LocalDate today);

	 @Query("SELECT nu.id FROM NotificationAdmin nu WHERE nu.adminid = :adminId ")
	  List<Long> findprimaryIdsByadminId(Long adminId);
	 
	 @Modifying
	 @Query("UPDATE NotificationAdmin nu SET nu.is_read = TRUE WHERE nu.adminid = :adminId")
	 void markAllAsRead(@Param("adminId") Long adminId);

}
