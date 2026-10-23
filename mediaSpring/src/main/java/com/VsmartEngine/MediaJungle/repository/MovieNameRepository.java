package com.VsmartEngine.MediaJungle.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.VsmartEngine.MediaJungle.model.MovieName;

@Repository
public interface MovieNameRepository extends JpaRepository<MovieName, Long>{

		
		
		@Query("SELECT id  FROM MovieName a WHERE Movie_name = :name")
		Long findIDBy_Moviename(@Param("name") String name);
		
		

	}

