package com.example.irongrid.leave.dto;

public record LeaveStatsResponse(
        int annualDaysRemaining,
        int sickDaysRemaining,
        long pendingCount
) {}