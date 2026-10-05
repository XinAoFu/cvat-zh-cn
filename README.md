# CVAT 中文版（zh-CN + Apple Silicon / arm64 原生）

基于 [CVAT](https://github.com/cvat-ai/cvat) **v2.77.0** 的社区分支，提供两件官方没有的东西：

1. **界面中文化**——基于 i18next 的完整 i18n 架构（非硬编码替换），内置中/英切换，可扩展任意语言
2. **arm64（aarch64）原生镜像**——Apple Silicon（M 系列Mac）与 arm 服务器无需 Rosetta 转译，直接原生运行

> ⚠️ 本项目为**非官方社区分支**，基于 v2.77.0 快照维护，与 CVAT.ai 官方无关联。

## 功能亮点

| 能力 | 说明 |
|---|---|
| i18n 架构 | i18next + react-i18next，三命名空间（base/auth/header），语言探测 + 手动切换（顶栏按钮） |
| 中文覆盖 | 登录/注册、顶部导航、任务列表页（含 Actions 菜单）、任务详情页（Jobs 表/Issue Tracker）、标注页（主菜单/播放器/外观面板/对象侧栏）、72 个快捷键名称、日期本地化（dayjs zh-cn） |
| arm64 原生 | `Dockerfile.ui` 与 `Dockerfile` 均可在 arm64 机器本地构建（FFmpeg/OpenH264 从源码编译为 arm64） |
| 一键部署 | 附带裁剪版 compose（去除了可选 analytics 组件，更省资源） |

## 快速开始

### 方式一：自行构建（约 1 小时，Apple Silicon 实测通过）

```bash
git clone https://github.com/<你的用户名>/cvat-zh-cn.git
cd cvat-zh-cn

# 1) 下载构建源码包（openh264/ffmpeg/smokescreen/datumaro，约 85MB；国内自动走镜像）
bash scripts/fetch-sources.sh

# 2) 构建镜像
docker build -f Dockerfile.ui -t cvat/ui:zh-cn .
docker build -f Dockerfile -t cvat/server:zh-cn .

# 3) 启动
docker compose -f docker-compose.zh-cn.yml up -d
```

打开 http://localhost:8080 ，首次使用在页面注册账号即可。

**构建要求**：Docker Desktop 内存 ≥ 10GB（默认 8GB 会在 webpack/编译阶段 OOM）；磁盘 ~10GB。

### 方式二：直接拉取镜像（发布到镜像库后可用）

```yaml
# docker-compose.zh-cn.yml 中的镜像名替换为：
# image: <registry>/cvat-ui:zh-cn-arm64
# image: <registry>/cvat-server:zh-cn-arm64
```

## 补充/修改中文词条

词条文件位于 `cvat-ui/src/i18n/locales/<命名空间>/<语言>.json`（en 与 zh-CN 同键对照）。补充后重建 UI 镜像生效：

```bash
docker build -f Dockerfile.ui -t cvat/ui:zh-cn .
docker compose -f docker-compose.zh-cn.yml up -d cvat_ui
```

给新组件接入 i18n 的标准姿势：

```tsx
import { useTranslation } from 'react-i18next';
// 函数组件内：
const { t } = useTranslation('base');
<Text>{t('Create new task')}</Text>
// class 组件用 withTranslation() HOC；非组件函数用 i18n.t('xxx')
```

## 与官方版本的差异

- 新增 `cvat-ui/src/i18n/`（i18next 初始化、词典、语言切换组件）与 30+ 组件的 t() 接入
- `Dockerfile`：FFmpeg 版本 8.0 → 8.1.2（源码取自 Debian 官方源）；四个源码包改为本地 `COPY`（由 `scripts/fetch-sources.sh` 预下载）；Go 模块走 goproxy.cn
- `docker-compose.zh-cn.yml`：移除 clickhouse/vector/grafana（analytics 可选组件）与 quality-reports worker，`CVAT_ANALYTICS: 0`
- 未合入官方 v2.78+ 的后续改动（快照式维护）

## 已知限制

- 少量深层界面文案（部分通知、错误详情）仍为英文，遇到就补词条
- 后端 Django 的少量校验错误消息为英文
- 3D 点云标注的 cuboid 坐标系与官方一致，第三方工具兼容

## 致谢

- [CVAT.ai / Intel](https://github.com/cvat-ai/cvat) —— 伟大的开源标注平台（MIT License）
- **[@acecode](https://github.com/acecode)** —— i18next 架构来自其社区 PR [#9197](https://github.com/cvat-ai/cvat/pull/9197)（该 PR 未被官方合并，本项目在其基础上移植到 v2.77.0 并扩展了覆盖范围）
- [Debian Project](https://www.debian.org) —— FFmpeg 原始源码包镜像

## 许可证

继承上游 [MIT License](LICENSE)。本项目的新增代码同样以 MIT 提供。
