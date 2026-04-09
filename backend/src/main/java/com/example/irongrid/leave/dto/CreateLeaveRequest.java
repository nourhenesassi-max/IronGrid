package com.example.irongrid.leave.dto;

import com.example.irongrid.leave.LeaveType;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.LocalDate;

public record CreateLeaveRequest(
        @NotNull(message = "Le type est obligatoire") LeaveType type,
        @NotNull(message = "La date de début est obligatoire") LocalDate startDate,
        @NotNull(message = "La date de fin est obligatoire") LocalDate endDate,
        @Size(max = 500, message = "Le motif est trop long") String reason
) {}