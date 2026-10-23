package com.VsmartEngine.MediaJungle.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.VsmartEngine.MediaJungle.model.PaymentUser;

public interface PaymentHistoryRepository extends JpaRepository<PaymentUser, Long> {
    List<PaymentUser> findByUserId(Long userId);
}
