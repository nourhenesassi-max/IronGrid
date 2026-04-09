package com.example.irongrid.admin.dto;

public record AcceptedUserResponse(
        Long id,
        String firstName,
        String lastName,
        String email,
        String phone,
        String address,
        String teamLabel,
        String projectLabel,
        String status,
        String role
) {}