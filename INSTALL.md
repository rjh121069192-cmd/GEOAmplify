# GEOAmplify 本地安装说明

> 仓库不会提交真实 `.env` 文件，因为 `.env` 里会放数据库密码、模型 API Key、发布平台密钥等本机私密配置。请先从 `.env.example` 复制出自己的 `.env`。

## 1. 准备本机环境

必须安装：

| 组件 | 要求 |
|---|---|
| PHP | 8.2+ |
| Composer | 2.x |
| PostgreSQL | 13+，建议本机可访问 |
| PHP 扩展 | `pdo_pgsql`、`mbstring`、`openssl`、`fileinfo`、`tokenizer`、`xml`、`ctype`、`json` |

可选安装：

| 组件 | 用途 |
|---|---|
| Redis | 队列、缓存和批量任务；没有 Redis 时可先用同步队列 |
| Node.js / npm | 需要重新构建前端资源时使用 |

## 2. 创建 `.env`

方式一：直接复制。

```bash
cp .env.example .env
```

方式二：使用项目脚本。

```bash
bash scripts/setup-local-env.sh
```

复制后至少检查这些配置：

```env
APP_ENV=local
APP_DEBUG=true
APP_URL=http://127.0.0.1:8080
ADMIN_BASE_PATH=geo_admin

DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=geo_amplify
DB_USERNAME=geo_user
DB_PASSWORD=geo_password

QUEUE_CONNECTION=redis
REDIS_HOST=127.0.0.1
REDIS_PORT=6379

GEOAMPLIFY_ADMIN_USERNAME=admin
GEOAMPLIFY_ADMIN_PASSWORD=password
```

如果本机没有 Redis，先把队列改成同步模式：

```env
QUEUE_CONNECTION=sync
GEOAMPLIFY_GEO_ASYNC_JOBS=false
GEOAMPLIFY_TASK_REALTIME_ENABLED=false
```

## 3. 准备 PostgreSQL 数据库

如果你使用默认 `.env.example`，需要创建数据库和用户：

```sql
CREATE USER geo_user WITH PASSWORD 'geo_password';
CREATE DATABASE geo_amplify OWNER geo_user;
```

已有数据库也可以，按实际值修改 `.env` 里的 `DB_DATABASE`、`DB_USERNAME` 和 `DB_PASSWORD`。

## 4. 安装依赖并初始化

```bash
composer install --no-interaction --prefer-dist
php artisan key:generate
php artisan migrate --force
php artisan db:seed --force
php artisan storage:link
```

如果需要重新构建前端资源：

```bash
npm install
npm run build
```

## 5. 启动本地 GUI

```bash
php artisan serve --host=127.0.0.1 --port=8080
```

打开：

- 前台：`http://127.0.0.1:8080`
- 后台：`http://127.0.0.1:8080/geo_admin/login`

默认后台账号来自 `.env`：

```text
用户名：admin
密码：password
```

第一次登录后请立即修改默认密码。

## 6. 验证 CLI

本地软件、Codex 或其他程序从项目根目录调用：

```bash
bin/geoamplify-cli status --pretty
bin/geoamplify-cli schema --pretty
```

看到 JSON 里 `ok: true` 表示 CLI 可用。

## 7. 真实 AI 搜索账号

如果使用这些平台：

```text
ai_web_workbench:chatgpt
ai_web_workbench:yuanbao
ai_web_workbench:<其他平台>
```

必须先在本机网页工作台里登录自己的平台账号。GEOAmplify 不提供公共账号，也不会绕过登录、验证码、付费墙或平台风控。

相关配置：

```env
GEOAMPLIFY_AI_WEB_WORKBENCH_COMMAND=/absolute/path/to/ai-web-workbench
GEOAMPLIFY_AI_WEB_WORKBENCH_DATA_DIR=/absolute/path/to/workbench-data
GEOAMPLIFY_AI_WEB_WORKBENCH_TIMEOUT=420
GEOAMPLIFY_AI_WEB_WORKBENCH_LOGIN_CHECK_TIMEOUT=90
```

## 8. 常见问题

### 找不到 `.env`

这是正常的。公开仓库只提交 `.env.example`，请执行：

```bash
cp .env.example .env
php artisan key:generate
```

### 数据库连不上

检查 PostgreSQL 是否启动，并确认 `.env` 中这些值和本机一致：

```env
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=geo_amplify
DB_USERNAME=geo_user
DB_PASSWORD=geo_password
```

### 没有 Redis

先用同步队列跑通流程：

```env
QUEUE_CONNECTION=sync
```

### 修改 `.env` 不生效

清理配置缓存：

```bash
php artisan config:clear
php artisan cache:clear
```
