package com.VsmartEngine.MediaJungle.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.VsmartEngine.MediaJungle.model.AddNewCategories;

@Repository
public interface AddNewCategoriesRepository extends JpaRepository<AddNewCategories, Long>{
    
	 @Query("SELECT c.categories FROM AddNewCategories c WHERE c.id IN :categoryIds")
	    List<String> findcategoryByIds(@Param("categoryIds") List<Long> categoryIds);

}
