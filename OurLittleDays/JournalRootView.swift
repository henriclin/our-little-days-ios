import SwiftUI
import WebKit

struct JournalRootView: View {
    @AppStorage("journal.serverURL") private var savedURL = ""
    @State private var showsConnection = false
    private var endpoint: URL? { JournalAddress.parse(savedURL) }

    var body: some View {
        Group {
            if let endpoint {
                JournalBrowser(endpoint: endpoint, showsConnection: $showsConnection)
                    .id(endpoint.absoluteString)
            } else {
                ConnectionView(savedURL: $savedURL, canDismiss: false)
            }
        }
        .tint(Color(red: 0.23, green: 0.30, blue: 0.24))
        .sheet(isPresented: $showsConnection) {
            ConnectionView(savedURL: $savedURL, canDismiss: true)
        }
    }
}

enum JournalAddress {
    static func parse(_ text: String) -> URL? {
        guard var components = URLComponents(string: text.trimmingCharacters(in: .whitespacesAndNewlines)),
              let host = components.host?.lowercased(),
              components.user == nil, components.password == nil else { return nil }
        let parts = host.split(separator: ".").compactMap { Int($0) }
        let privateIP = parts.count == 4 && parts.allSatisfy { (0...255).contains($0) } &&
            (parts[0] == 10 || parts[0] == 127 ||
             (parts[0] == 192 && parts[1] == 168) ||
             (parts[0] == 172 && (16...31).contains(parts[1])))
        let localHost = host == "localhost" || host == "::1" || host.hasSuffix(".local") || privateIP
        guard components.scheme == "https" || (components.scheme == "http" && localHost) else { return nil }
        guard components.query == nil, components.fragment == nil,
              components.path.isEmpty || components.path == "/" else { return nil }
        components.path = "/"
        return components.url
    }
}

struct ConnectionView: View {
    @Binding var savedURL: String
    let canDismiss: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var draft = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("我们的小日子").font(.system(size: 28, design: .serif))
                        Text("连接属于你们的回忆空间。")
                            .foregroundStyle(.secondary)
                    }.padding(.vertical, 14)
                    TextField("https://你的网址", text: $draft)
                        .keyboardType(.URL).textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .accessibilityLabel("网站服务器地址")
                } footer: {
                    Text("输入网站的完整地址。外网使用 HTTPS；同一 Wi-Fi 调试时，可填电脑的局域网地址和端口。")
                }
                Section {
                    Button("连接空间") {
                        guard let url = JournalAddress.parse(draft) else { return }
                        savedURL = url.absoluteString
                        dismiss()
                    }.disabled(JournalAddress.parse(draft) == nil)
                }
                Section {
                    Text("照片和登录由你现有的网站服务提供。此版本支持在线浏览；离线相册和 Face ID 登录尚未启用。")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
            .navigationTitle(canDismiss ? "连接设置" : "欢迎")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if canDismiss { ToolbarItem(placement: .cancellationAction) { Button("取消") { dismiss() } } }
            }
            .onAppear { draft = savedURL }
        }
    }
}

struct JournalBrowser: View {
    let endpoint: URL
    @Binding var showsConnection: Bool
    @StateObject private var browser = JournalBrowserModel()

    var body: some View {
        VStack(spacing: 0) {
            if browser.isLoading { ProgressView().padding(6).accessibilityLabel("正在打开回忆") }
            ZStack {
                JournalWebView(browser: browser)
                if let error = browser.errorMessage {
                    VStack(spacing: 18) {
                        Image(systemName: "wifi.exclamationmark").font(.largeTitle)
                        Text("暂时连不上你们的空间").font(.headline)
                        Text(error).font(.footnote).foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        Button("重新连接") { browser.open(endpoint) }.buttonStyle(.borderedProminent)
                        Button("修改连接地址") { showsConnection = true }
                    }.padding(28).frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(red: 0.96, green: 0.95, blue: 0.92))
                }
            }
            HStack(spacing: 30) {
                Button { browser.webView.goBack() } label: { Image(systemName: "chevron.left").frame(width: 44, height: 44) }
                    .disabled(!browser.canGoBack).accessibilityLabel("返回")
                Button { browser.webView.goForward() } label: { Image(systemName: "chevron.right").frame(width: 44, height: 44) }
                    .disabled(!browser.canGoForward).accessibilityLabel("前进")
                Spacer(minLength: 0)
                Button { browser.open(endpoint) } label: { Image(systemName: "arrow.clockwise").frame(width: 44, height: 44) }
                    .accessibilityLabel("重新载入")
                Button { showsConnection = true } label: { Image(systemName: "gearshape").frame(width: 44, height: 44) }
                    .accessibilityLabel("连接设置")
            }
            .padding(.horizontal, 10)
            .background(Color(red: 0.96, green: 0.95, blue: 0.92))
        }
        .background(Color(red: 0.96, green: 0.95, blue: 0.92))
        .task { browser.open(endpoint) }
    }
}

