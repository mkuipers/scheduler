# Scheduler

A small **Rails 8** app for informal **meeting polls**: an organizer creates a poll, adds time options on a calendar, and shares a link. Participants pick **yes / maybe / no** per slot; everyone can view a **responses matrix**. No accounts—identity is a signed cookie (creator vs voter).

## Features

- **Creator flow**: month calendar, time windows (natural language, e.g. `2pm–4pm`, `330pm`), quick-add presets, per-day slot list.
- **Participant flow**: join with a name, availability grouped **by day** with optional **decline all for that day**, copyable **share link**.
- **Usage stats** (`/scheduler/usage`): public totals and 14-day charts (polls created, responses saved)—no poll titles or personal data.
- **Deploy**: Docker + [Fly.io](https://fly.io/) friendly (SQLite on a volume; see `fly.toml` if present).

## Requirements

- Ruby **3.3.x** (see `Gemfile`)
- SQLite 3 (default)

## Setup

```bash
bundle install
bin/rails db:prepare
bin/rails server
```

Open [http://localhost:3000/scheduler](http://localhost:3000/scheduler) (root redirects there).

## Configuration

| Env / setting | Purpose |
|---------------|---------|
| `SOURCE_CODE_URL` | URL for the **Source code** header link (default: this repo’s GitHub URL in `config/initializers/app_links.rb`) |
| `DATABASE_URL` | Optional in production for SQLite path / Solid DBs (see `config/database.yml`) |

## Tests

```bash
bin/rails test
```

System tests use Selenium + headless Chrome; ensure Chrome/Chromium is available if you run `test/system`.

## Deployment (Fly.io)

With the Fly CLI logged in and `fly.toml` configured for your app:

```bash
fly deploy
```

Set secrets (e.g. `SECRET_KEY_BASE`) per Fly’s Rails docs. Consider moving sensitive values out of `[env]` in `fly.toml` into `fly secrets set`.

## License

Use and modify as you like unless otherwise noted.
