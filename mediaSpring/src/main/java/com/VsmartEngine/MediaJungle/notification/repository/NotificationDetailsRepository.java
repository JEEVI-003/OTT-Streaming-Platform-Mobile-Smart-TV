package com.VsmartEngine.MediaJungle.notification.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.VsmartEngine.MediaJungle.notification.NotificationDetails;

@Repository
public interface NotificationDetailsRepository extends JpaRepository<NotificationDetails,Long>{

}
