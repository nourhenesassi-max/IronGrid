package com.example.irongrid.me;

import java.util.Map;

import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class MeController {
    @GetMapping("/api/me")
    public Map<String, Object> me(Authentication auth) {
        return Map.of(
                "email", auth.getName(),
                "authorities", auth.getAuthorities()
        );
    }
}
