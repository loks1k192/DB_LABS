# ЛР 2. SQL-запросы и аналитические сценарии

**Вариант 11 — система управления проектами.** Запросы выполняются на базе [ЛР 1](../lab1/) после миграции. Модель не расширялась.

Задание: [Лабораторная работа № 2.pdf](Лабораторная%20работа%20№%202.pdf).

## Файлы

| Файл | Задание | Содержание |
|------|---------|------------|
| [01_data.sql](01_data.sql) | 1.1 | дополнение тестовых данных |
| [02_dml.sql](02_dml.sql) | 1.2 | INSERT, UPDATE, массовое UPDATE, DELETE, ROLLBACK |
| [03_joins.sql](03_joins.sql) | 2.1 | запросы с JOIN |
| [04_aggregates.sql](04_aggregates.sql) | 2.2 | агрегация и группировка |
| [05_subqueries.sql](05_subqueries.sql) | 3.1–3.4 | подзапросы, EXISTS, NOT EXISTS, коррелированный подзапрос |
| [06_report.sql](06_report.sql) | 4 | отчёт с CTE |

## Запуск

Из корня репозитория, по порядку на чистой базе:

```bash
docker compose exec db psql -U student -d labs -f /labs/lab1/schema.sql
docker compose exec db psql -U student -d labs -f /labs/lab1/data.sql
docker compose exec db psql -U student -d labs -f /labs/lab1/migration.sql
docker compose exec db psql -U student -d labs -f /labs/lab2/01_data.sql
docker compose exec db psql -U student -d labs -f /labs/lab2/02_dml.sql
docker compose exec db psql -U student -d labs -f /labs/lab2/03_joins.sql
docker compose exec db psql -U student -d labs -f /labs/lab2/04_aggregates.sql
docker compose exec db psql -U student -d labs -f /labs/lab2/05_subqueries.sql
docker compose exec db psql -U student -d labs -f /labs/lab2/06_report.sql
```

## Данные (1.1)

После `01_data.sql` в базе 165 записей, в таблице `tasks` — 30.

- статусы задач: `todo`, `in_progress`, `review`, `done`, `cancelled`;
- задачи созданы в 12 разных месяцах;
- повторяющиеся операции: у задачи несколько записей в истории статусов и несколько комментариев;
- без связанных записей: проект DOCS (нет команды и задач), сотрудники Белов и Волкова (нет задач);
- пограничные значения: бюджет DOCS равен 0, задачи без исполнителя, оценки и срока (NULL).

## Отчёт (часть 4)

Вопрос: как продвигаются проекты — сколько задач выполнено и просрочено, какой процент выполнения, сколько дней в среднем занимает задача?

| Этап | Вход | Преобразование | Результат |
|------|------|----------------|-----------|
| исходные данные | таблица `tasks` | отбрасываются отменённые задачи | задачи проектов |
| промежуточные показатели (`task_data`) | задачи | для каждой задачи: выполнена ли, просрочена ли, сколько дней выполнялась | строка на задачу с показателями |
| агрегация (`project_stats`) | `task_data` | группировка по проекту: всего задач, выполнено, просрочено, средний срок выполнения | строка на проект |
| итоговый отчёт | `project_stats` и `projects` | добавляются код и статус проекта, считается процент выполнения | отчёт по проектам |
