package com.example.irongrid.leave.dto;

import jakarta.validation.constraints.Size;

public record DecisionRequest(
        @Size(max = 500, message = "Le commentaire est trop long") String managerComment
) {}