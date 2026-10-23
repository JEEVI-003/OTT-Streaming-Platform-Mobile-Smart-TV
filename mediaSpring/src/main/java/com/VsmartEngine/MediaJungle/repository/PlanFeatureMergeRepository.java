package com.VsmartEngine.MediaJungle.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.VsmartEngine.MediaJungle.model.PlanFeatureMerge;

import jakarta.transaction.Transactional;

public interface PlanFeatureMergeRepository extends JpaRepository<PlanFeatureMerge, Long> {
	   @Modifying
	    @Transactional
	    @Query("DELETE FROM PlanFeatureMerge pfm WHERE pfm.planId = :planId")
	   void deleteByPlanId(Long planId);
	    List<PlanFeatureMerge> findByPlanId(Long planId);
	   
	   Optional<PlanFeatureMerge> findByPlanIdAndFeatureId(Long planId, Long featureId);

}
