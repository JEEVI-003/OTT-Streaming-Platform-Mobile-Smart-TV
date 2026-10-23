package com.VsmartEngine.MediaJungle.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.VsmartEngine.MediaJungle.model.PlanDetails;

@Repository
public interface PlanDetailsRepository extends JpaRepository<PlanDetails,Long>{
	

}
