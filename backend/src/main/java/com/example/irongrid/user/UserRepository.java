package com.example.irongrid.user;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByEmail(String email);

    long countByStatus(AccountStatus status);

    List<User> findByStatusOrderByIdDesc(AccountStatus status);

    @Query("""
        select u
        from User u
        join u.role r
        where lower(r.name) in :roleNames
          and u.id <> :excludedUserId
        order by u.firstName asc, u.lastName asc, u.name asc
    """)
    List<User> findMessageableUsers(List<String> roleNames, Long excludedUserId);

    @Query("""
        select u
        from User u
        join u.role r
        where lower(r.name) = 'manager'
          and u.status = com.example.irongrid.user.AccountStatus.APPROVED
          and lower(coalesce(u.teamLabel, '')) = lower(coalesce(:teamLabel, ''))
        order by u.firstName asc, u.lastName asc, u.name asc
    """)
    List<User> findApprovedManagersByTeamLabel(String teamLabel);

    @Query("""
        select u
        from User u
        join u.role r
        where lower(r.name) = 'employe'
          and u.status = com.example.irongrid.user.AccountStatus.APPROVED
          and lower(coalesce(u.teamLabel, '')) = lower(coalesce(:teamLabel, ''))
        order by u.firstName asc, u.lastName asc, u.name asc
    """)
    List<User> findApprovedEmployeesByTeamLabel(String teamLabel);

    @Query("""
        select u
        from User u
        join u.role r
        where lower(r.name) = 'rh'
          and u.status = com.example.irongrid.user.AccountStatus.APPROVED
        order by u.firstName asc, u.lastName asc, u.name asc
    """)
    List<User> findApprovedRhUsers();
}