package com.VsmartEngine.MediaJungle.Library;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface PlaylistRepository extends JpaRepository<Playlist, Long> {
	
//	@Query("SELECT p.title FROM Playlist p WHERE p.userId = :userId")
//	List<String> findTitlesByUserId(@Param("userId") Long userId);
	
//	@Query("SELECT p.id, p.title FROM Playlist p WHERE p.userId = :userId")
//    List<Object[]> findTitlesAndIdsByUserId(@Param("userId") Long userId);
	
	@Query("SELECT p FROM Playlist p WHERE p.userId = :userId")
    List<Playlist> findAllByUserId(@Param("userId") Long userId);

	@Query("SELECT p FROM Playlist p WHERE p.id = :id")
	List<Playlist> findByPlaylist(@Param("id") Long id);


}
