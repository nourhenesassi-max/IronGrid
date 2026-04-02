package com.example.irongrid.time.dto;

import jakarta.validation.constraints.NotBlank;

public record StartRequest(
        @NotBlank(message = "Le projet est obligatoire")
        String project
) {}