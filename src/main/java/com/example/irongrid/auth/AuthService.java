package com.example.irongrid.auth;

import com.example.irongrid.auth.dto.AuthResponse;
import com.example.irongrid.auth.dto.LoginRequest;
import com.example.irongrid.security.JwtService;
import com.example.irongrid.user.User;
import com.example.irongrid.user.UserService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

    private final UserService userService;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    public AuthService(UserService userService,
                       PasswordEncoder passwordEncoder,
                       JwtService jwtService) {
        this.userService = userService;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
    }

    public AuthResponse login(LoginRequest req) {
        // 1) user from DB by email
        User user = userService.getByEmailOrThrow(req.getEmail());

        // 2) password check (bcrypt)
        if (!passwordEncoder.matches(req.getPassword(), user.getPassword())) {
            throw new RuntimeException("Mot de passe incorrect");
        }

        // 3) optional: verify role selected from Flutter
        if (req.getRole() != null && !req.getRole().isBlank()) {
            if (!user.getRole().equalsIgnoreCase(req.getRole())) {
                throw new RuntimeException("Rôle incorrect");
            }
        }

        // 4) JWT should contain ROLE_...
        String authority = "ROLE_" + user.getRole().toUpperCase();
        String token = jwtService.generateToken(user.getEmail(), authority);

        return new AuthResponse(token, user.getRole());
    }
}
