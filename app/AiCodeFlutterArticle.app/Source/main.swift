import UIKit
import WebKit

// Minimal WKWebView host. Loads the packaged VitePress page from Web/index.html.
// Compiled on macOS (see build_and_sign.sh) into the CFBundleExecutable Mach-O.
final class RootViewController: UIViewController {
    private lazy var webView: WKWebView = {
        let w = WKWebView(frame: view.bounds)
        w.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        w.allowsBackForwardNavigationGestures = true
        w.isOpaque = false
        return w
    }()

    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webView)
        guard let index = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "Web") else { return }
        // Allow the web view to read every resource under the app bundle (assets, fonts, chunks).
        webView.loadFileURL(index, allowingReadAccessTo: Bundle.main.bundleURL)
    }
}

final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = RootViewController()
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}

let app = UIApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, NSStringFromClass(type(of: delegate)))
