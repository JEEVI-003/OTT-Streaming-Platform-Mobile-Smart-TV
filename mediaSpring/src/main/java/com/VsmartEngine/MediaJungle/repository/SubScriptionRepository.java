package com.VsmartEngine.MediaJungle.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.VsmartEngine.MediaJungle.model.SubScription;

@Repository
public interface SubScriptionRepository extends JpaRepository<SubScription,Long>{

	Optional<SubScription> findByOrderId(String orderId);
}
