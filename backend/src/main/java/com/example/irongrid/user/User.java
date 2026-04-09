package com.example.irongrid.user;

import jakarta.persistence.*;

@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 150)
    private String name;

    @Column(nullable = false, unique = true, length = 190)
    private String email;

    @Column(name = "password_hash", nullable = false)
    private String passwordHash;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "role_id")
    private RoleEntity role;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private AccountStatus status = AccountStatus.PENDING;

    @Column(name = "first_name", length = 100)
    private String firstName;

    @Column(name = "last_name", length = 100)
    private String lastName;

    @Column(name = "phone", length = 50)
    private String phone;

    @Column(name = "address", length = 255)
    private String address;

    @Column(name = "avatar_url", length = 500)
    private String avatarUrl;

    @Column(name = "team_label", length = 150)
    private String teamLabel;

    @Column(name = "project_label", length = 150)
    private String projectLabel;

    public User() {
    }

    public User(String name, String email, String passwordHash, RoleEntity role) {
        this.name = name;
        this.email = email;
        this.passwordHash = passwordHash;
        this.role = role;
        this.status = AccountStatus.PENDING;
    }

    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public String getEmail() {
        return email;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public RoleEntity getRole() {
        return role;
    }

    public AccountStatus getStatus() {
        return status;
    }

    public String getFirstName() {
        return firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public String getPhone() {
        return phone;
    }

    public String getAddress() {
        return address;
    }

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public String getTeamLabel() {
        return teamLabel;
    }

    public String getProjectLabel() {
        return projectLabel;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public void setRole(RoleEntity role) {
        this.role = role;
    }

    public void setStatus(AccountStatus status) {
        this.status = status;
    }

    public void setFirstName(String firstName) {
        this.firstName = blankToNull(firstName);
    }

    public void setLastName(String lastName) {
        this.lastName = blankToNull(lastName);
    }

    public void setPhone(String phone) {
        this.phone = blankToNull(phone);
    }

    public void setAddress(String address) {
        this.address = blankToNull(address);
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = blankToNull(avatarUrl);
    }

    public void setTeamLabel(String teamLabel) {
        this.teamLabel = blankToNull(teamLabel);
    }

    public void setProjectLabel(String projectLabel) {
        this.projectLabel = blankToNull(projectLabel);
    }

    @Transient
    public String getDisplayName() {
        String fn = firstName == null ? "" : firstName.trim();
        String ln = lastName == null ? "" : lastName.trim();
        String full = (fn + " " + ln).trim();
        return !full.isEmpty() ? full : name;
    }

    private String blankToNull(String value) {
        if (value == null) return null;
        String v = value.trim();
        return v.isEmpty() ? null : v;
    }
    @Column(name = "department", length = 100)
private String department;

public String getDepartment() {
    return department;
}

public void setDepartment(String department) {
    this.department = department;
}
}