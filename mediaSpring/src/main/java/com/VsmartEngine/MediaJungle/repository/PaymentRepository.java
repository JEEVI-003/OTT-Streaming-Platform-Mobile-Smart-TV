package com.VsmartEngine.MediaJungle.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.VsmartEngine.MediaJungle.model.PaymentUser;


@Repository
public interface PaymentRepository extends JpaRepository<PaymentUser,Long>{
	List<PaymentUser> findUserByUserId(Long userId);
	Optional<PaymentUser> findByOrderId(String orderId);
	Optional<PaymentUser> findByUserId(Long userId);
	Optional<PaymentUser> findByPaymentId(String paymentId);
	Optional<PaymentUser> findByStatus(String Status);

}
