package com.example.irongrid.me;

import com.example.irongrid.me.dto.AvatarUploadResponse;
import com.example.irongrid.me.dto.MeResponse;
import com.example.irongrid.me.dto.UpdateMeRequest;
import com.example.irongrid.security.JwtService;
import com.example.irongrid.user.User;
import com.example.irongrid.user.UserRepository;
import com.example.irongrid.user.UserService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

@Service
public class MeService {

    private final UserService userService;
    private final UserRepository userRepository;
    private final JwtService jwtService;

    @Value("${app.upload.dir:uploads}")
    private String uploadDir;

    @Value("${app.base-url:http://127.0.0.1:8081}")
    private String baseUrl;

    public MeService(UserService userService, UserRepository userRepository, JwtService jwtService) {
        this.userService = userService;
        this.userRepository = userRepository;
        this.jwtService = jwtService;
    }

    @Transactional(readOnly = true)
    public MeResponse me(String email) {
        User user = userService.getByEmailOrThrow(email);
        return toResponse(user);
    }

    @Transactional
    public MeResponse update(String currentEmail, UpdateMeRequest req) {
        User user = userService.getByEmailOrThrow(currentEmail);

        String cleanEmail = req.email().trim().toLowerCase();

        Optional<User> existing = userRepository.findByEmail(cleanEmail);
        if (existing.isPresent() && !existing.get().getId().equals(user.getId())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Email déjà utilisé");
        }

        String firstName = req.firstName().trim();
        String lastName = req.lastName().trim();
        String fullName = (firstName + " " + lastName).trim();

        user.setFirstName(firstName);
        user.setLastName(lastName);
        user.setName(fullName);
        user.setEmail(cleanEmail);
        user.setPhone(normalize(req.phone()));
        user.setAddress(normalize(req.address()));
        user.setDepartment(normalize(req.department()));

        userRepository.save(user);

        String roleUpper = user.getRole() != null && user.getRole().getName() != null
                ? user.getRole().getName().trim().toUpperCase()
                : "";

        String refreshedToken = roleUpper.isBlank()
                ? null
                : jwtService.generateToken(user.getId(), user.getEmail(), roleUpper);

        return toResponse(user, refreshedToken);
    }

    @Transactional
    public AvatarUploadResponse uploadAvatar(String currentEmail, MultipartFile file) {
        User user = userService.getByEmailOrThrow(currentEmail);

        if (file == null || file.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Fichier vide");
        }

        String contentType = file.getContentType();
        String originalFilename = file.getOriginalFilename();
        String ext = getExtension(originalFilename);

        Set<String> allowedTypes = Set.of(
                "image/jpeg",
                "image/jpg",
                "image/png",
                "image/webp",
                "image/heic",
                "image/heif",
                "image/gif"
        );

        Set<String> allowedExtensions = Set.of(
                "jpg",
                "jpeg",
                "png",
                "webp",
                "heic",
                "heif",
                "gif"
        );

        boolean validMimeType = contentType != null && allowedTypes.contains(contentType.toLowerCase());
        boolean validExtension = StringUtils.hasText(ext) && allowedExtensions.contains(ext.toLowerCase());

        if (!validMimeType && !validExtension) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Format image non supporté");
        }

        try {
            Path avatarsDir = Path.of(uploadDir, "avatars");
            Files.createDirectories(avatarsDir);

            if (!StringUtils.hasText(ext)) {
                ext = switch (contentType != null ? contentType.toLowerCase() : "") {
                    case "image/png" -> "png";
                    case "image/webp" -> "webp";
                    case "image/heic" -> "heic";
                    case "image/heif" -> "heif";
                    case "image/gif" -> "gif";
                    case "image/jpg", "image/jpeg" -> "jpg";
                    default -> "jpg";
                };
            }

            String fileName = "user_" + user.getId() + "_" + UUID.randomUUID() + "." + ext;
            Path target = avatarsDir.resolve(fileName);

            Files.copy(file.getInputStream(), target, StandardCopyOption.REPLACE_EXISTING);

            String avatarUrl = baseUrl + "/uploads/avatars/" + fileName;
            user.setAvatarUrl(avatarUrl);
            userRepository.save(user);

            return new AvatarUploadResponse(avatarUrl);
        } catch (IOException e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Erreur lors de l'upload");
        }
    }

    private MeResponse toResponse(User user) {
        return toResponse(user, null);
    }

    private MeResponse toResponse(User user, String token) {
        return new MeResponse(
                user.getId(),
                user.getDisplayName(),
                user.getFirstName(),
                user.getLastName(),
                user.getEmail(),
                user.getPhone(),
                user.getAddress(),
                user.getDepartment(),
                user.getAvatarUrl(),
                user.getTeamLabel(),
                user.getProjectLabel(),
                user.getRole() != null ? user.getRole().getName() : null,
                token
        );
    }

    private String normalize(String value) {
        if (value == null) return null;
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private String getExtension(String fileName) {
        if (!StringUtils.hasText(fileName) || !fileName.contains(".")) {
            return "";
        }
        return fileName.substring(fileName.lastIndexOf('.') + 1).toLowerCase();
    }
}