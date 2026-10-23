
package com.VsmartEngine.MediaJungle;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.Properties;

import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;
import org.springframework.jdbc.datasource.DriverManagerDataSource;

//@Configuration
public class DataSourceConfig {
//    @Value("${upload.sqlport.directory}")
//    private String configFilePath;
//
//    @Value("${spring.datasource.url}")
//    private String dataSourceUrl;
//
//     @Bean
//     public DataSource dataSource(Environment environment) throws IOException {
//         Properties properties = new Properties();
//         try (FileInputStream inputStream = new FileInputStream(configFilePath)) {
//             properties.load(inputStream);
//         }
//
//         String port = properties.getProperty("sql.server.port");
//
//         // Build the JDBC URL with the port from the external file
//         String jdbcUrl = dataSourceUrl.replace("localhost", "localhost:" + port);
//
//         // Set up the DataSource with the dynamically constructed JDBC URL
//         DriverManagerDataSource dataSource = new DriverManagerDataSource();
//         dataSource.setDriverClassName("org.postgresql.Driver");
//         dataSource.setUrl(jdbcUrl);
//         dataSource.setUsername(environment.getProperty("spring.datasource.username"));
//         dataSource.setPassword(environment.getProperty("spring.datasource.password"));
//
//         return dataSource;
//     }

}