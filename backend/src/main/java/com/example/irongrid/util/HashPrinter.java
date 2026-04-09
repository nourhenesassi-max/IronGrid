package com.example.irongrid.util;

import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
public class HashPrinter implements CommandLineRunner {

    private final PasswordEncoder passwordEncoder;

    public HashPrinter(PasswordEncoder passwordEncoder) {
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public void run(String... args) {
        System.out.println("BCRYPT_HASH=" + passwordEncoder.encode("1234567"));
    }
}
