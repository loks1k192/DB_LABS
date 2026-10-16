DROP TABLE IF EXISTS users, projects, project_members, tasks, comments, time_entries CASCADE;


CREATE TABLE users (
    id          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name  VARCHAR(100) NOT NULL,
    last_name   VARCHAR(100) NOT NULL,
    login       VARCHAR(32)  NOT NULL UNIQUE CHECK (login = lower(login) AND length(login) >= 3),
    email       VARCHAR(100) NOT NULL UNIQUE
                CHECK (email = lower(email) AND email LIKE '%_@_%'),
    job_title   VARCHAR(100),
    is_active   BOOLEAN NOT NULL DEFAULT true
);

CREATE TABLE projects (
    id          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code        VARCHAR(10)  NOT NULL UNIQUE CHECK (code = upper(code)),
    name        VARCHAR(200) NOT NULL,
    owner_id    INTEGER NOT NULL REFERENCES users (id) ON DELETE RESTRICT,
    status      VARCHAR(20)  NOT NULL DEFAULT 'planned'
                CHECK (status IN ('planned', 'active', 'on_hold', 'completed', 'cancelled')),
    start_date  DATE NOT NULL,
    end_date    DATE,
    budget      NUMERIC(14,2) CHECK (budget >= 0),
    description TEXT,
    CONSTRAINT projects_dates_check CHECK (end_date IS NULL OR end_date >= start_date)
);

CREATE TABLE project_members (
    project_id  INTEGER NOT NULL REFERENCES projects (id) ON DELETE CASCADE,
    user_id     INTEGER NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    role        VARCHAR(20) NOT NULL
                CHECK (role IN ('manager', 'analyst', 'developer', 'tester', 'designer')),
    joined_at   DATE NOT NULL DEFAULT CURRENT_DATE,
    PRIMARY KEY (project_id, user_id)
);

CREATE TABLE tasks (
    id             INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    project_id     INTEGER NOT NULL REFERENCES projects (id) ON DELETE CASCADE,
    task_number    INTEGER NOT NULL CHECK (task_number > 0),
    title          VARCHAR(200) NOT NULL,
    status         VARCHAR(20)  NOT NULL DEFAULT 'todo'
                   CHECK (status IN ('todo', 'in_progress', 'review', 'done', 'cancelled')),
    priority       VARCHAR(20)  NOT NULL DEFAULT 'medium'
                   CHECK (priority IN ('low', 'medium', 'high', 'critical')),
    author_id      INTEGER NOT NULL REFERENCES users (id) ON DELETE RESTRICT,
    assignee_id    INTEGER,
    estimate_hours NUMERIC(6,2) CHECK (estimate_hours > 0),
    due_date       DATE,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    completed_at   TIMESTAMPTZ,
    description    TEXT,
    CONSTRAINT tasks_number_unique UNIQUE (project_id, task_number),
    CONSTRAINT tasks_completed_check CHECK (
        (status = 'done' AND completed_at IS NOT NULL) OR
        (status <> 'done' AND completed_at IS NULL)
    ),
    -- исполнитель должен состоять в команде этого проекта;
    -- при удалении его из команды обнуляется только assignee_id
    FOREIGN KEY (project_id, assignee_id)
        REFERENCES project_members (project_id, user_id) ON DELETE SET NULL (assignee_id)
);

CREATE TABLE comments (
    id          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    task_id     INTEGER NOT NULL REFERENCES tasks (id) ON DELETE CASCADE,
    author_id   INTEGER NOT NULL REFERENCES users (id) ON DELETE RESTRICT,
    body        TEXT NOT NULL CHECK (btrim(body) <> ''),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE time_entries (
    id          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    task_id     INTEGER NOT NULL REFERENCES tasks (id) ON DELETE CASCADE,
    user_id     INTEGER NOT NULL REFERENCES users (id) ON DELETE RESTRICT,
    work_date   DATE NOT NULL,
    hours       NUMERIC(4,2) NOT NULL CHECK (hours > 0 AND hours <= 24),
    note        VARCHAR(200),
    CONSTRAINT time_entries_day_unique UNIQUE (task_id, user_id, work_date)
);
