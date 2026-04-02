package com.example.irongrid.expense.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

public record ExpenseResponse(
        Long id,
        String category,
        BigDecimal amount,
        String currency,
        LocalDate expenseDate,
        String note,
        String status,
        String receiptUrl,
        String reviewReason,
        String employeeName,
        String employeeEmail,
        LocalDateTime createdAt
) {}