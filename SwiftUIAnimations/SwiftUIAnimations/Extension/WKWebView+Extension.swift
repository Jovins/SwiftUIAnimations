extension WKWebView {
    @objc func setupUserAgentInUserDefaults(shouldSetUserAgent: Bool = true, success: @escaping () -> Void) {
        guard shouldSetUserAgent,
              self.customUserAgent == nil || self.customUserAgent == "" else {
            success()
            return
        }
        if let userAgentString = UserDefaults.standard.string(forKey: "UserAgent") {
            self.customUserAgent = userAgentString
            success()
            return
        }
        evaluateJavaScript("navigator.userAgent") { [weak self] (any, _) in
            guard let result = any else { return }
            var baseUserAgent = String(describing: result)
            if UIDevice.current.model == "iPad" {
                baseUserAgent = baseUserAgent.replacingOccurrences(of: "iPhone", with: "iPad")
            }
            let userAgentString = baseUserAgent + ";XOXO/TheBumpApp"
            let dictionary = ["UserAgent": userAgentString]
            UserDefaults.standard.register(defaults: dictionary)
            self?.customUserAgent = userAgentString
            success()
        }
    }
}
