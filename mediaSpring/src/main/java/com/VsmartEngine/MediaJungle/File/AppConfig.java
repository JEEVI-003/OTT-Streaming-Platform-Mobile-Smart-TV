package com.VsmartEngine.MediaJungle.File;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class AppConfig {

    @Bean
    public Root root() {
        return new Root();
    }
}