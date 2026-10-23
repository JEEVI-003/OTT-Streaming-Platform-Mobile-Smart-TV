package com.VsmartEngine.MediaJungle.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.VsmartEngine.MediaJungle.model.AddLanguage;

@Repository
public interface AddLanguageRepository extends JpaRepository<AddLanguage, Long>{

}
