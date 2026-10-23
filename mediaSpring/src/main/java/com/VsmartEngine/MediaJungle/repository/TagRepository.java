package com.VsmartEngine.MediaJungle.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.VsmartEngine.MediaJungle.model.Tag;

@Repository
public interface TagRepository extends JpaRepository<Tag, Long>{
	
	@Query("SELECT c.tag FROM Tag c WHERE c.id IN :tagIds")
    List<String> findtagByIds(@Param("tagIds") List<Long> tagIds);

}
