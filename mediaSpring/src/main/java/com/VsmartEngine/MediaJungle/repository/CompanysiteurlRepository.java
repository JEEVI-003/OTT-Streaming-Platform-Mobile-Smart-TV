package com.VsmartEngine.MediaJungle.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.VsmartEngine.MediaJungle.model.Companysiteurl;

@Repository
public interface CompanysiteurlRepository extends JpaRepository<Companysiteurl, Long> {

}


