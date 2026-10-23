package com.VsmartEngine.MediaJungle.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import org.springframework.transaction.annotation.Transactional;


import com.VsmartEngine.MediaJungle.model.PlanFeatureMerge;
import com.VsmartEngine.MediaJungle.repository.PlanFeatureMergeRepository;

@Service
public class PlanFeatureMergeService {

    @Autowired
    private PlanFeatureMergeRepository repository;

    public void deleteFeaturesByPlanId(Long planId) {
        repository.deleteByPlanId(planId);
    }

    public List<PlanFeatureMerge> updatePlanFeatureMerges(List<PlanFeatureMerge> planFeatureMerges) {
        return repository.saveAll(planFeatureMerges);
    }


    @Transactional // Ensure the deletion and insertion are handled in a single transaction
    public List<PlanFeatureMerge> saveUpdatedPlanFeatures(Long planId, List<PlanFeatureMerge> planFeatureMerges) {
        // Step 1: Delete existing features for the given plan
        repository.deleteByPlanId(planId);

        // Step 2: Save the new feature records for the plan
        return repository.saveAll(planFeatureMerges);
    }

    public List<PlanFeatureMerge> getFeaturesByPlanId(Long planId) {
        return repository.findByPlanId(planId);
    }
}
