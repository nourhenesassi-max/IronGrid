package com.example.irongrid.admin.dto;

public record AdminDashboardStatsResponse(
        long pendingRequests,
        long approvedUsers,
        long rejectedUsers
) {}