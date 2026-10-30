-- Часть 3. Подзапросы.

\echo '3.1. Задачи, оценка которых выше средней оценки задач своего проекта'
SELECT
  p.code || '-' || t.task_number AS task,
  t.title,
  t.estimate_hours,
  round(a.avg_hours, 1) AS project_avg_hours
FROM
  tasks t
  JOIN projects p ON p.id = t.project_id
  JOIN (
    SELECT
      project_id,
      avg(estimate_hours) AS avg_hours
    FROM
      tasks
    GROUP BY
      project_id
  ) a ON a.project_id = t.project_id
WHERE
  t.estimate_hours > a.avg_hours
ORDER BY
  p.code,
  t.estimate_hours DESC;

\echo '3.2. Проекты, в которых есть незавершённая задача критического приоритета (EXISTS)'
SELECT
  p.code,
  p.name
FROM
  projects p
WHERE
  EXISTS (
    SELECT
      1
    FROM
      tasks t
    WHERE
      t.project_id = p.id
      AND t.priority = 'critical'
      AND t.status NOT IN ('done', 'cancelled')
  );

\echo '3.3. Выполненные задачи, которые не проходили ревью (NOT EXISTS)'
SELECT
  p.code || '-' || t.task_number AS task,
  t.title
FROM
  tasks t
  JOIN projects p ON p.id = t.project_id
WHERE
  t.status = 'done'
  AND NOT EXISTS (
    SELECT
      1
    FROM
      task_status_history h
    WHERE
      h.task_id = t.id
      AND h.status = 'review'
  );

\echo '3.4. Для каждого сотрудника: число незавершённых задач и написанных комментариев (коррелированные подзапросы)'
SELECT
  u.last_name,
  (
    SELECT
      count(*)
    FROM
      tasks t
    WHERE
      t.assignee_id = u.id
      AND t.status NOT IN ('done', 'cancelled')
  ) AS open_tasks,
  (
    SELECT
      count(*)
    FROM
      comments c
    WHERE
      c.author_id = u.id
  ) AS comments
FROM
  users u
ORDER BY
  open_tasks DESC,
  u.last_name;