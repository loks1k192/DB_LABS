-- Проверка ограничений целостности (запускать после schema.sql, data.sql и migration.sql)

\echo 'NOT NULL: нет фамилии'
INSERT INTO users (first_name, login, email)
VALUES ('Безфамильный', 'nolastname', 'nolastname@devstudio.ru');

\echo 'UNIQUE: email уже занят'
INSERT INTO users (first_name, last_name, login, email)
VALUES ('Андрей', 'Иванов', 'ivanov.an', 'a.ivanov@devstudio.ru');

\echo 'UNIQUE: логин уже занят'
INSERT INTO users (first_name, last_name, login, email)
VALUES ('Анатолий', 'Попов', 'popova.a', 'a.popov@devstudio.ru');

\echo 'CHECK: email с заглавными буквами'
INSERT INTO users (first_name, last_name, login, email)
VALUES ('Сергей', 'Петров', 'petrov.s', 'Petrov@DevStudio.ru');

\echo 'UNIQUE: код проекта уже занят'
UPDATE projects SET code = 'CRM' WHERE id = 3;

\echo 'CHECK: код проекта строчными буквами'
INSERT INTO projects (code, name, owner_id, start_date)
VALUES ('hr', 'Кадровый портал', 1, '2026-11-01');

\echo 'составной CHECK: проект заканчивается раньше, чем начинается'
UPDATE projects SET end_date = '2026-01-01' WHERE id = 1;

\echo 'CHECK: статус проекта'
UPDATE projects SET status = 'frozen' WHERE id = 4;

\echo 'FK: руководитель не существует'
INSERT INTO projects (code, name, owner_id, start_date)
VALUES ('HR', 'Кадровый портал', 999, '2026-11-01');

\echo 'составной PK: Кузнецов уже в команде CRM'
INSERT INTO project_members (project_id, user_id, role)
VALUES (1, 3, 'tester');

\echo 'CHECK: роль в проекте'
INSERT INTO project_members (project_id, user_id, role)
VALUES (4, 3, 'boss');

\echo 'составной UNIQUE: в CRM уже есть задача с номером 1'
INSERT INTO tasks (project_id, task_number, title, author_id)
VALUES (1, 1, 'Дубликат номера', 1);

\echo 'составной FK: Соколова не в команде CRM, назначить её на CRM-3 нельзя'
UPDATE tasks SET assignee_id = 6 WHERE id = 3;

\echo 'составной CHECK: статус done без даты выполнения'
UPDATE tasks SET status = 'done' WHERE id = 3;

\echo 'CHECK: приоритет'
UPDATE tasks SET priority = 'urgent' WHERE id = 5;

\echo 'CHECK: статус в истории статусов'
INSERT INTO task_status_history (task_id, status, started_at)
VALUES (3, 'paused', '2026-09-22 10:00+03');

\echo 'составной CHECK: период статуса заканчивается раньше, чем начинается'
INSERT INTO task_status_history (task_id, status, started_at, ended_at)
VALUES (3, 'review', '2026-10-05 10:00+03', '2026-10-01 10:00+03');

\echo 'CHECK: комментарий из одних пробелов'
INSERT INTO comments (task_id, author_id, body)
VALUES (3, 2, '    ');

\echo 'RESTRICT: у Кузнецова есть комментарии'
DELETE FROM users WHERE id = 3;


\echo 'Демонстрация ON DELETE (изменения откатываются)'
BEGIN;

\echo 'SET NULL: Кузнецова убрали из команды CRM — его задачи остались без исполнителя'
DELETE FROM project_members WHERE project_id = 1 AND user_id = 3;
SELECT id, project_id, task_number, assignee_id FROM tasks WHERE id IN (2, 3);

\echo 'CASCADE: проект SITE удаляется вместе с командой, задачами и комментариями'
DELETE FROM projects WHERE id = 3;
SELECT
    (SELECT count(*) FROM project_members WHERE project_id = 3)            AS members,
    (SELECT count(*) FROM tasks           WHERE project_id = 3)            AS tasks,
    (SELECT count(*) FROM comments        WHERE task_id IN (16, 17, 18))   AS comments;

ROLLBACK;
