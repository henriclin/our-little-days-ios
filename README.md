# 我们的小日子 · iPhone 工程（未签名）

这是 SwiftUI + WKWebView 的真正 iOS App 工程，以原生外壳承载现有网站界面，不是 PWA。目标 iOS 17+，建议 Xcode 16 或更新版本；无第三方依赖。

## 当前提供

- 原生连接设置、加载状态、网络错误重试、返回/前进。
- 浏览现有网站的全部界面、账号登录和照片。
- WebKit 持久网站数据；实际登录时长仍由网站决定（当前 8 小时，服务器重启失效）。
- 外网地址要求 HTTPS，局域网开发允许私有 IP HTTP。

当前尚未接入 Face ID、离线相册、上传、通知或正式 App 图标。安装 App 不会改变网站的联网范围。此工程未附带任何私人照片、密码或证书。

## Windows + 免费云编译（当前路线）

不需要自己持有 Mac。工程自带 `.github/workflows/build-ios.yml`，用 GitHub 的 macOS 环境编译不带签名的真机 IPA，再在 Windows 的 Sideloadly 中用自己的免费 Apple 账号签名安装。云端不需要 Apple 登录或证书。

只把本 `OurLittleDays` 文件夹中的 App 工程上传为独立仓库；不要上传父目录网站，也不要上传 `data`、照片、账号文件、密码或证书。标准 GitHub 托管运行器在公开仓库免费；私有仓库受账号免费额度约束，不能保证无限免费。可手动运行；main 分支的 App 代码或编译配置更新时也会自动运行。15 分钟超时，产物仅保留 1 天。

1. 建立独立 GitHub 仓库，把本目录内容放在仓库根目录，保留 `.github/workflows`。公开仓库会公开这份 App 源代码；当前工程不含私人照片、网站地址或账号。
2. 在 Actions 中选择 Build unsigned iPhone app，点击 Run workflow。
3. 构建成功后下载 Artifacts 下的 OurLittleDays-unsigned-iPhone，解压取得 IPA。
4. 从 https://sideloadly.io/ 安装 Windows 版 Sideloadly，按其官方指引准备 Apple 设备连接组件。
5. USB 连接并信任 iPhone，在 Sideloadly 导入 IPA，使用自己的免费 Apple 账号完成签名安装。Apple 登录在你自己的 Windows 工具内进行，不需要上传到 GitHub 或聊天。
6. 按 iPhone 提示开启 Developer Mode/信任开发者，打开 App，填写网站服务地址。
7. 免费签名约 7 天有效。可以开启 Sideloadly 的 Automatic Refresh；自动续签需要电脑、后台工具及手机连接条件满足，仍可能需要手动处理连接/登录失败。不是永久签名。

已在 GitHub 的 macOS 环境完成首次真机 Release 编译，Xcode 16.4 / iPhoneOS SDK 18.5，结果 BUILD SUCCEEDED。安装包为 arm64、最低 iOS 17 的未签名 IPA。尚未执行 Apple 签名或真机安装。

构建记录：https://github.com/henriclin/our-little-days-ios/actions/runs/40310953562

本次下载：https://github.com/henriclin/our-little-days-ios/actions/runs/40310953562/artifacts/12644866961

下载 ZIP 后解压，取得 OurLittleDays-unsigned.ipa，再导入 Sideloadly。产物过期后可重新运行 Actions 生成。

## 可借到 Mac 时：免费账号真机测试

1. 把此文件夹复制到 Mac，打开 OurLittleDays.xcodeproj。
2. Xcode → Settings → Accounts 添加你自己的 Apple Account。
3. Target → Signing & Capabilities 开启 Automatically manage signing，选择自己的 Team；必要时改成唯一的 Bundle Identifier。
4. 连接 iPhone，选择该设备，按 Run。按苹果提示开启 Developer Mode、信任设备。
5. App 中填网站地址，例如同一 Wi-Fi 下电脑终端显示的地址和端口。不要在手机中填 localhost，它指向手机本身。
6. 免费 Personal Team 签名有效期通常为 7 天，过期需要重新构建安装。

## TestFlight 私人测试（付费备选，当前不采用）

可以仅通过邮件邀请你们两个人测试，无需公开发布 App Store 正式版。需要付费 Apple Developer Program，并在 App Store Connect 上传签名构建。外部测试通常需要 TestFlight Beta App Review。

手机首次通过 TestFlight 安装后，可以开启自动更新，后续可覆盖更新而不用卸载重装。但每个构建从上传起最多可测试 90 天，需在到期前提供新的可用构建；自动更新本身不会延长旧构建的有效期。它是测试分发，不是永久免维护的私人发行。

当前已完成免费云端编译；没有执行苹果签名、TestFlight 审核或上传，也没有 TestFlight 邀请链接。App 图标和上传所需的元数据仍需在正式打包前补齐。

## Ad Hoc 私人安装（备选）

需要付费 Apple Developer Program、有效的分发证书、App ID、登记的设备 UDID 和 Ad Hoc provisioning profile。只登记你们要安装的 iPhone。证书/描述文件到期或设备变更时，需要更新签名和安装包。

在 Xcode 中先选 Any iOS Device，再 Product → Archive。随后在 Organizer 中选择 Distribute App，选择 Release Testing / Ad Hoc / registered devices 对应的分发方式（名称随 Xcode 版本不同），导出只包含登记设备的签名 IPA。可通过 Xcode 或 Apple Configurator 安装到登记设备。不要选择 App Store 上传分发。

不要把 Apple 密码、私钥或证书放入网站工程或聊天里；在自己的 Mac 上完成签名。

## 编译检查

在 Mac 执行：

    xcodebuild -project OurLittleDays.xcodeproj -scheme OurLittleDays -sdk iphonesimulator -configuration Debug CODE_SIGNING_ALLOWED=NO build

本地 Windows 环境没有 Xcode/iOS SDK；已通过 GitHub macOS 环境完成真机 Release 构建及打包，但尚未进行手机签名、安装和运行验证。未签名 IPA 无法直接在 iPhone 中点开安装。

## 后端现状

原 server.cjs 仍是局域网 HTTP 模式，没有被此工程修改。外网使用前需完成固定 HTTPS 地址、受信任域名/Origin 校验、代理配置、安全 Cookie 和持久会话适配。电脑关机或服务停止后，在线 App 无法读取回忆。

## 苹果官方资料

- https://developer.apple.com/help/account/devices/devices-overview/
- https://developer.apple.com/help/account/provisioning-profiles/create-an-ad-hoc-provisioning-profile/
- https://developer.apple.com/help/account/basics/about-your-developer-account/

