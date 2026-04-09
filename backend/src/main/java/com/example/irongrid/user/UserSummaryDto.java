package com.example.irongrid.user;

public class UserSummaryDto {

    private Long id;
    private String name;
    private String role;
    private String email;
    private String avatarUrl; // ✅ added

    // ✅ OLD constructor (kept → no break)
    public UserSummaryDto(Long id, String name, String role, String email) {
        this.id = id;
        this.name = name;
        this.role = role;
        this.email = email;
    }

    // ✅ NEW constructor (used for messages)
    public UserSummaryDto(Long id, String name, String role, String email, String avatarUrl) {
        this.id = id;
        this.name = name;
        this.role = role;
        this.email = email;
        this.avatarUrl = avatarUrl;
    }

    // ✅ Getters

    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public String getFullName() {
        return name;
    }

    public String getRole() {
        return role;
    }

    public String getEmail() {
        return email;
    }

    public String getAvatarUrl() { // ✅ added
        return avatarUrl;
    }
}
