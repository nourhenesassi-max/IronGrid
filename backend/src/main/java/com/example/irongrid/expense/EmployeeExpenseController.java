package com.example.irongrid.expense;

import com.example.irongrid.expense.dto.ExpenseResponse;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.*;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;

@RestController
@RequestMapping("/api/expenses")
public class EmployeeExpenseController {

    private final ExpenseService service;

    public EmployeeExpenseController(ExpenseService service) {
        this.service = service;
    }

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ExpenseResponse create(
            Authentication auth,
            @RequestParam String category,
            @RequestParam String amount,
            @RequestParam(defaultValue = "TND") String currency,
            @RequestParam String expenseDate,
            @RequestParam(required = false, defaultValue = "") String note,
            @RequestParam("receipt") MultipartFile receipt
    ) {
        return service.create(auth.getName(), category, amount, currency, expenseDate, note, receipt);
    }

    @GetMapping("/me")
    public List<ExpenseResponse> myExpenses(Authentication auth) {
        return service.myExpenses(auth.getName());
    }

    @GetMapping("/{id}/receipt")
    public ResponseEntity<Resource> receipt(@PathVariable Long id) throws Exception {
        Path path = service.getReceiptPathOrThrow(id);
        Resource res = new FileSystemResource(path);

        String mime = Files.probeContentType(path);
        MediaType mediaType = mime != null
                ? MediaType.parseMediaType(mime)
                : MediaType.APPLICATION_OCTET_STREAM;

        return ResponseEntity.ok()
                .contentType(mediaType)
                .cacheControl(CacheControl.noCache())
                .body(res);
    }
}