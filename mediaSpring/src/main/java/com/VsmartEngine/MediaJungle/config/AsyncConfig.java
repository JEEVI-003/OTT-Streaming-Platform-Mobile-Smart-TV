package com.VsmartEngine.MediaJungle.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

import java.util.concurrent.Executor;

/**
 * Dedicated thread-pool for background DASH encoding jobs.
 *
 * corePoolSize  = 2  → up to 2 videos encoded simultaneously.
 * maxPoolSize   = 4  → burst capacity if queue fills up.
 * queueCapacity = 10 → queue up to 10 pending jobs before rejecting.
 *
 * Tune these numbers based on your server's CPU core count.
 * Rule of thumb: corePoolSize = (CPU cores / 2).
 */
@Configuration
public class AsyncConfig {

    @Bean(name = "dashTaskExecutor")
    public Executor dashTaskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(2);
        executor.setMaxPoolSize(4);
        executor.setQueueCapacity(10);
        executor.setThreadNamePrefix("DashEncoder-");
        executor.initialize();
        return executor;
    }
}
