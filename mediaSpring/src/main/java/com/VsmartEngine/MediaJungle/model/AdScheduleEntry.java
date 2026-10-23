package com.VsmartEngine.MediaJungle.model;

public class AdScheduleEntry {
   private String time;
    private Long   adId;  
 
    public AdScheduleEntry() {}
 
    public AdScheduleEntry(String time, Long adId) {
        this.time  = time;
        this.adId  = adId;
    }
 
    public String getTime()          { return time; }
    public void   setTime(String t)  { this.time = t; }
 
    public Long   getAdId()          { return adId; }
    public void   setAdId(Long id)   { this.adId = id; }
}
