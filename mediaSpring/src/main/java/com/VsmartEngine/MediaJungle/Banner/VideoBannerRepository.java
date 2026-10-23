package com.VsmartEngine.MediaJungle.Banner;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface VideoBannerRepository extends JpaRepository<VideoBanner,Long>{

}
