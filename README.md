# Базы данных — лабораторные работы

5 семестр, 2026. СУБД — PostgreSQL 17 в Docker.

| № | Тема | Папка | Срок |
|---|------|-------|------|
| 1 | Проектирование и реализация реляционной БД (вариант 11 — система управления проектами) | [lab1](lab1/) | 20.10 |

## Запуск PostgreSQL

```bash
docker compose up -d                              # поднять сервер
docker compose exec db psql -U student -d labs    # консоль psql
```

Корень репозитория смонтирован в контейнер как `/labs`, скрипты запускаются так:

```bash
docker compose exec db psql -U student -d labs -f /labs/lab1/schema.sql
```

Подключение из DBeaver или другого клиента: `localhost:5432`, база `labs`, пользователь и пароль `student`.

## Структура

```
labN/
├── README.md     — описание лабы и запуск
└── *.sql         — скрипты по заданию
```
