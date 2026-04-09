package com.example.irongrid.expense;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.io.IOException;
import java.net.MalformedURLException;
import java.nio.file.*;
import java.util.UUID;

@Service
public class ReceiptStorageService {

    private final Path baseDir;

    public ReceiptStorageService(@Value("${app.uploads.receipts-dir:uploads/receipts}") String receiptsDir) {
        this.baseDir = Paths.get(receiptsDir).toAbsolutePath().normalize();
        try {
            Files.createDirectories(baseDir);
        } catch (IOException e) {
            throw new IllegalStateException("Cannot create receipts directory: " + baseDir, e);
        }
    }

    public StoredReceipt store(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Receipt image is required");
        }

        String original = StringUtils.cleanPath(file.getOriginalFilename() == null ? "receipt.jpg" : file.getOriginalFilename());
        String ext = "";
        int dot = original.lastIndexOf('.');
        if (dot >= 0 && dot < original.length() - 1) ext = original.substring(dot);

        String filename = UUID.randomUUID() + ext;

        try {
            Path target = baseDir.resolve(filename);
            Files.copy(file.getInputStream(), target, StandardCopyOption.REPLACE_EXISTING);
            return new StoredReceipt(filename, original, file.getContentType());
        } catch (IOException e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Failed to store receipt: " + e.getMessage());
        }
    }

    public Resource loadAsResource(String filename) {
        try {
            Path file = baseDir.resolve(filename).normalize();
            if (!file.startsWith(baseDir)) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid filename");
            }
            Resource resource = new UrlResource(file.toUri());
            if (!resource.exists()) {
                throw new ResponseStatusException(HttpStatus.NOT_FOUND, "File not found");
            }
            return resource;
        } catch (MalformedURLException e) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "File not found");
        }
    }

    public record StoredReceipt(String filename, String originalName, String mime) {}
}