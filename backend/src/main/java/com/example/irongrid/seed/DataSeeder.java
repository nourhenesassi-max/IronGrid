package com.example.irongrid.seed;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

import com.example.irongrid.user.Role;
import com.example.irongrid.user.User;
import com.example.irongrid.user.UserRepository;

@Configuration
public class DataSeeder {

    @Bean
    CommandLineRunner seed(UserRepository repo, PasswordEncoder encoder) {
        return args -> {
            createIfMissing(repo, encoder, "manager@demo.com", "Password123!", Role.MANAGER);
            createIfMissing(repo, encoder, "employe@demo.com", "Password123!", Role.EMPLOYE);
            createIfMissing(repo, encoder, "rh@demo.com", "Password123!", Role.RH);
            createIfMissing(repo, encoder, "finance@demo.com", "Password123!", Role.FINANCE);
            createIfMissing(repo, encoder, "it@demo.com", "Password123!", Role.IT);
        };
    }

    private void createIfMissing(UserRepository repo, PasswordEncoder encoder, String email, String pwd, Role role) {
        if (repo.findByEmail(email).isPresent()) return;
        repo.save(new User(email, encoder.encode(pwd), role));
    }
}
