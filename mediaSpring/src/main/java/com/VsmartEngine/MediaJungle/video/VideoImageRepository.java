package com.VsmartEngine.MediaJungle.video;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;



@Repository
public interface VideoImageRepository extends JpaRepository<VideoImage,Long>{
	
	@Query("SELECT u FROM VideoImage u WHERE u.videoId = ?1")
	Optional<VideoImage> findVideoById(long videoId);

	void deleteByVideoId(Long videoId);
	
	@Query("SELECT u.videoThumbnail FROM VideoImage u WHERE u.videoId = ?1")
	Optional<byte[]> findVideoThumbnailByVideoId(long videoId);
	
	List<VideoImage> findByVideoIdIn(List<Long> videoIds);


}
