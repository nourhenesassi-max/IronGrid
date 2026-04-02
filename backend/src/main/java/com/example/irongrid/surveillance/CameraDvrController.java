package com.example.irongrid.surveillance;

import com.example.irongrid.surveillance.dto.CameraDvrRequest;
import com.example.irongrid.surveillance.dto.CameraDvrResponse;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/manager/surveillance/dvrs")
public class CameraDvrController {

    private final CameraDvrService service;

    public CameraDvrController(CameraDvrService service) {
        this.service = service;
    }

    @GetMapping
    public List<CameraDvrResponse> getAll() {
        return service.getAll();
    }

    @GetMapping("/{id}")
    public CameraDvrResponse getOne(@PathVariable Long id) {
        return service.getOne(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public CameraDvrResponse create(@RequestBody CameraDvrRequest request) {
        return service.create(request);
    }

    @PutMapping("/{id}")
    public CameraDvrResponse update(@PathVariable Long id, @RequestBody CameraDvrRequest request) {
        return service.update(id, request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) {
        service.delete(id);
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<Map<String, String>> handleBadRequest(IllegalArgumentException ex) {
        return ResponseEntity.badRequest().body(Map.of("message", ex.getMessage()));
    }

    @ExceptionHandler(EntityNotFoundException.class)
    public ResponseEntity<Map<String, String>> handleNotFound(EntityNotFoundException ex) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", ex.getMessage()));
    }
}