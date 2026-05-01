import WebKit
import Foundation

class WebFetcher: NSObject, WKNavigationDelegate {
    static let shared = WebFetcher()

    private var webView: WKWebView!
    private var isReady = false
    private var isBusy = false
    private var taskQueue: [(orgId: String, cookieString: String, completion: (Result<Data, Error>) -> Void)] = []

    private override init() {
        super.init()
        DispatchQueue.main.async { self.setup() }
    }

    private func setup() {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .nonPersistent()
        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
    }

    // MARK: - Public

    private let maxQueueSize = 20

    func fetch(orgId: String, cookieString: String, completion: @escaping (Result<Data, Error>) -> Void) {
        DispatchQueue.main.async {
            guard self.taskQueue.count < self.maxQueueSize else {
                completion(.failure(NSError(domain: "WebFetcher", code: -2, userInfo: [NSLocalizedDescriptionKey: "Queue full"])))
                return
            }
            self.taskQueue.append((orgId, cookieString, completion))
            self.drainQueue()
        }
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let host = webView.url?.host, host.contains("claude.ai") else { return }
        isReady = true
        drainQueue()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        if !isReady {
            isReady = true
            drainQueue()
        }
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if !isReady {
            isReady = true
            drainQueue()
        }
    }

    // MARK: - Queue

    private func drainQueue() {
        guard !isBusy, !taskQueue.isEmpty else { return }
        isBusy = true
        let task = taskQueue.removeFirst()
        executeTask(task)
    }

    private func executeTask(_ task: (orgId: String, cookieString: String, completion: (Result<Data, Error>) -> Void)) {
        injectCookies(task.cookieString) {
            if self.isReady {
                self.performFetch(orgId: task.orgId, completion: task.completion)
            } else {
                // Navigate to claude.ai first, then fetch on didFinish
                self.taskQueue.insert(task, at: 0)
                self.isBusy = false
                self.isReady = false
                self.webView.load(URLRequest(url: URL(string: "https://claude.ai")!))
            }
        }
    }

    private func injectCookies(_ cookieString: String, completion: @escaping () -> Void) {
        let store = webView.configuration.websiteDataStore.httpCookieStore
        store.getAllCookies { existing in
            let group = DispatchGroup()
            for cookie in existing {
                group.enter()
                store.delete(cookie) { group.leave() }
            }
            group.notify(queue: .main) {
                let cookies: [HTTPCookie] = cookieString
                    .components(separatedBy: ";")
                    .compactMap { part in
                        let t = part.trimmingCharacters(in: .whitespaces)
                        let kv = t.components(separatedBy: "=")
                        guard kv.count >= 2 else { return nil }
                        let name = kv[0].trimmingCharacters(in: .whitespaces)
                        let value = kv.dropFirst().joined(separator: "=")
                        return HTTPCookie(properties: [
                            .name: name,
                            .value: value,
                            .domain: ".claude.ai",
                            .path: "/",
                            .secure: "TRUE"
                        ])
                    }
                let g2 = DispatchGroup()
                for cookie in cookies {
                    g2.enter()
                    store.setCookie(cookie) { g2.leave() }
                }
                g2.notify(queue: .main) { completion() }
            }
        }
    }

    private func performFetch(orgId: String, completion: @escaping (Result<Data, Error>) -> Void) {
        let js = """
        const r = await fetch('/api/organizations/\(orgId)/usage', {
            credentials: 'include',
            headers: {
                'accept': '*/*',
                'anthropic-client-platform': 'web_claude_ai',
                'anthropic-client-version': '1.0.0',
                'anthropic-client-sha': 'ec58f908c65bf1b6cd36aab8c717a3c78597ac3b',
                'sec-fetch-dest': 'empty',
                'sec-fetch-mode': 'cors',
                'sec-fetch-site': 'same-origin'
            }
        });
        const body = await r.text();
        return {status: r.status, body: body};
        """
        webView.callAsyncJavaScript(js, arguments: [:], in: nil, in: .page) { [weak self] result in
            guard let self else { return }
            defer {
                self.isBusy = false
                self.drainQueue()
            }
            switch result {
            case .success(let value):
                guard let dict = value as? [String: Any],
                      let status = dict["status"] as? Int,
                      let body = dict["body"] as? String else {
                    completion(.failure(NSError(domain: "WebFetcher", code: -1)))
                    return
                }
                if status == 200, let data = body.data(using: .utf8) {
                    completion(.success(data))
                } else {
                    completion(.failure(NSError(domain: "WebFetcher", code: status)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
