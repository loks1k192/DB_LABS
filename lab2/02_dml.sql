-- Задание 1.2. Операции изменения данных (запускать один раз после 01_data.sql).
SET timezone = 'Europe/Moscow';

\echo '1. INSERT: новая задача CRM-14 и её первая запись в истории статусов'
BEGIN;
INSERT INTO tasks (project_id, task_number, title, priority, author_id, assignee_id, estimate_hours, due_date)
    VALUES (1, 14, 'Интеграция с почтой', 'medium', 1, 11, 16, '2026-12-01');
INSERT INTO task_status_history (task_id, status, started_at)
SELECT
    id,
    status,
    created_at
FROM
    tasks
WHERE
    project_id = 1
    AND task_number = 14;
COMMIT;

SELECT
    t.id,
    t.task_number,
    t.title,
    t.status,
    h.status AS history_status,
    h.started_at
FROM
    tasks t
    JOIN task_status_history h ON h.task_id = t.id
WHERE
    t.project_id = 1
    AND t.task_number = 14;

\echo '2. UPDATE: задача CRM-4 (id 4) прошла ревью и выполнена'
BEGIN;
UPDATE
    task_status_history
SET
    ended_at = NOW()
WHERE
    task_id = 4
    AND ended_at IS NULL;
INSERT INTO task_status_history (task_id, status, started_at)
    VALUES (4, 'done', NOW());
UPDATE
    tasks
SET
    status = 'done',
    completed_at = NOW()
WHERE
    id = 4;
COMMIT;

SELECT
    status,
    started_at,
    ended_at
FROM
    task_status_history
WHERE
    task_id = 4
ORDER BY
    started_at;

\echo '3. Массовое UPDATE: незавершённым задачам CRM без исполнителя назначается аналитик Смирнова (id 2)'
UPDATE
    tasks
SET
    assignee_id = 2
WHERE
    project_id = 1
    AND assignee_id IS NULL
    AND status NOT IN ('done', 'cancelled');

SELECT
    task_number,
    title,
    status,
    assignee_id
FROM
    tasks
WHERE
    project_id = 1
ORDER BY
    task_number;

\echo '4. DELETE: отменённая задача CRM-8 (id 8) удаляется вместе с историей (ON DELETE CASCADE)'
SELECT
    count(*) AS history_before
FROM
    task_status_history
WHERE
    task_id = 8;

DELETE FROM tasks
WHERE id = 8;

SELECT
    count(*) AS history_after
FROM
    task_status_history
WHERE
    task_id = 8;

\echo '5. ROLLBACK: удаление всех комментариев отменяется'
SELECT
    count(*) AS comments_before
FROM
    comments;

BEGIN;
DELETE FROM comments;
SELECT
    count(*) AS comments_inside_transaction
FROM
    comments;
ROLLBACK;

SELECT
    count(*) AS comments_after_rollback
FROM
    comments;

