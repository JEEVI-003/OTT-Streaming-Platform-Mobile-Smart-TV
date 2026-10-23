package com.VsmartEngine.MediaJungle.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.VsmartEngine.MediaJungle.model.CastandCrew;

@Repository
public interface CastandcrewRepository extends JpaRepository<CastandCrew,Long>{

	@Query("SELECT c.name FROM CastandCrew c WHERE c.id IN :castIds")
    List<String> findcastByIds(@Param("castIds") List<Long> castIds);
}
