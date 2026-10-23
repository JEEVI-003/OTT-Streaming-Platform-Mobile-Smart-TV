package com.VsmartEngine.MediaJungle;

import org.springdoc.core.models.GroupedOpenApi;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

	@Bean
	public GroupedOpenApi publicApi() {
		return GroupedOpenApi.builder().group("public").pathsToMatch("/api/v2/**") // Match all API paths
				.pathsToExclude("/api/v2/affliation") // Exclude specific path
				.build();
	}
}
