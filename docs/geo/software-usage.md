# 软件使用说明

GEOAmplify 的日常使用分两层：

- **GUI**：浏览器后台，用来配置模型、素材、品牌资料、查看草稿、审核发布和确认数据沉淀。
- **CLI**：本地软件、Codex、脚本或其他程序调用，用来自动跑选题、搜索、草稿、发布包和公众号草稿提交。

## 1. 启动本地服务

先在项目根目录启动 GUI：

```bash
php artisan serve --host=127.0.0.1 --port=8080
```

打开后台：

```text
http://127.0.0.1:8080/geo_admin/login
```

如果需要异步任务，另开终端启动：

```bash
php artisan queue:work redis --queue=geoamplify,default --sleep=1 --tries=1 --timeout=300
php artisan schedule:work
```

## 2. 登录后台

默认后台账号来自 `.env`：

```env
GEOAMPLIFY_ADMIN_USERNAME=admin
GEOAMPLIFY_ADMIN_PASSWORD=password
```

第一次进入后台后，应先修改默认密码。

登录后进入本地后台仪表盘，可以看到 GEO 工作台、AI 检视、内容资产和数据概览：

![GEOAmplify 本地后台仪表盘](screenshots/geoamplify-local-dashboard.png)

## 3. 配置 AI 模型

进入后台 `模型 / AI配置器`：

1. 添加至少一个 chat 模型，用于内容生成、诊断、标题和正文生产。
2. 如果需要知识库 RAG，再添加 embedding 模型。
3. 保存后点击模型测试，确认 API Base URL、模型 ID 和 API Key 可用。

模型 API Key 保存在本项目数据库中，并通过 Laravel `APP_KEY` 加密。修改 `APP_KEY` 会影响已保存密钥的解密。

## 4. 登录真实搜索账号

真实 AI 搜索依赖本机多平台 AI 网页工作台。只要你选择了这些平台代码：

```text
ai_web_workbench:chatgpt
ai_web_workbench:yuanbao
ai_web_workbench:<其他平台>
```

就必须先在本机登录自己的平台账号。GEOAmplify 不提供公共账号，也不会绕过登录、验证码、付费墙或平台风控。

推荐操作：

1. 在 `.env` 配置网页工作台命令：

   ```env
   GEOAMPLIFY_AI_WEB_WORKBENCH_COMMAND=/absolute/path/to/ai-web-workbench
   GEOAMPLIFY_AI_WEB_WORKBENCH_DATA_DIR=/absolute/path/to/workbench-data
   GEOAMPLIFY_AI_WEB_WORKBENCH_TIMEOUT=420
   GEOAMPLIFY_AI_WEB_WORKBENCH_LOGIN_CHECK_TIMEOUT=90
   ```

2. 进入后台 `GEO获客` 或 `AI问答 / 网页工作台`。
3. 在真实搜索平台区域点击 `打开登录`。
4. 在打开的网页里登录你自己的 ChatGPT、元宝或其他平台账号。
5. 回到后台点击 `一键检查登录状态`。
6. 只有显示已登录的平台，才建议用于真实 AI 搜索。

检视任务中的平台登录状态检查示例：

![GEOAmplify 检视平台登录状态检查](screenshots/geoamplify-search-login-check.png)

网页工作台中的平台监视示例：

![GEOAmplify 网页工作台平台登录状态](screenshots/geoamplify-web-workbench-login-status.png)

也可以用 CLI 查看工作台状态：

```bash
bin/geoamplify-cli web-workbench-status --json='{"limit": 5}' --pretty
```

如果平台未登录，真实搜索可能返回失败、空回答、验证码阻塞或超时。这不是系统 bug，需要先恢复对应平台账号登录状态。

## 5. 配置品牌和素材

进入 `GEO获客`：

1. 填写品牌名、别名、业务、服务区域、核心优势、真实案例和补充事实。
2. 进入素材库，补充知识库、标题库、关键词库、图片库和作者。
3. 知识库优先使用真实、可核验资料。

素材越完整，后续搜索、仿写、草稿和发布包越稳定。

## 6. 运行搜索与检视

后台有两种常见方式：

- `外部问答检视`：人工设置问题矩阵，检查 AI 回答里的品牌命中、竞品、推荐和引用来源。
- `机会搜索 / 选题链路`：从选题或机会词生成搜索问题、采集引用来源，再生成文章草稿和发布包。

平台选择规则：

| 平台类型 | 是否需要登录 | 说明 |
|---|---|---|
| Mock 平台 | 否 | 只用于流程验收，不代表真实搜索结果 |
| 后台 AI 模型 `ai_model:*` | 否 | 使用后台保存的 API Key 调模型 |
| 网页工作台 `ai_web_workbench:*` | 是 | 必须先登录自己的网页平台账号 |

## 7. 用 CLI 跑完整链路

从选题生成草稿、配图位和发布包：

```bash
bin/geoamplify-cli topic-pipeline --admin=admin --json='{
  "topic": "重庆涪陵全屋定制板材环保等级怎么选",
  "platform_codes": ["ai_web_workbench:chatgpt", "ai_web_workbench:yuanbao"],
  "max_references": 2
}' --pretty
```

注意：上面的 `chatgpt` 和 `yuanbao` 是真实网页平台，运行前必须先登录自己的账号。如果暂时没有登录，可以先换成 Mock 平台或后台 AI 模型做流程验收。

本地软件、Codex 或脚本调用 CLI 时会得到稳定 JSON：

![GEOAmplify CLI status 输出](screenshots/geoamplify-cli-status.png)

## 8. 查看草稿和数据沉淀

CLI 成功后会返回：

- `draft.id`
- `draft.title`
- `edit_url`
- `publish_package.manifest_path`
- `publish_package.image_count`
- `references_count`

打开 `edit_url` 可以在 GUI 里看到：

- 正文 Markdown
- 正文预览
- 引用来源
- 配图与发布包
- 微信公众号草稿提交状态
- 发布 SOP

这些数据会沉淀在数据库和本地发布包目录中。

完整链路中的草稿、发布包和发布状态示例：

![GEOAmplify 草稿与发布状态](screenshots/geoamplify-cli-gui-draft-19.png)

## 9. 提交微信公众号草稿

公众号草稿提交走蚁小二，需要先配置：

```env
YIXIAOER_API_KEY=
YIXIAOER_API_URL=https://www.yixiaoer.cn/api
```

同时，目标公众号账号必须在蚁小二中保持已登录、已授权、`status=1`。

提交草稿：

```bash
bin/geoamplify-cli submit-wxmp-draft --json='{
  "draft_id": 19,
  "platform_codes": ["weixingongzhonghao"]
}' --pretty
```

该动作只提交微信公众号草稿，不会群发。

## 10. 常见问题

### 真实搜索没有结果

先检查：

```bash
bin/geoamplify-cli web-workbench-status --json='{"limit": 5}' --pretty
```

如果平台未登录，先在 GUI 里点击 `打开登录`，使用自己的账号登录，再点击 `一键检查登录状态`。

### CLI 能运行，但后台看不到新数据

检查 CLI 是否在正确项目根目录运行。推荐从仓库根目录执行，或使用绝对路径：

```bash
/absolute/path/to/GEOAmplify/bin/geoamplify-cli status --pretty
```

### 改了 `.env` 但不生效

执行：

```bash
php artisan config:clear
php artisan cache:clear
```

### 发布到公众号失败

先确认：

- `YIXIAOER_API_KEY` 已配置。
- 蚁小二中目标公众号账号已登录并授权。
- 账号状态为 `status=1`。
- 发布包已经导出，图片素材路径存在。
