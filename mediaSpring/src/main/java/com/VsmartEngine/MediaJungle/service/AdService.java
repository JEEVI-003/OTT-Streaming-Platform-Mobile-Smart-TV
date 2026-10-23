package com.VsmartEngine.MediaJungle.service;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.VsmartEngine.MediaJungle.model.AddAd;
import com.VsmartEngine.MediaJungle.repository.AddAdRepository;

@Service
public class AdService {
    @Autowired
    private AddAdRepository adRepository;

    public AddAd saveAd(AddAd ad) {
        return adRepository.save(ad);
    }

    public Optional<AddAd> getAdById(Long id) {
        return adRepository.findById(id);
    }

    public List<AddAd> getAllAds() {
        return adRepository.findAll();
    }

    public AddAd updateAd(Long id, AddAd updatedAd) {
    	System.out.print(updatedAd);
        return adRepository.findById(id)
                .map(ad -> {
                    ad.setAdName(updatedAd.getAdName());
                    ad.setCertificateNumber(updatedAd.getCertificateNumber());
                    ad.setCertificateName(updatedAd.getCertificateName());
                    ad.setViews(updatedAd.getViews());
                    ad.setRollType(updatedAd.getRollType());
                    ad.setVideoFilePath(updatedAd.getVideoFilePath());
                    return adRepository.save(ad);
                })
                .orElseThrow(() -> new RuntimeException("Ad not found with id " + id));
    }
    
    public void deleteAdById(Long id) {
        if (adRepository.existsById(id)) {
            adRepository.deleteById(id);
        } else {
            throw new RuntimeException("Ad with ID " + id + " not found");
        }
    }
}
