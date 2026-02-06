# ADR-010: Display Scoring Workflow

## Status

**Accepted**

## Date

2026-02-04

## Context

DMS VIPPro includes a "VIP Display Scoring" feature where:

1. **NVBH (Sales Reps)** capture photos of product displays at customer locations
2. **GSBH (Supervisors)** review and score these photos
3. Scores determine compliance with display standards and may affect incentives

### Business Requirements

- Photos are captured during visits with GPS location
- Multiple photos per visit (different angles, products)
- Scoring is binary: Pass (Đạt) or Fail (Không đạt)
- Revenue attribution to display scores
- Batch scoring for efficiency
- Pending scores dashboard

## Decision

We will implement a **dedicated scoring entity** with asynchronous evaluation workflow.

### Workflow Design

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                       DISPLAY SCORING WORKFLOW                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  PHASE 1: CAPTURE (NVBH Mobile)                                            │
│  ──────────────────────────────                                             │
│                                                                             │
│  1. NVBH checks in at customer                                              │
│  2. NVBH takes display photos (TrungBay album)                             │
│  3. Photos uploaded with GPS, timestamp                                     │
│  4. System creates DisplayScore record (pending)                            │
│                                                                             │
│        ┌──────────┐     ┌──────────┐     ┌──────────┐                      │
│        │  Visit   │────▶│  Photos  │────▶│ Display  │                      │
│        │  Check-in│     │  Upload  │     │  Score   │                      │
│        └──────────┘     └──────────┘     │ (Pending)│                      │
│                                          └──────────┘                      │
│                                                                             │
│  PHASE 2: REVIEW (GSBH Web/Mobile)                                         │
│  ─────────────────────────────────                                          │
│                                                                             │
│  1. GSBH views pending scores dashboard                                     │
│  2. Opens score detail with photos                                          │
│  3. Reviews photos for display compliance                                   │
│  4. Marks as Pass/Fail with optional revenue                               │
│                                                                             │
│        ┌──────────┐     ┌──────────┐     ┌──────────┐                      │
│        │ Pending  │────▶│  Review  │────▶│  Score   │                      │
│        │ Queue    │     │  Photos  │     │ Recorded │                      │
│        └──────────┘     └──────────┘     └──────────┘                      │
│                                                                             │
│  PHASE 3: REPORTING                                                         │
│  ──────────────────                                                         │
│                                                                             │
│  - Pass rate by NVBH                                                        │
│  - Pass rate by customer/territory                                          │
│  - Revenue attributed to displays                                           │
│  - Trend analysis                                                           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Database Schema

```sql
-- Display Score record (created when TrungBay photos uploaded)
CREATE TABLE display_scores (
    score_id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    visit_id            UUID NOT NULL REFERENCES visits(visit_id),
    customer_id         UUID NOT NULL REFERENCES customers(customer_id),
    distributor_id      UUID NOT NULL REFERENCES distributors(distributor_id),

    -- Capture info
    captured_by_user_id UUID NOT NULL REFERENCES users(user_id),
    photo_count         INT NOT NULL DEFAULT 0,
    upload_date         DATE NOT NULL,

    -- Scoring info (NULL until scored)
    scored_by_user_id   UUID NULL REFERENCES users(user_id),
    scored_date         DATE NULL,
    is_passed           BOOLEAN NULL,
    revenue             DECIMAL(18,2) NULL,
    notes               TEXT NULL,

    -- Metadata
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for common queries
CREATE INDEX ix_display_scores_pending
    ON display_scores(distributor_id, upload_date DESC)
    WHERE scored_by_user_id IS NULL;

CREATE INDEX ix_display_scores_captured_by
    ON display_scores(captured_by_user_id, upload_date DESC);

CREATE INDEX ix_display_scores_customer
    ON display_scores(customer_id, upload_date DESC);

CREATE INDEX ix_display_scores_scored_by
    ON display_scores(scored_by_user_id, scored_date DESC)
    WHERE scored_by_user_id IS NOT NULL;

-- Link to actual photos (already in visit_photos table)
-- visit_photos.album_type = 'TrungBay' for display photos
```

### Auto-creation on Photo Upload

