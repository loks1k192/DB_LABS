BEGIN;

DROP TABLE time_entries;

CREATE TABLE task_status_history (
    id          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    task_id     INTEGER NOT NULL REFERENCES tasks (id) ON DELETE CASCADE,
    status      VARCHAR(20) NOT NULL
                CHECK (status IN ('todo', 'in_progress', 'review', 'done', 'cancelled')),
    started_at  TIMESTAMPTZ NOT NULL,
    ended_at    TIMESTAMPTZ,
    CONSTRAINT task_status_history_period_check CHECK (ended_at IS NULL OR ended_at > started_at)
);

COMMIT;
