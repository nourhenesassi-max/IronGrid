package com.example.irongrid.me.dto;

public record MeResponse(
        Long id,
        String name,
        String firstName,
        String lastName,
        String email,
        String phone,
        String address,
        String department,
        String avatarUrl,
        String teamLabel,
        String projectLabel,
        String role,
        String token
) {
}