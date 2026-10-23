package com.VsmartEngine.MediaJungle.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.VsmartEngine.MediaJungle.model.MailSetting;

@Repository
public interface MailsettingRepository extends JpaRepository<MailSetting,Long>{

	Optional<MailSetting> findFirstByOrderByIdAsc();
	
}
