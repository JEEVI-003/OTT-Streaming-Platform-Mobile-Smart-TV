package com.VsmartEngine.MediaJungle.Banner;

import java.util.List;

public class VideoBannerRequest {

	   private int noOfSlides;
	    private List<Long> videoIds;
		public int getNoOfSlides() {
			return noOfSlides;
		}
		public void setNoOfSlides(int noOfSlides) {
			this.noOfSlides = noOfSlides;
		}
		public List<Long> getVideoIds() {
			return videoIds;
		}
		public void setVideoIds(List<Long> videoIds) {
			this.videoIds = videoIds;
		}
	    
	    
}
