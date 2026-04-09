package com.example.irongrid.me;

import com.example.irongrid.me.dto.AvatarUploadResponse;
import com.example.irongrid.me.dto.MeResponse;
import com.example.irongrid.me.dto.UpdateMeRequest;
import jakarta.validation.Valid;
import org.springframework.http.MediaType;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/me")
public class MeController {

    private final MeService meService;

    public MeController(MeService meService) {
        this.meService = meService;
    }

    @GetMapping
    public MeResponse me(Authentication auth) {
        return meService.me(auth.getName());
    }

    @PutMapping
    public MeResponse update(Authentication auth, @Valid @RequestBody UpdateMeRequest req) {
        return meService.update(auth.getName(), req);
    }

    @PostMapping(value = "/avatar", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public AvatarUploadResponse uploadAvatar(
            Authentication auth,
            @RequestParam(value = "avatar", required = false) MultipartFile avatar,
            @RequestParam(value = "file", required = false) MultipartFile file
    ) {
        MultipartFile uploadedFile = avatar != null && !avatar.isEmpty() ? avatar : file;
        return meService.uploadAvatar(auth.getName(), uploadedFile);
    }
}