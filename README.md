# KmiGithub

基于 GitHub REST API 的 iOS 客户端示例项目，使用 **SwiftUI**、**Redux** 与 **MVVM** 组合架构。

## 功能概览

| 功能 | 说明 |
|------|------|
| 登录 | GitHub OAuth（`ASWebAuthenticationSession`），Token 存 Keychain |
| 生物识别 | 已保存 Token 时可用 Face ID / Touch ID 快速登录 |
| 游客模式 | 可跳过登录浏览首页与搜索（受 API 未认证限流影响） |
| 首页 | 热门仓库列表（搜索 API 模拟），分页加载 |
| 搜索 | 关键词搜索仓库，防抖 + 分页 |
| 个人 | 登录后展示资料与仓库列表，支持退出登录 |
| 错误提示 | 全局错误浮层 + 页面内联重试 |
| 主题 | 浅色 / 深色 / 跟随系统，写入 `UserDefaults` |
| 本地化 | 文案走 `Localizable.strings`（含简体中文） |

## 技术实现

- **UI**：SwiftUI，`NavigationView` + `TabView`，自定义组件（头像 `Kingfisher`、语言标签等）。
- **全局状态（Redux）**：`AppState`（认证、用户、错误、主题）→ `AppAction` → `appReducer` + 各子 Reducer；`AppStore` 为 `ObservableObject`，通过 `environmentObject` 注入。
- **副作用**：`AuthMiddleware` 在登录成功后写 Keychain、更新 `GitHubService` Token、拉取 `/user`。
- **MVVM**：各 Tab 使用独立 `ViewModel`（列表状态、分页、网络请求），与 Redux 分工：全局用 Store，页面局部用 `@Published`。
- **网络**：Moya + 现有 `NetworkManager`；`GitHubAPITarget` 定义接口；`endpointClosure` 注入 `Authorization: Bearer <token>`（OAuth 换 Token 请求不带 Bearer）。

## 依赖

- [Moya](https://github.com/Moya/Moya)（含 CombineMoya）
- [Kingfisher](https://github.com/onevcat/Kingfisher)

系统框架：`AuthenticationServices`、`LocalAuthentication`、`Security`（Keychain）。

## 配置与运行

1. 在 [GitHub Developer Settings](https://github.com/settings/developers) 创建 **OAuth App**：
   - **Authorization callback URL**：与 `AppConstants.oauthCallbackURL` 一致（默认 `kmigithub://oauth/callback`）
   - 将 **Client ID**、**Client Secret** 填入 `KmiGithub/App/AppConstants.swift`（勿将真实密钥提交到公开仓库）。
2. 确认 `Info.plist` 中已配置 URL Scheme（与 `oauthCallbackScheme` 一致）及 Face ID 使用说明（若使用生物识别）。
3. 使用 Xcode 打开 `KmiGithub.xcodeproj`，选择模拟器或真机运行。

**最低系统版本**：iOS 14.0（工程内以 Xcode 目标为准）。

## 目录结构（简要）

```
KmiGithub/
├── App/                 # 入口、常量、AppDelegate
├── Redux/               # State、Action、Store、Reducers、Middleware
├── Models/              # GitHubUser、Repository、SearchResult 等
├── Services/            # GitHub API、OAuth、Keychain、生物识别
├── ViewModels/
├── Views/               # Tab、各页、Common（含 ThemeSelectorView）
├── Network/             # 通用 Moya + Combine 封装
└── Resources/           # zh-Hans / en Localizable.strings
```

## 测试

单元测试位于 `KmiGithubTests/`（Reducer、Store、模型解码等），在 Xcode 中运行 **KmiGithub** Scheme 的 Test 即可。

---

*作业/演示用途：请自行替换 OAuth 密钥并注意不要在公开仓库泄露 Client Secret。*
