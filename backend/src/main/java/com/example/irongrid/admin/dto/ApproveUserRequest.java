package com.example.irongrid.admin.dto;

import jakarta.validation.constraints.NotBlank;

public record ApproveUserRequest(

        @NotBlank(message = "Le rôle est obligatoire")
        String role

) {}
