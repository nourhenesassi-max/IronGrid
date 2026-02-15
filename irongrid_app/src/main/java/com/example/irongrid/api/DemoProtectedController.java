package com.example.irongrid.api;

import java.util.Map;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class DemoProtectedController {

    @GetMapping("/api/manager/dashboard")
    public Map<String, String> manager() { return Map.of("dashboard", "Manager dashboard data"); }

    @GetMapping("/api/employe/dashboard")
    public Map<String, String> employe() { return Map.of("dashboard", "Employe dashboard data"); }

    @GetMapping("/api/rh/dashboard")
    public Map<String, String> rh() { return Map.of("dashboard", "RH dashboard data"); }

    @GetMapping("/api/finance/dashboard")
    public Map<String, String> finance() { return Map.of("dashboard", "Finance dashboard data"); }

    @GetMapping("/api/it/dashboard")
    public Map<String, String> it() { return Map.of("dashboard", "IT dashboard data"); }
}
