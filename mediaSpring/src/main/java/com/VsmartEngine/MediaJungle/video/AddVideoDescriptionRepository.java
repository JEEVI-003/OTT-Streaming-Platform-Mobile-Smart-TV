package com.VsmartEngine.MediaJungle.video;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface AddVideoDescriptionRepository extends JpaRepository<VideoDescription,Long> {
	
//	@Query("SELECT vd.id FROM VideoDescription vd WHERE :categoryId IN (vd.categorylist)")
//	List<Long> findVideoIdsByCategory(@Param("categoryId") Long categoryId);

	
	
	
//	@Query("SELECT vd.id FROM VideoDescription vd WHERE :categoryId MEMBER OF vd.categorylist")
//    List<Long> findVideoIdsByCategoryId(@Param("categoryId") Long categoryId);

//	@Query("SELECT vd.id FROM VideoDescription vd WHERE FIND_IN_SET(:categoryId, vd.categorylist) > 0")
//	List<Long> findVideoIdsByCategoryId(@Param("categoryId") Long categoryId);
	
//	@Query(value = "SELECT vd.id FROM VideoDescription vd WHERE FIND_IN_SET(:categoryId, vd.categorylist) > 0", nativeQuery = true)
//	List<Long> findVideoIdsByCategoryId(@Param("categoryId") Long categoryId);
	
	@Query(value = "SELECT vd.id FROM video_description vd WHERE position(:categoryId || ',' in vd.categorylist) > 0", nativeQuery = true)
	List<Long> findVideoIdsByCategoryId(@Param("categoryId") String categoryId);


//	@Query("SELECT vd.id FROM VideoDescription vd WHERE :categoryId MEMBER OF vd.categorylist")
//	List<Long> findVideoIdsByCategory(@Param("categoryId") Long categoryId);
	
//	@Query("SELECT vd.id, vi.videoThumbnail FROM VideoDescription vd JOIN VideoImage vi ON vd.id = vi.videoId WHERE :categoryId MEMBER OF vd.categorylist")
//	List<Object[]> findVideoIdsAndThumbnailsByCategory(@Param("categoryId") Long categoryId);

//	@Query("SELECT v.id FROM VideoDescription v WHERE :categoryId MEMBER OF v.categorylist")
//    List<Long> findAllVideoIdsByCategoryId(Long categoryId);
//	@Query("SELECT v.id FROM VideoDescription v WHERE :categoryId IN elements(v.categorylist)")
//	List<Long> findAllVideoIdsByCategoryId(Long categoryId);
//	
//	@Query("SELECT v.id FROM VideoDescription v JOIN v.categorylist c WHERE c = :categoryId")
//	List<Long> findAllVideoIdsByCategoryId(@Param("categoryId") Long categoryId);




}