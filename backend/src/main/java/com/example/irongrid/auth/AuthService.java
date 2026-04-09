package com.example.irongrid.auth;

import com.example.irongrid.auth.dto.AuthResponse;
import com.example.irongrid.auth.dto.ForgotPasswordRequest;
import com.example.irongrid.auth.dto.LoginRequest;
import com.example.irongrid.auth.dto.MessageResponse;
import com.example.irongrid.auth.dto.ResetPasswordRequest;
import com.example.irongrid.auth.dto.SignupPendingResponse;
import com.example.irongrid.auth.dto.SignupRequest;
import com.example.irongrid.security.JwtService;
import com.example.irongrid.user.AccountStatus;
import com.example.irongrid.user.User;
import com.example.irongrid.user.UserRepository;
import com.example.irongrid.user.UserService;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.security.SecureRandom;
import java.time.Instant;
import java.util.List;

@Service
public class AuthService {

    private static final int CODE_EXPIRATION_MINUTES = 10;
    private static final int MAX_ATTEMPTS = 5;

    private final UserRepository userRepo;
    private final UserService userService;
    private final PasswordEncoder encoder;
    private final JwtService jwtService;
    private final VerificationCodeRepository codeRepo;
    private final MailService mailService;

    public AuthService(
            UserRepository userRepo,
            UserService userService,
            PasswordEncoder encoder,
            JwtService jwtService,
            VerificationCodeRepository codeRepo,
            MailService mailService
    ) {
        this.userRepo = userRepo;
        this.userService = userService;
        this.encoder = encoder;
        this.jwtService = jwtService;
        this.codeRepo = codeRepo;
        this.mailService = mailService;
    }

    public AuthResponse login(LoginRequest req) {
        String email = req.email().trim().toLowerCase();
        String password = req.password();

        User user = userRepo.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.UNAUTHORIZED,
                        "Adresse email introuvable"
                ));

        if (!encoder.matches(password, user.getPasswordHash())) {
            throw new ResponseStatusException(
                    HttpStatus.UNAUTHORIZED,
                    "Mot de passe incorrect"
            );
        }

        if (user.getStatus() == AccountStatus.PENDING) {
            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    "Votre compte est en attente de l'acceptation par l'administrateur"
            );
        }

        if (user.getStatus() == AccountStatus.REJECTED) {
            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    "Votre compte a été refusé par l'administrateur"
            );
        }

        if (user.getRole() == null || user.getRole().getName() == null || user.getRole().getName().isBlank()) {
            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    "Aucun rôle n'a encore été attribué à ce compte"
            );
        }

        String roleUpper = user.getRole().getName().trim().toUpperCase();
        String token = jwtService.generateToken(user.getId(), user.getEmail(), roleUpper);

        return new AuthResponse(token, roleUpper, user.getEmail());
    }

    public SignupPendingResponse signup(SignupRequest req) {
        String email = req.email().trim().toLowerCase();

        if (userRepo.findByEmail(email).isPresent()) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "Adresse déjà utilisée"
            );
        }

        User user = userService.createPendingUser(
                req.firstName().trim(),
                req.lastName().trim(),
                email,
                req.password()
        );

        mailService.sendSignupPendingMail(user.getEmail(), user.getDisplayName());

        return new SignupPendingResponse(
                "Votre demande d'inscription est en attente de l'acceptation par l'administrateur."
        );
    }

    public MessageResponse forgotPassword(ForgotPasswordRequest req) {
        String email = req.email().trim().toLowerCase();

        userRepo.findByEmail(email).ifPresent(user -> {
            if (user.getStatus() != AccountStatus.APPROVED) {
                return;
            }

            invalidateOldCodes(email);

            String rawCode = generate6DigitCode();

            VerificationCode verificationCode = new VerificationCode();
            verificationCode.setEmail(email);
            verificationCode.setCodeHash(encoder.encode(rawCode));
            verificationCode.setExpiresAt(Instant.now().plusSeconds(CODE_EXPIRATION_MINUTES * 60L));
            verificationCode.setUsed(false);
            verificationCode.setAttempts(0);

            codeRepo.save(verificationCode);

            // Envoi asynchrone pour ne pas bloquer la réponse HTTP
            mailService.sendResetCode(email, rawCode);
        });

        return new MessageResponse("Si cette adresse existe, le code de réinitialisation a été envoyé.");
    }

    public MessageResponse resetPassword(ResetPasswordRequest req) {
        String email = req.email().trim().toLowerCase();
        String code = req.code().trim();
        String newPassword = req.newPassword();

        VerificationCode verificationCode = codeRepo
                .findTopByEmailAndUsedFalseOrderByIdDesc(email)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.BAD_REQUEST,
                        "Code invalide ou expiré"
                ));

        if (verificationCode.getExpiresAt().isBefore(Instant.now())) {
            verificationCode.setUsed(true);
            codeRepo.save(verificationCode);
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Code expiré");
        }

        if (verificationCode.getAttempts() >= MAX_ATTEMPTS) {
            verificationCode.setUsed(true);
            codeRepo.save(verificationCode);
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Nombre maximum de tentatives dépassé");
        }

        if (!encoder.matches(code, verificationCode.getCodeHash())) {
            verificationCode.setAttempts(verificationCode.getAttempts() + 1);

            if (verificationCode.getAttempts() >= MAX_ATTEMPTS) {
                verificationCode.setUsed(true);
            }

            codeRepo.save(verificationCode);
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Code invalide");
        }

        User user = userRepo.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.BAD_REQUEST,
                        "Requête invalide"
                ));

        if (user.getStatus() != AccountStatus.APPROVED) {
            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    "Compte non autorisé"
            );
        }

        user.setPasswordHash(encoder.encode(newPassword));
        userRepo.save(user);

        verificationCode.setUsed(true);
        codeRepo.save(verificationCode);

        return new MessageResponse("Mot de passe modifié avec succès");
    }

    private void invalidateOldCodes(String email) {
        List<VerificationCode> activeCodes = codeRepo.findByEmailAndUsedFalse(email);
        for (VerificationCode code : activeCodes) {
            code.setUsed(true);
        }
        codeRepo.saveAll(activeCodes);
    }

    private String generate6DigitCode() {
        int number = new SecureRandom().nextInt(900000) + 100000;
        return String.valueOf(number);
    }
}
