import UIKit
import WebKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let w = UIWindow(frame: UIScreen.main.bounds)
        w.rootViewController = GameViewController()
        w.makeKeyAndVisible()
        window = w
        return true
    }
}

final class GameViewController: UIViewController, WKScriptMessageHandler {
    private var web: WKWebView!
    private let saveKey = "neondash1"

    override var prefersStatusBarHidden: Bool { true }
    override var prefersHomeIndicatorAutoHidden: Bool { true }
    override var shouldAutorotate: Bool { true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .landscape }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.02, green: 0.02, blue: 0.06, alpha: 1)

        // Сохранение хранится в UserDefaults и отдаётся игре при запуске
        let saved = UserDefaults.standard.string(forKey: saveKey) ?? ""
        var literal = "[\"\"]"
        if let data = try? JSONSerialization.data(withJSONObject: [saved], options: []),
           let str = String(data: data, encoding: .utf8) {
            literal = str
        }
        let ucc = WKUserContentController()
        ucc.addUserScript(WKUserScript(source: "window.__nd = (\(literal))[0];",
                                       injectionTime: .atDocumentStart,
                                       forMainFrameOnly: true))
        ucc.add(self, name: "nd")

        let cfg = WKWebViewConfiguration()
        cfg.userContentController = ucc
        cfg.mediaTypesRequiringUserActionForPlayback = []

        web = WKWebView(frame: .zero, configuration: cfg)
        web.translatesAutoresizingMaskIntoConstraints = false
        web.isOpaque = false
        web.backgroundColor = view.backgroundColor
        web.scrollView.backgroundColor = view.backgroundColor
        web.scrollView.isScrollEnabled = false
        web.scrollView.bounces = false
        web.scrollView.contentInsetAdjustmentBehavior = .never
        view.addSubview(web)
        NSLayoutConstraint.activate([
            web.topAnchor.constraint(equalTo: view.topAnchor),
            web.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            web.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            web.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])

        if let url = Bundle.main.url(forResource: "index", withExtension: "html") {
            web.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
    }

    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        if let s = message.body as? String {
            UserDefaults.standard.set(s, forKey: saveKey)
        }
    }
}
