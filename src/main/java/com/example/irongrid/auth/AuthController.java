package com.example.irongrid.auth;

import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.irongrid.auth.dto.AuthResponse;
import com.example.irongrid.auth.dto.LoginRequest;
import com.example.irongrid.security.JwtService;
import com.example.irongrid.user.UserRepository;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final UserRepository userRepo;
    private final PasswordEncoder encoder;
    private final JwtService jwtService;

    public AuthController(UserRepository userRepo, PasswordEncoder encoder, JwtService jwtService) {
        this.userRepo = userRepo;
        this.encoder = encoder;
        this.jwtService = jwtService;
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequest req) {
        var user = userRepo.findByEmail(req.email()).orElse(null);
        if (user == null || !encoder.matches(req.password(), user.getPasswordHash()))
            return ResponseEntity.status(401).body(Map.of("message", "Invalid credentials"));

        if (!user.getRole().equals(req.role()))
            return ResponseEntity.status(403).body(Map.of("message", "Role mismatch"));

        String token = jwtService.generateToken(user.getEmail(), user.getRole().name());
        return ResponseEntity.ok(new AuthResponse(token, user.getRole().name(), user.getEmail()));
    }
}
