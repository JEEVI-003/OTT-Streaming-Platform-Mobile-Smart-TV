package com.VsmartEngine.MediaJungle.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.VsmartEngine.MediaJungle.model.Contactsettings;

@Repository
public interface ContactsettingsRepository extends JpaRepository<Contactsettings, Long> {

}
