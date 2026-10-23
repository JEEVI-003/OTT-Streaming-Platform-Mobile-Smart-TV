package com.VsmartEngine.MediaJungle.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;

import com.VsmartEngine.MediaJungle.model.AddNewCategories;
import com.VsmartEngine.MediaJungle.model.AudioCategories;
import com.VsmartEngine.MediaJungle.model.Audiodescription;

public interface AudioCategoriesRepository extends JpaRepository<AudioCategories, Long> {

	@Query("SELECT Categories_id  FROM AudioCategories a WHERE audio_id.id = :audio_id")
	List<AddNewCategories> findByCategorie_Id(@Param("audio_id") long audio_id);
	
	
	@Query("SELECT audio_id  FROM AudioCategories a WHERE Categories_id.id = :categorie_id")
	List<Audiodescription> findaudiobyCategorie_Id(@Param("categorie_id") long categorie_id);

	@Modifying
	@Transactional
	@Query("DELETE FROM AudioCategories a WHERE audio_id.id = :audio_id")
	void deletecategoriesByAudioId(@Param("audio_id") long audio_id);
	
	@Modifying
	@Transactional
	@Query("DELETE FROM AudioCategories a WHERE Categories_id.id = :categoryId AND audio_id.id = :audioId")
	void deletetagBycategotiesId(@Param("categoryId") long categoryId,@Param("audioId") long audioId);
//	    Optional<AudioTags> findByaudioid(long audioId);

}
