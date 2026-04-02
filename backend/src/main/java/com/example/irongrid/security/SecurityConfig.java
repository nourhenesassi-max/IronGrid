package com.example.irongrid.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
public class SecurityConfig {

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http, JwtAuthFilter jwtAuthFilter) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .cors(Customizer.withDefaults())
            .sessionManagement(sm -> sm.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .headers(h -> h.frameOptions(f -> f.disable()))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
                .requestMatchers("/api/auth/**").permitAll()
                .requestMatchers("/api/test/**").permitAll()
                .requestMatchers("/error").permitAll()
                .requestMatchers("/h2-console/**").permitAll()
                .requestMatchers("/uploads/**").permitAll()

                // ADMIN
                .requestMatchers(HttpMethod.DELETE, "/api/admin/**").hasRole("ADMIN")
                .requestMatchers(HttpMethod.POST, "/api/admin/**").hasRole("ADMIN")
                .requestMatchers(HttpMethod.GET, "/api/admin/**").hasRole("ADMIN")
                .requestMatchers("/api/admin/**").hasRole("ADMIN")

                .requestMatchers("/files/**").authenticated()
                .requestMatchers(HttpMethod.GET, "/api/me").authenticated()
                .requestMatchers(HttpMethod.PUT, "/api/me").authenticated()
                .requestMatchers(HttpMethod.POST, "/api/me/avatar").authenticated()

                .requestMatchers("/api/time/**").hasRole("EMPLOYE")
                .requestMatchers("/api/leave/**").hasRole("EMPLOYE")
                .requestMatchers(HttpMethod.GET, "/api/leave/stats").hasRole("EMPLOYE")
                .requestMatchers("/api/expenses/**").hasRole("EMPLOYE")

                .requestMatchers("/api/manager/**").hasRole("MANAGER")

                .requestMatchers(HttpMethod.GET, "/api/notifications/**").authenticated()
                .requestMatchers(HttpMethod.PATCH, "/api/notifications/**").authenticated()
                .requestMatchers(HttpMethod.POST, "/api/notifications/send").hasAnyRole("MANAGER", "ADMIN")

                .requestMatchers(HttpMethod.GET, "/api/users/employees").hasRole("MANAGER")
                .requestMatchers(HttpMethod.DELETE, "/api/users/employees/*").hasRole("MANAGER")
                .requestMatchers(HttpMethod.DELETE, "/api/users/employees/*/team").hasRole("MANAGER")
                .requestMatchers(HttpMethod.GET, "/api/users/messageable").hasAnyRole("EMPLOYE", "ADMIN", "MANAGER")

                .requestMatchers("/api/messages/**").hasAnyRole("EMPLOYE", "RH", "ADMIN", "MANAGER")
                .requestMatchers(HttpMethod.GET, "/api/employee/projects/**").hasRole("EMPLOYE")

                .requestMatchers("/api/rh/**").hasRole("RH")
                .requestMatchers(HttpMethod.GET, "/api/machines/**").hasRole("EMPLOYE")
                .requestMatchers(HttpMethod.POST, "/api/machines/*/verify").hasRole("EMPLOYE")
                .requestMatchers(HttpMethod.PATCH, "/api/machines/*/status").hasAnyRole("ADMIN", "MANAGER")

                .anyRequest().authenticated()
            )
            .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}
