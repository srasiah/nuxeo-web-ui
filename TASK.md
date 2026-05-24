# Taskfile Reference

Run any task with `task <name>`. List all tasks with `task` (or `task --list`).

## Configuration

Tasks read configuration from `.env` (and `.env.sample` as fallback). Copy `.env.sample` to `.env` and override as needed. All vars can also be overridden via shell environment or CLI (`VARNAME=value task <name>`).

| Variable | Default                                                     | Description |
|---|-------------------------------------------------------------|---|
| `NUXEO_WEB_UI_VERSION` | from `package.json`                                         | Web UI version |
| `NUXEO_VERSION` | `master`                                                    | Nuxeo server version |
| `NUXEO_PACKAGES` | drive, liveconnect, template-rendering                      | Extra Nuxeo packages |
| `NUXEO_DEV_MODE` | `true`                                                      | Enable dev mode |
| `NUXEO_PLUGIN_WEBUI_FILE_PATH` | `./plugin/web-ui/marketplace/target/*.zip`                  | Built marketplace zip source |
| `NUXEO_BENCHMARK_MARKETPLACE_PATH` | `~/your-projects/nuxeo/docker/nuxeo-benchmark/marketplace/` | Benchmark marketplace destination |
| `MAVEN_VERSION` | `current`                                                   | sdkman Maven version |
| `JAVA_VERSION` | `current`                                                   | sdkman Java version |
| `MAVEN_OPTS` | `-Xmx2g -Xms512m`                                           | Maven JVM options |

---

## Tasks

### Installation

| Task | Description |
|---|---|
| `task install` | Install npm dependencies |
| `task check-node` | Verify Node.js is installed and print version |

### Development

| Task | Description |
|---|---|
| `task start` | Start development server (`npm run start`) |
| `task start-build` | Serve built files via HTTP server |

### Build

| Task | Description |
|---|---|
| `task prepare` | Prepare build environment (i18n, workbox) |
| `task build` | Production build |
| `task build-analyze` | Production build with bundle size analysis |

### Testing

| Task | Description |
|---|---|
| `task test` | Run unit tests |
| `task test-watch` | Run unit tests in watch mode |
| `task ftest` | Run functional tests (headless) |
| `task ftest-headful` | Run functional tests in headful mode |
| `task ftest-dev` | Run functional tests against local dev server |
| `task ftest-watch` | Run functional tests in watch/debug mode |

### Lint & Format

| Task | Description |
|---|---|
| `task lint` | Run ESLint + Prettier checks |
| `task lint-eslint` | Run ESLint only |
| `task lint-prettier` | Run Prettier check only |
| `task format` | Auto-fix with Prettier and ESLint |
| `task format-eslint` | Auto-fix with ESLint |
| `task format-prettier` | Auto-fix with Prettier |

### Clean

| Task | Description |
|---|---|
| `task clean` | Remove `dist/`, `.tmp/`, `node_modules/`, `target/` |
| `task clean-dist` | Remove `dist/` only |
| `task clean-tmp` | Remove `.tmp/` only |

### Maven

| Task | Description |
|---|---|
| `task mvn-clean` | `mvn clean` |
| `task mvn-install` | `mvn clean install` — build marketplace zip |
| `task mvn-install-ftest` | Build marketplace zip with functional tests (`-Pftest`) |
| `task mvn-install-skip` | Build marketplace zip, skip tests (`-DskipTests`) |

### Deploy

| Task | Description |
|---|---|
| `task copy-to-benchmark` | Copy built marketplace zip (`NUXEO_PLUGIN_WEBUI_FILE_PATH`) to local benchmark directory (`NUXEO_BENCHMARK_MARKETPLACE_PATH`) |

### Docker

| Task | Description |
|---|---|
| `task docker-build` | Build Docker image |
| `task docker-up` | Start Docker Compose services |
| `task docker-up-build` | Build and start Docker Compose services |
| `task docker-up-detached` | Start Docker Compose services in detached mode |
| `task docker-down` | Stop Docker Compose services |
| `task docker-logs` | Tail Docker Compose logs |
| `task docker-clean` | Remove containers, volumes, and images |

### Combined

| Task | Description |
|---|---|
| `task all` | Clean → install → build |
| `task full-build` | install → build → `mvn-install` |
| `task dev` | install → start dev server |
| `task ci` | install → lint → test → build |

### Info

| Task | Description |
|---|---|
| `task info` | Print resolved build configuration (versions, paths, options) |