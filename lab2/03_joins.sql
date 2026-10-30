-- Задание 2.1. Многотабличные запросы.
\echo '2.1.1. Задачи с проектом, автором и исполнителем (задачи без исполнителя тоже выводятся)'
SELECT
    p.code || '-' || t.task_number AS task,
    t.title,
    t.status,
    t.priority,
    a.last_name AS author,
    s.last_name AS assignee
FROM
    tasks t
    JOIN projects p ON p.id = t.project_id
    JOIN users a ON a.id = t.author_id
    LEFT JOIN users s ON s.id = t.assignee_id
ORDER BY
    p.code,
    t.task_number;

\echo '2.1.2. Участники команд, у которых нет ни одной задачи в своём проекте'
SELECT
    p.code AS project,
    u.last_name,
    m.role
FROM
    project_members m
    JOIN projects p ON p.id = m.project_id
    JOIN users u ON u.id = m.user_id
    LEFT JOIN tasks t ON t.project_id = m.project_id
        AND t.assignee_id = m.user_id
WHERE
    t.id IS NULL
ORDER BY
    p.code,
    u.last_name;

\echo '2.1.3. Незавершённые задачи высокого и критического приоритета в активных проектах, назначенные на разработчиков'
SELECT
    p.code || '-' || t.task_number AS task,
    t.title,
    t.priority,
    t.status,
    u.last_name AS developer
FROM
    tasks t
    JOIN projects p ON p.id = t.project_id
    JOIN users u ON u.id = t.assignee_id
    JOIN project_members m ON m.project_id = t.project_id
        AND m.user_id = t.assignee_id
WHERE
    p.status = 'active'
    AND t.status NOT IN ('done', 'cancelled')
    AND t.priority IN ('high', 'critical')
    AND m.role = 'developer'
ORDER BY
    p.code,
    t.task_number;

