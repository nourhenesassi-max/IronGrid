package com.example.irongrid.expense;

import com.example.irongrid.user.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ExpenseRepository extends JpaRepository<Expense, Long> {
    List<Expense> findByUserOrderByCreatedAtDesc(User user);
    List<Expense> findByStatusOrderByCreatedAtDesc(ExpenseStatus status);
}