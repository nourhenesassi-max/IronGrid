package com.example.irongrid.me.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record UpdateMeRequest(
        @NotBlank(message = "Le prénom est requis")
        @Size(max = 100)
        String firstName,

        @NotBlank(message = "Le nom est requis")
        @Size(max = 100)
        String lastName,

        @NotBlank(message = "L'email est requis")
        @Email(message = "Email invalide")
        @Size(max = 190)
        String email,

        @Size(max = 50)
        String phone,

        @Size(max = 255)
        String address,

        @Size(max = 100)
        String department
) {
}