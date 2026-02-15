package com.example.irongrid.user;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder; // pour signup / update password

    public UserService(UserRepository userRepository,
                       PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public User getByEmailOrThrow(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Email introuvable"));
    }

    public boolean existsByEmail(String email) {
        return userRepository.findByEmail(email).isPresent();
    }

    public User createUser(String name, String email, String rawPassword, String role) {
        if (existsByEmail(email)) {
            throw new RuntimeException("Email déjà utilisé");
        }

        User u = new User();
        u.setName(name);
        u.setEmail(email);
        u.setPassword(passwordEncoder.encode(rawPassword)); // bcrypt
        u.setRole(role.toUpperCase()); // MANAGER / RH / FINANCE / EMPLOYE
        return userRepository.save(u);
    }
}
