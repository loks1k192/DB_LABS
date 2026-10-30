-- Задание 2.2. Агрегация и группировка.
\echo '2.2.1. Количество задач в каждом статусе по проектам'
SELECT
    p.code AS project,
    t.status,
    count(*) AS tasks
FROM
    tasks t
    JOIN projects p ON p.id = t.project_id
GROUP BY
    p.code,
    t.status
ORDER BY
    p.code,
    t.status;

\echo '2.2.2. Исполнители, у которых в незавершённых задачах больше 40 часов работы по оценке'
SELECT
    u.last_name,
    count(*) AS open_tasks,
    sum(t.estimate_hours) AS total_hours,
    round(avg(t.estimate_hours), 1) AS avg_hours
FROM
    tasks t
    JOIN users u ON u.id = t.assignee_id
WHERE
    t.status NOT IN ('done', 'cancelled')
GROUP BY
    u.last_name
HAVING
    sum(t.estimate_hours) > 40
ORDER BY
    total_hours DESC;

\echo '2.2.3. Сравнение приоритетов: сколько дней выполнялись задачи (среднее, минимум, максимум)'
SELECT
    t.priority,
    count(*) AS done_tasks,
    round(avg(t.completed_at::date - t.created_at::date), 1) AS avg_days,
    min(t.completed_at::date - t.created_at::date) AS min_days,
    max(t.completed_at::date - t.created_at::date) AS max_days
FROM
    tasks t
WHERE
    t.status = 'done'
GROUP BY
    t.priority
ORDER BY
    avg_days;

