package com.VsmartEngine.MediaJungle.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.VsmartEngine.MediaJungle.model.AddCertificate;

@Repository
public interface CertificateRepository extends JpaRepository<AddCertificate, Long>{

}
