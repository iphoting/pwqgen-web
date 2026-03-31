# CLAUDE.md — AI Assistant Guide for pwqgen-web

## Overview

A Sinatra-based web application that generates random passwords, PINs, and hex
tokens using the [`pwqgen.rb`](https://github.com/iphoting/pwqgen.rb) gem (and
optionally the legacy `pwqgen.static` binary on Linux for "classic" output).

Deployed on Dokku. Served by Puma.

---

## Technology Stack

| Layer | Technology |
|---|---|
| Ruby version | 3.4.9 (see `.ruby-version`) |
| Web framework | Sinatra 4.x with `sinatra-contrib` namespaces |
| Templating | Haml 5.x |
| Asset pipeline | Sprockets 4 + Uglifier (requires Node.js at build time) |
| Production server | Puma (via Rack) |
| Development server | Puma (via Rack) |
| Container base | `ruby:3.2.2-alpine` (pending harmonisation to slim) |
| Password generation | `pwqgen.rb` gem; classic mode: `./pwqgen.static` binary |

---

## Repository Layout

```
pwqgen-web/
├── .github/workflows/
│   ├── docker.yml        # CI: build image + HTTP 200 smoke test
│   ├── dokku.yml         # CD: deploy to Dokku on push to master
│   └── ruby.yml          # CI: run Cucumber test suite
├── _assets/js/
│   └── app.js            # Clipboard.js integration
├── features/             # Cucumber BDD tests
│   ├── main.feature
│   ├── step_definitions/
│   └── support/env.rb
├── views/                # Haml templates
│   ├── layout.haml
│   ├── index.haml        # Single-password view
│   └── multi.haml        # Multi-password list view
├── config.ru             # Rack entry point (mounts /assets + /)
├── pwqgen-web.rb         # Sinatra application — all routes + helpers
├── pwqgen.static         # Precompiled Linux binary (classic mode only)
├── Dockerfile            # Multi-stage Docker build
├── Procfile              # Dokku process definition
├── Gemfile               # Ruby gem dependencies
├── Gemfile.lock          # Locked gem versions
├── Rakefile              # Rake tasks (test target)
├── .ruby-version         # Pinned Ruby version
└── .dockerignore         # Docker build context exclusions
```

---

## Application Routes

All routes live in `pwqgen-web.rb`. SSL is enforced only in `production`
environment (`Rack::SslEnforcer, only_environments: 'production'`).

| Path | Response | Notes |
|---|---|---|
| `GET /` | 200 HTML | Single password (index.haml) |
| `GET /txt` or `/text` | 200 text/plain | Single password, plain text |
| `GET /m[ulti][/N]` | 200 HTML | N passwords (default 30) |
| `GET /m[ulti]/text[/N]` | 200 text/plain | N passwords, plain text |
| `GET /pin[/N]` | 200 HTML | N-digit PIN (default 6, max 2048) |
| `GET /pin[/N]/txt` | 200 text/plain | PIN, plain text |
| `GET /hex[/N]` | 200 HTML | N-bit hex token (default 256, max 4096) |
| `GET /hex[/N]/txt` | 200 text/plain | Hex token, plain text |
| `GET /assets/app.js` | 200 JS | Sprockets-served, uglified at runtime |

"Classic" mode activates only when `request.host == "pwqgen.herokuapp.com"` on
Linux (legacy Heroku hostname). All other environments use `pwqgen.rb`.

---

## Development Workflow

### Setup

```bash
bundle install
```

Node.js must be present for Uglifier (asset compression via Sprockets).

### Run locally

```bash
bundle exec rackup          # Puma on port 9292
```

Verify: `curl http://localhost:9292/` should return HTTP 200.

### Run tests

```bash
bundle exec rake test       # Cucumber BDD suite via Capybara
```

The test suite uses `Capybara` in rack-test mode (no browser required).
`RACK_ENV` does not need to be set for tests.

### Docker

```bash
docker build -t pwqgen-web .
docker run -p 9292:9292 -e RACK_ENV=development pwqgen-web bundle exec rackup -o 0.0.0.0
```

The Dockerfile uses a **multi-stage build**:
1. **Builder stage**: installs build tools + nodejs/npm, installs gems into `vendor/`
2. **Runtime stage**: copies `vendor/` from builder; no build tools in final image

Note: `nodejs` is absent from the final stage. Sprockets/Uglifier asset
compression is called at request time — if assets are requested in production,
the container will error. This is a known limitation to address in a future
Dockerfile harmonisation (see harmonisation plan in git history).

---

## CI/CD Pipelines

### GitHub Actions

**`docker.yml`** — runs on every push and pull request:
- Builds Docker image
- Starts container with `RACK_ENV=development` (disables SSL enforcer)
- Polls up to 60 s, then asserts HTTP 200 on `/`
- Dumps `docker logs` on timeout

**`ruby.yml`** — runs on every push and pull request:
- Sets up Ruby via `ruby/setup-ruby@v1` using `.ruby-version`
- Runs `bundle exec rake test` (Cucumber suite)

**`dokku.yml`** — runs on push to `master` only:
- Deploys to Dokku: `ssh://dokku@c.iphoting.cc:3022/pwqgen`
- Uses `SSH_PRIVATE_KEY` secret
- Force-push; in-progress runs cancelled by concurrency control

---

## Dependency Management

Gem versions are locked in `Gemfile.lock`. To update:

```bash
bundle update
```

Then commit both `Gemfile.lock` and (if changed) `.ruby-version`.

When bumping the Ruby version:
1. Update `.ruby-version`
2. Update `RUBY VERSION` in `Gemfile.lock`
3. Update `BUNDLED WITH` in `Gemfile.lock` to match the bundler shipped with that Ruby
4. Update `FROM ruby:X.Y.Z-alpine` in `Dockerfile` (both stages)
5. Run `bundle install` to verify no gem incompatibilities

**Known incompatibility:** `iodine ~> 0.7` does not compile against Ruby 3.4.
Production server was switched to `puma` (already used in development).

---

## Code Conventions

### Commit Messages

Follow **Conventional Commits** style:

```
<type>: <short description>

Types: feat, fix, chore, ci, docs, refactor
Examples: chore(deps): bump sinatra to 4.2, ci: increase smoke-test timeout
```

---

## Deployment

| Target | Trigger | Method |
|---|---|---|
| Dokku (primary) | Push to `master` branch | `dokku.yml` GitHub Action force-push |

Required env vars on Dokku (see `app.json`):
- `RACK_ENV` — set to `production` to enable SSL enforcement and HSTS
- `APP_ENV` — application environment identifier
- `LANG`, `PATH`, `GEM_PATH` — runtime environment

The `Procfile` runs Puma: `web: bundle exec puma -p ${PORT}`.
Dokku sets `$PORT` automatically.
