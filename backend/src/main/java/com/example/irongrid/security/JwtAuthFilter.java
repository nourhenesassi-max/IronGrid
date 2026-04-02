package com.example.irongrid.security;

import com.example.irongrid.user.User;
import com.example.irongrid.user.UserRepository;
import io.jsonwebtoken.Claims;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpHeaders;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;

@Component
public class JwtAuthFilter extends OncePerRequestFilter {

    private final JwtService jwtService;
    private final UserRepository userRepo;

    public JwtAuthFilter(JwtService jwtService, UserRepository userRepo) {
        this.jwtService = jwtService;
        this.userRepo = userRepo;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain)
            throws ServletException, IOException {

        System.out.println("=== JWT FILTER ===");
        System.out.println("METHOD: " + request.getMethod());
        System.out.println("URI: " + request.getRequestURI());

        String auth = request.getHeader(HttpHeaders.AUTHORIZATION);
        System.out.println("AUTH HEADER: " + auth);

        if (auth == null || !auth.startsWith("Bearer ")) {
            System.out.println("NO BEARER TOKEN");
            filterChain.doFilter(request, response);
            return;
        }

        String token = auth.substring(7);

        try {
            Claims claims = jwtService.parseClaims(token);
            String subject = claims.getSubject();
            String tokenRole = claims.get("role", String.class);
            String tokenEmail = claims.get("email", String.class);

            System.out.println("SUBJECT FROM TOKEN: " + subject);
            System.out.println("EMAIL CLAIM FROM TOKEN: " + tokenEmail);
            System.out.println("ROLE FROM TOKEN: " + tokenRole);

            if ((subject == null || subject.isBlank()) && (tokenEmail == null || tokenEmail.isBlank())) {
                System.out.println("TOKEN SUBJECT AND EMAIL CLAIM ARE EMPTY");
                SecurityContextHolder.clearContext();
                filterChain.doFilter(request, response);
                return;
            }

            User u = resolveUser(subject, tokenEmail);
            System.out.println("USER FOUND IN DB: " + (u != null));
            String principalEmail = u != null
                    ? u.getEmail()
                    : (tokenEmail != null && !tokenEmail.isBlank() ? tokenEmail : subject);

            String role = null;

            if (u != null && u.getRole() != null && u.getRole().getName() != null) {
                role = u.getRole().getName();
                System.out.println("ROLE FROM DB: " + role);
            } else {
                role = tokenRole;
                System.out.println("USING ROLE FROM TOKEN: " + role);
            }

            if (role == null || role.isBlank()) {
                System.out.println("FINAL ROLE IS EMPTY");
                SecurityContextHolder.clearContext();
                filterChain.doFilter(request, response);
                return;
            }

            String roleUpper = role.trim().toUpperCase();
            if (roleUpper.startsWith("ROLE_")) {
                roleUpper = roleUpper.substring("ROLE_".length());
            }

            var authorities = List.of(new SimpleGrantedAuthority("ROLE_" + roleUpper));
            var authentication = new UsernamePasswordAuthenticationToken(
                    principalEmail,
                    null,
                    authorities
            );

            SecurityContextHolder.getContext().setAuthentication(authentication);
            System.out.println("AUTHENTICATED AS: " + principalEmail + " / ROLE_" + roleUpper);

        } catch (Exception e) {
            System.out.println("JWT FILTER ERROR: " + e.getMessage());
            e.printStackTrace();
            SecurityContextHolder.clearContext();
        }

        filterChain.doFilter(request, response);
    }

    private User resolveUser(String subject, String tokenEmail) {
        if (subject != null && !subject.isBlank()) {
            try {
                Long userId = Long.parseLong(subject);
                User byId = userRepo.findById(userId).orElse(null);
                if (byId != null) {
                    return byId;
                }
            } catch (NumberFormatException ignored) {
                User byEmail = userRepo.findByEmail(subject).orElse(null);
                if (byEmail != null) {
                    return byEmail;
                }
            }
        }

        if (tokenEmail != null && !tokenEmail.isBlank()) {
            return userRepo.findByEmail(tokenEmail).orElse(null);
        }

        return null;
    }
}
