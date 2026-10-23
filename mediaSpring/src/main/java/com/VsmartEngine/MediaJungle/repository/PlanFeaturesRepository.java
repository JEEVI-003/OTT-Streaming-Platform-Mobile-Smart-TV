package com.VsmartEngine.MediaJungle.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.VsmartEngine.MediaJungle.model.PlanFeatures;

@Repository
public interface PlanFeaturesRepository extends JpaRepository<PlanFeatures, Long> {

}
