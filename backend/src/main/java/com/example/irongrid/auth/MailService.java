package com.example.irongrid.auth;

import com.example.irongrid.user.User;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

@Service
public class MailService {

    private final JavaMailSender mailSender;

    @Value("${app.mail.from}")
    private String fromEmail;

    @Value("${app.mail.fromName:IronGrid}")
    private String fromName;

    public MailService(JavaMailSender mailSender) {
        this.mailSender = mailSender;
    }

    @Async
    public void sendSignupPendingMail(String to, String displayName) {
        sendMail(
                to,
                "Demande d'inscription reçue",
                "Votre demande d'inscription a bien été reçue.\n" +
                        "Elle est actuellement en attente de validation par un administrateur.\n\n" +
                        "Cordialement,\nIronGrid"
        );
    }

    @Async
    public void sendApprovedAccountMail(User user) {
        String role = user.getRole() != null ? user.getRole().getName() : "-";

        sendMail(
                user.getEmail(),
                "Création de compte acceptée",
                "Votre demande de création de compte a été acceptée.\n\n" +
                        "Email : " + safe(user.getEmail()) + "\n" +
                        "Rôle attribué : " + role.toUpperCase() + "\n\n" +
                        "Vous pouvez maintenant vous connecter à l'application avec le mot de passe choisi lors de l'inscription.\n\n" +
                        "Cordialement,\nIronGrid"
        );
    }

    @Async
    public void sendRejectedAccountMail(String to, String displayName) {
        sendMail(
                to,
                "Création de compte refusée",
                "Votre demande de création de compte a été refusée.\n" +
                        "Veuillez contacter l'administrateur pour plus d'informations.\n\n" +
                        "Cordialement,\nIronGrid"
        );
    }

    @Async
    public void sendResetCode(String to, String rawCode) {
        sendMail(
                to,
                "Code de réinitialisation",
                "Votre code de réinitialisation est : " + rawCode + "\n" +
                        "Ce code expire dans 10 minutes.\n\n" +
                        "Cordialement,\nIronGrid"
        );
    }

    private void sendMail(String to, String subject, String body) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, false, "UTF-8");

            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(body, false);
            helper.setFrom(new InternetAddress(fromEmail, fromName));

            mailSender.send(message);
        } catch (Exception e) {
            throw new RuntimeException("Erreur lors de l'envoi du mail", e);
        }
    }

    private String safe(String value) {
        return value == null || value.isBlank() ? "-" : value;
    }
}