```csharp
public class VisitPhotoService : IVisitPhotoService
{
    public async Task<VisitPhoto> UploadPhotoAsync(
        Guid visitId,
        Guid userId,
        Stream photoStream,
        AlbumType albumType,
        double latitude,
        double longitude,
        CancellationToken ct = default)
    {
        // Upload to blob storage
        var blobUrl = await _blobService.UploadAsync(photoStream, ct);

        // Create photo record
        var photo = new VisitPhoto
        {
            VisitId = visitId,
            AlbumType = albumType,
            ImageUrl = blobUrl,
            Latitude = latitude,
            Longitude = longitude,
            CapturedAt = DateTime.UtcNow
        };

        await _db.VisitPhotos.AddAsync(photo, ct);

        // If TrungBay album, ensure DisplayScore exists
        if (albumType == AlbumType.TrungBay)
        {
            await EnsureDisplayScoreAsync(visitId, userId, ct);
        }

        await _db.SaveChangesAsync(ct);
        return photo;
    }

    private async Task EnsureDisplayScoreAsync(
        Guid visitId,
        Guid userId,
        CancellationToken ct)
    {
        var existingScore = await _db.DisplayScores
            .FirstOrDefaultAsync(ds => ds.VisitId == visitId, ct);

        if (existingScore != null)
        {
            // Increment photo count
            existingScore.PhotoCount++;
            return;
        }

        // Get visit details
        var visit = await _db.Visits
            .Include(v => v.Customer)
            .FirstAsync(v => v.VisitId == visitId, ct);

        // Create new DisplayScore
        var displayScore = new DisplayScore
        {
            VisitId = visitId,
            CustomerId = visit.CustomerId,
            DistributorId = visit.Customer.DistributorId,
            CapturedByUserId = userId,
            PhotoCount = 1,
            UploadDate = DateTime.UtcNow.Date
        };

        await _db.DisplayScores.AddAsync(displayScore, ct);
    }
}
```

### Scoring Service

```csharp
public class DisplayScoreService : IDisplayScoreService
{
    public async Task<DisplayScore> ScoreAsync(
        Guid scoreId,
        Guid scorerId,
        bool isPassed,
        decimal? revenue,
        string? notes,
        CancellationToken ct = default)
    {
        var score = await _db.DisplayScores
            .FirstOrDefaultAsync(ds => ds.ScoreId == scoreId, ct)
            ?? throw new NotFoundException("Display score not found");

        if (score.ScoredByUserId != null)
            throw new BusinessException("Score already recorded");

        // Validate scorer has permission
        await ValidateScorerPermissionAsync(scorerId, score.DistributorId, ct);

        // Record score
        score.ScoredByUserId = scorerId;
        score.ScoredDate = DateTime.UtcNow.Date;
        score.IsPassed = isPassed;
        score.Revenue = revenue;
        score.Notes = notes;
        score.UpdatedAt = DateTime.UtcNow;

        await _db.SaveChangesAsync(ct);

        // Notify NVBH of score result
        await _notificationService.SendAsync(
            score.CapturedByUserId,
            new DisplayScoreNotification(score),
            ct);

        return score;
    }

    public async Task<BulkScoreResult> BulkScoreAsync(
        Guid scorerId,
        List<ScoreInput> scores,
        CancellationToken ct = default)
    {
        var result = new BulkScoreResult();

        foreach (var input in scores)
        {
            try
            {
                await ScoreAsync(
                    input.ScoreId,
                    scorerId,
                    input.IsPassed,
                    input.Revenue,
                    input.Notes,
                    ct);
                result.Success++;
            }
            catch (Exception ex)
            {
                result.Failed++;
                result.Errors.Add(new ScoreError(input.ScoreId, ex.Message));
            }
        }

        return result;
    }
}
```

### Reporting Queries

```sql
-- Display score summary by NVBH
SELECT
    u.user_id,
    u.full_name,
    COUNT(*) as total_submissions,
    COUNT(CASE WHEN ds.scored_by_user_id IS NOT NULL THEN 1 END) as scored,
    COUNT(CASE WHEN ds.is_passed = true THEN 1 END) as passed,
    COUNT(CASE WHEN ds.is_passed = false THEN 1 END) as failed,
    ROUND(
        COUNT(CASE WHEN ds.is_passed = true THEN 1 END)::numeric /
        NULLIF(COUNT(CASE WHEN ds.scored_by_user_id IS NOT NULL THEN 1 END), 0) * 100,
        1
    ) as pass_rate,
    COALESCE(SUM(ds.revenue) FILTER (WHERE ds.is_passed = true), 0) as attributed_revenue
FROM users u
JOIN display_scores ds ON u.user_id = ds.captured_by_user_id
WHERE ds.upload_date BETWEEN :startDate AND :endDate
  AND ds.distributor_id = :distributorId
GROUP BY u.user_id, u.full_name
ORDER BY pass_rate DESC;
```

## Consequences

### Positive

1. **Clear workflow**: Separate capture and scoring phases
2. **Batch processing**: GSBH can score multiple displays efficiently
3. **Auditable**: Full trail of who scored what and when
4. **Flexible**: Easy to add scoring criteria in future

### Negative

1. **Manual scoring**: No AI/automatic scoring (future enhancement)
2. **Latency**: Scores not immediately available after upload
3. **Workload**: GSBH has additional scoring responsibility

### Future Enhancements

1. **AI-assisted scoring**: Use image recognition for preliminary assessment
2. **Scoring rubric**: Detailed criteria with partial scores
3. **Escalation**: Auto-escalate old unscored items

## Related Decisions

- [ADR-006: Offline-first Mobile](ADR-006-offline-first-mobile.md) - Photo upload handling
- [05-API-DESIGN.md](../05-API-DESIGN.md) - Display scoring endpoints

## References

- PRD-v2.md Section 8: Display Scoring
