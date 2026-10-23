package com.VsmartEngine.MediaJungle.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;

import com.VsmartEngine.MediaJungle.model.AudioTags;
import com.VsmartEngine.MediaJungle.model.Tag;

public interface AudioTagRepository extends JpaRepository<AudioTags, Long> {

	@Query("SELECT Tagid  FROM AudioTags a WHERE Audioid.id = :audioId")
	List<Tag> findByAudio_Id(@Param("audioId") long audioId);

	@Modifying
	@Transactional
	@Query("DELETE FROM AudioTags a WHERE Audioid.id = :audioId")
	void deletetagByAudioId(@Param("audioId") long audioId);

	@Modifying
	@Transactional
	@Query("DELETE FROM AudioTags a WHERE Tagid.id = :TagId AND Audioid.id = :audioId")
	void deletetagBytagId(@Param("TagId") long tagId,@Param("audioId") long audioId);
//	    Optional<AudioTags> findByaudioid(long audioId);
}
