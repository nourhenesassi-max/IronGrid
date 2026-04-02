package com.example.irongrid.time.dto;

public record TimeSummaryResponse(
        long minutesToday,
        long minutesThisWeek
) {}