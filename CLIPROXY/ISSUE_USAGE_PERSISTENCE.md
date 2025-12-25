# Issue: Usage Statistics Persistence - Would a PR be accepted?

## Title
[Feature] Usage Statistics Persistence to JSON File - PR Proposal

## Body

### Context

I saw issue #681 was closed with "no plan for this", but I'd like to propose a **minimal, opt-in implementation** that I'm willing to contribute via PR.

I run CLIProxyAPI as a long-running service and losing usage statistics on every restart makes it hard to track usage patterns over time.

### Proposal

A simple, backwards-compatible persistence layer:

```yaml
# config.yaml
usage-statistics-persistence:
  enabled: false                    # opt-in, default off (no behavior change)
  path: "./usage_stats.json"        # file location
  interval: 300                     # save every 5 minutes (seconds)
  load-on-startup: true             # restore previous stats on start
```

### Implementation Approach

1. **Minimal changes** - Only touch `internal/usage/logger_plugin.go`
2. **No new dependencies** - Just `encoding/json` + `os` (already used elsewhere)
3. **Goroutine with ticker** - Periodic save, no performance impact on request path
4. **Atomic writes** - Write to temp file, then rename (safe for crashes)
5. **Backwards compatible** - Disabled by default, existing behavior unchanged

### Rough Implementation

```go
// In RequestStatistics struct, add:
func (s *RequestStatistics) SaveToFile(path string) error {
    snapshot := s.Snapshot()
    data, err := json.MarshalIndent(snapshot, "", "  ")
    if err != nil {
        return err
    }
    tmpPath := path + ".tmp"
    if err := os.WriteFile(tmpPath, data, 0644); err != nil {
        return err
    }
    return os.Rename(tmpPath, path)
}

func (s *RequestStatistics) LoadFromFile(path string) error {
    data, err := os.ReadFile(path)
    if err != nil {
        if os.IsNotExist(err) {
            return nil // fresh start
        }
        return err
    }
    var snapshot StatisticsSnapshot
    if err := json.Unmarshal(data, &snapshot); err != nil {
        return err
    }
    // Restore counters from snapshot...
    return nil
}
```

### Why This Approach?

| Concern | How Addressed |
|---------|---------------|
| "Too complex" | ~100 lines of code, no new deps |
| "Performance" | Async save on timer, not on request path |
| "Breaking changes" | Disabled by default |
| "Docker-friendly" | Works with volume mounts |
| "Maintenance burden" | Self-contained, easy to remove if needed |

### My Question

**Would you accept a PR implementing this?**

I'm happy to:
- Follow your code style and conventions
- Add tests
- Iterate based on feedback
- Keep it as simple as possible

If the answer is still "no", I understand and will maintain it in my fork. Just wanted to check before investing the effort.

Thanks for the great project!

---

**Related:** #681 (closed)
