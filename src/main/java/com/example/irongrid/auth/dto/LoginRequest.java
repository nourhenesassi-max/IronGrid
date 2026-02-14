package com.example.irongrid.auth.dto;

import com.example.irongrid.user.Role;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record LoginRequest(
        @Email @NotBlank String email,
        @NotBlank String password,
        @NotNull Role role
) {}
