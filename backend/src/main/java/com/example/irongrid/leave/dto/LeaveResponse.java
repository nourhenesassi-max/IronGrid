package com.example.irongrid.leave.dto;

public record LeaveResponse(
        Long id,
        Long userId,
        String employeeEmail,
        String employeeName,
        String type,
        String startDate,
        String endDate,
        String reason,
        String status,
        String createdAt,
        String decidedAt,
        String decidedByEmail,
        String managerComment
) {}