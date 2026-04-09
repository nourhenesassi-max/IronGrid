
package com.example.irongrid.security;

import com.example.irongrid.user.User;
import com.example.irongrid.user.UserRepository;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.*;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class DbUserDetailsService implements UserDetailsService {

    private final UserRepository userRepo;

    public DbUserDetailsService(UserRepository userRepo) {
        this.userRepo = userRepo;
    }

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        User u = userRepo.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("User not found: " + email));

        String roleUpper = u.getRole() == null || u.getRole().getName() == null
                ? ""
                : u.getRole().getName().toUpperCase();

        return new org.springframework.security.core.userdetails.User(
                u.getEmail(),
                u.getPasswordHash(),
                roleUpper.isBlank()
                        ? List.of()
                        : List.of(new SimpleGrantedAuthority("ROLE_" + roleUpper))
        );
    }
}
