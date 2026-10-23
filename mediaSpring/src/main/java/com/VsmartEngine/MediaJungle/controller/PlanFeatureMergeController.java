package com.VsmartEngine.MediaJungle.controller;

import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.VsmartEngine.MediaJungle.Container.VideoContainerController;
import com.VsmartEngine.MediaJungle.model.PlanFeatureMerge;
import com.VsmartEngine.MediaJungle.service.PlanFeatureMergeService;

@RestController
@RequestMapping("/api/v2")
@CrossOrigin(origins = "*")
public class PlanFeatureMergeController {

    @Autowired
    private PlanFeatureMergeService service;

    private static final Logger logger = LoggerFactory.getLogger(PlanFeatureMergeController.class);

    public ResponseEntity<List<PlanFeatureMerge>> updatePlanFeatureMerge(
            @RequestBody List<PlanFeatureMerge> planFeatureMerges) {
        try {
            List<PlanFeatureMerge> updatedRecords = service.updatePlanFeatureMerges(planFeatureMerges);
            return new ResponseEntity<>(updatedRecords, HttpStatus.OK);
        } catch (Exception e) {
            e.printStackTrace(); // For debugging, replace with proper logging
            logger.error("", e);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

   
    public ResponseEntity<List<PlanFeatureMerge>> patchPlanFeatureMerge(
            @RequestBody List<PlanFeatureMerge> planFeatureMerges) {
        try {
            if (!planFeatureMerges.isEmpty()) {
                Long planId = planFeatureMerges.get(0).getPlanId();

                // Delete existing records and insert new ones in a single transaction
                List<PlanFeatureMerge> updatedRecords = service.saveUpdatedPlanFeatures(planId, planFeatureMerges);

                return new ResponseEntity<>(updatedRecords, HttpStatus.OK);
            } else {
                return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
            }
        } catch (Exception e) {
            e.printStackTrace(); // Replace with proper logging
            logger.error("", e);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    public ResponseEntity<HttpStatus> deleteFeaturesByPlanId(
            @RequestParam Long planId) {
        try {
            service.deleteFeaturesByPlanId(planId);
            return new ResponseEntity<>(HttpStatus.NO_CONTENT);
        } catch (Exception e) {
            e.printStackTrace(); // For debugging, replace with proper logging
            logger.error("", e);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    public ResponseEntity<List<PlanFeatureMerge>> getFeaturesByPlanId(@RequestParam Long planId) {
        try {
            List<PlanFeatureMerge> features = service.getFeaturesByPlanId(planId);
            return new ResponseEntity<>(features, HttpStatus.OK);
        } catch (Exception e) {
            e.printStackTrace(); // For debugging, replace with proper logging
            logger.error("", e);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}
