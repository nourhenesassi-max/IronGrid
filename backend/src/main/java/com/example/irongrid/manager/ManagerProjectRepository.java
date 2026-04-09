package com.example.irongrid.manager;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ManagerProjectRepository extends JpaRepository<ManagerProject, Long> {

    List<ManagerProject> findByManagerId(Long managerId);
    List<ManagerProject> findByEmployeeId(Long employeeId);

    Optional<ManagerProject> findByIdAndManagerId(Long id, Long managerId);

    void deleteByManagerId(Long managerId);
}