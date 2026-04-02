package com.example.irongrid.time;

import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "work_breaks")
public class WorkBreak {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    @JoinColumn(name = "session_id", nullable = false)
    private WorkSession session;

    @Column(name = "break_start", nullable = false)
    private LocalDateTime breakStart;

    @Column(name = "break_end")
    private LocalDateTime breakEnd;

    public WorkBreak() {}

    public Long getId() { return id; }
    public WorkSession getSession() { return session; }
    public LocalDateTime getBreakStart() { return breakStart; }
    public LocalDateTime getBreakEnd() { return breakEnd; }

    public void setSession(WorkSession session) { this.session = session; }
    public void setBreakStart(LocalDateTime breakStart) { this.breakStart = breakStart; }
    public void setBreakEnd(LocalDateTime breakEnd) { this.breakEnd = breakEnd; }
}