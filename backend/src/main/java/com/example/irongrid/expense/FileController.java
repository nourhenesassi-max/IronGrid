package com.example.irongrid.expense;

import org.springframework.core.io.Resource;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/files")
public class FileController {

    private final ReceiptStorageService storage;

    public FileController(ReceiptStorageService storage) {
        this.storage = storage;
    }

    @GetMapping("/receipts/{filename}")
    public ResponseEntity<Resource> receipt(@PathVariable String filename) {
        Resource res = storage.loadAsResource(filename);
        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_OCTET_STREAM)
                .body(res);
    }
}