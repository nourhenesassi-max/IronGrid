package com.example.irongrid.admin.dto;

public record PendingUserDto(
        Long id,
        String firstName,
        String lastName,
        String email,
        String status
) {}