package com.example.irongrid.manager;

import org.springframework.data.jpa.repository.JpaRepository;

public interface ManagerTaskRepository extends JpaRepository<ManagerTask, Long> {

    void deleteByProject_Id(Long projectId);
}