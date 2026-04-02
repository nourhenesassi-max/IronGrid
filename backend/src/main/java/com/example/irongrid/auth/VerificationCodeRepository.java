package com.example.irongrid.auth;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface VerificationCodeRepository extends JpaRepository<VerificationCode, Long> {

    Optional<VerificationCode> findTopByEmailAndUsedFalseOrderByIdDesc(String email);

    List<VerificationCode> findByEmailAndUsedFalse(String email);
}