package com.example.irongrid.time.dto;

public record SessionStateResponse(
        Long sessionId,
        String project,
        String status,
        String startedAt,
        String endedAt
) {}