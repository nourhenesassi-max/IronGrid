package com.example.irongrid.expense.dto;

import jakarta.validation.constraints.NotBlank;

public record RejectRequest(
        @NotBlank(message = "La raison est obligatoire") String reason
) {}