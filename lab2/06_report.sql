-- Часть 4. Отчёт: как продвигаются проекты — сколько задач выполнено и просрочено,
-- какой процент выполнения и сколько дней в среднем занимает задача.
\ echo '4. Отчёт по проектам: выполнение, просрочки, средний срок выполнения задачи' -- Исходные данные: таблица tasks.
WITH -- 1. Промежуточные показатели по каждой задаче (отменённые задачи не учитываются)
task_data AS (
    SELECT
        t.project_id,
        t.status = 'done' AS is_done,
        t.status NOT IN ('done', 'cancelled')
        AND t.due_date < CURRENT_DATE AS is_overdue,
        t.completed_at :: date - t.created_at :: date AS days_to_done
    FROM
        tasks t
    WHERE
        t.status <> 'cancelled'
),
-- 2. Агрегация по проектам
project_stats AS (
    SELECT
        project_id,
        count(*) AS tasks,
        count(*) FILTER (
            WHERE
                is_done
        ) AS done,
        count(*) FILTER (
            WHERE
                is_overdue
        ) AS overdue,
        round(avg(days_to_done), 1) AS avg_days_to_done
    FROM
        task_data
    GROUP BY
        project_id
) -- 3. Итоговый отчёт
SELECT
    p.code,
    p.status,
    s.tasks,
    s.done,
    round(100.0 * s.done / s.tasks) AS done_pct,
    s.overdue,
    s.avg_days_to_done
FROM
    project_stats s
    JOIN projects p ON p.id = s.project_id
ORDER BY
    done_pct;