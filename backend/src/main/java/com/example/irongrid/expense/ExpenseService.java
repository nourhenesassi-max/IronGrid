package com.example.irongrid.expense;

import com.example.irongrid.expense.dto.ExpenseResponse;
import com.example.irongrid.expense.dto.RejectRequest;
import com.example.irongrid.user.User;
import com.example.irongrid.user.UserService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Service
public class ExpenseService {

    private final ExpenseRepository repo;
    private final UserService userService;
    private final Path uploadDir;

    public ExpenseService(
            ExpenseRepository repo,
            UserService userService,
            @Value("${app.upload.expenses-dir:uploads/expenses}") String uploadDir
    ) {
        this.repo = repo;
        this.userService = userService;
        this.uploadDir = Paths.get(uploadDir).toAbsolutePath().normalize();
    }

    private User currentUser(String email) {
        return userService.getByEmailOrThrow(email);
    }

    private ExpenseResponse toResponse(Expense e) {
        String receiptUrl = (e.getReceiptPath() == null || e.getReceiptPath().isBlank())
                ? null
                : "/api/expenses/" + e.getId() + "/receipt";

        return new ExpenseResponse(
                e.getId(),
                e.getCategory(),
                e.getAmount(),
                e.getCurrency(),
                e.getExpenseDate(),
                e.getNote() != null ? e.getNote() : "",
                e.getStatus().name(),
                receiptUrl,
                e.getReviewReason(),
                e.getUser() != null ? e.getUser().getName() : null,
                e.getUser() != null ? e.getUser().getEmail() : null,
                e.getCreatedAt()
        );
    }

    private String saveReceipt(Long expenseId, MultipartFile file) {
        try {
            Files.createDirectories(uploadDir);

            String original = file.getOriginalFilename() != null
                    ? file.getOriginalFilename()
                    : "receipt.jpg";

            String ext = original.contains(".")
                    ? original.substring(original.lastIndexOf('.'))
                    : ".jpg";

            String filename = "expense_" + expenseId + "_" + System.currentTimeMillis() + ext;
            Path target = uploadDir.resolve(filename);

            Files.copy(file.getInputStream(), target, StandardCopyOption.REPLACE_EXISTING);
            return target.toString();
        } catch (IOException ex) {
            throw new ResponseStatusException(
                    HttpStatus.INTERNAL_SERVER_ERROR,
                    "Failed to save receipt"
            );
        }
    }

    @Transactional
    public ExpenseResponse create(
            String email,
            String category,
            String amount,
            String currency,
            String expenseDate,
            String note,
            MultipartFile receipt
    ) {
        User u = currentUser(email);

        if (receipt == null || receipt.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Receipt file is required");
        }

        Expense e = new Expense();
        e.setUser(u);
        e.setCategory(category.trim());
        e.setAmount(new BigDecimal(amount));
        e.setCurrency(currency == null || currency.isBlank() ? "TND" : currency.trim());
        e.setExpenseDate(LocalDate.parse(expenseDate));
        e.setNote(note == null ? "" : note.trim());
        e.setStatus(ExpenseStatus.PENDING);

        repo.saveAndFlush(e);

        String path = saveReceipt(e.getId(), receipt);
        e.setReceiptPath(path);
        repo.save(e);

        return toResponse(e);
    }

    @Transactional(readOnly = true)
    public List<ExpenseResponse> myExpenses(String email) {
        User u = currentUser(email);
        return repo.findByUserOrderByCreatedAtDesc(u)
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<ExpenseResponse> listByStatus(ExpenseStatus status) {
        return repo.findByStatusOrderByCreatedAtDesc(status)
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional
    public ExpenseResponse approve(Long id) {
        Expense e = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Expense not found"));

        e.setStatus(ExpenseStatus.APPROVED);
        e.setReviewReason(null);
        e.setReviewedAt(LocalDateTime.now());
        repo.save(e);

        return toResponse(e);
    }

    @Transactional
    public ExpenseResponse reject(Long id, RejectRequest req) {
        Expense e = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Expense not found"));

        e.setStatus(ExpenseStatus.REJECTED);
        e.setReviewReason(req.reason());
        e.setReviewedAt(LocalDateTime.now());
        repo.save(e);

        return toResponse(e);
    }

    public Path getReceiptPathOrThrow(Long id) {
        Expense e = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Expense not found"));

        if (e.getReceiptPath() == null || e.getReceiptPath().isBlank()) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Receipt not found");
        }

        Path p = Paths.get(e.getReceiptPath());
        if (!Files.exists(p)) {
          throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Receipt file missing");
        }

        return p;
    }
}