import UIKit
import WebKit

class NOSPluginExternalWebViewLogout: UIViewController, WKNavigationDelegate {
    
    var urlLoading : String?
    var pageTitle : String?
    var headers: String?
    
    var webView : WKWebView?
    var buttonBack, buttonForward: UIButton!
    var progressView: UIProgressView!
    
    
    let colorButtonsEnable = UIColor(red: CGFloat(26.0/255.0), green: CGFloat(26.0/255.0), blue: CGFloat(26.0/255.0), alpha: CGFloat(1.0))
    let colorButtonsDisable = UIColor(red: CGFloat(204.0/255.0), green: CGFloat(204.0/255.0), blue: CGFloat(204.0/255.0), alpha: CGFloat(1.0))
    var backgroundColor =  UIColor(red: CGFloat(110.0/255.0), green: CGFloat(165.0/255.0), blue: CGFloat(20.0/255.0), alpha: CGFloat(1.0))
    let backgroundWebViewColor = UIColor(red: CGFloat(51.0/255.0), green: CGFloat(51.0/255.0), blue: CGFloat(51.0/255.0), alpha: CGFloat(1.0))
    
    var toolBar = UIView()
    var bottomBar = UIView()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var defaults = UserDefaults()
    
    var scheme = "selfcare://"
    
    var delegate: NOSCordovaPluginInterface?
    var callbackId: String?
    
    var mainColor: String?
    var logging: Bool = false
    var returnURL: String?
    var buttonsAlignment: String?
    var showBottomBar: Bool = true
    
    var forceResetWebview: Bool = false
    
    var timeoutSecond: Double = 10.0;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.isOpaque = false
        
        if(logging == true){
            
            let alert = UIAlertController()
            alert.title = "DEBUG - Init WebView"
            
            let dismiss = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(dismiss)
            
            self.present(alert, animated: true, completion: nil)
        }
        
        print("Atmosphere viewDidLoad")
        
        if(mainColor != ""){
            backgroundColor = parseColor(hexString: mainColor ?? "");
        }
        //Set Navigation bar
        //UIApplication.shared.statusBarStyle = .lightContent
        //UINavigationBar.appearance().barStyle = .default
        //self.setNeedsStatusBarAppearanceUpdate()
        //self.navigationController?.navigationBar.tintColor = UIColor.white
        
        //view.backgroundColor = backgroundColor
        
        let url = URL(string: urlLoading ?? "")
        
        var request = URLRequest.init(url: url!)
        
        
        webView = WKWebView(frame: self.view.frame)
        
        var setUserAgent = false
        if let headers = headers {
            let headersList = headers.components(separatedBy: "!!!")
            
            if(headersList.count > 0){
                for header in headersList {
                    let headerText = header.split {$0 == ";"}
                    if(headerText.count > 1){
                        let headerName: String = String(headerText[0])
                        let headerValue: String = String(headerText[1])
                        
                        request.setValue(headerValue, forHTTPHeaderField: headerName)
                        
                        if(headerName.contains("UserAgent")){
                            
                            setUserAgent = true
                            webView?.evaluateJavaScript("navigator.userAgent") {
                                (result, error) in if error != nil {
                                    print("Error occured to get userAgent")
                                    self.webView?.load(request)
                                    
                                    return
                                }
                                var userAgent: String
                                userAgent = ""
                                if let unwrappedUserAgent = result as? String {
                                    userAgent=unwrappedUserAgent
                                } else {
                                    print("Failed to get userAgent")
                                }
                                
                                print(userAgent)
                                let originalUserAgent = userAgent + " " +  headerValue
                                print(originalUserAgent)
                                
                                self.defaults.register(defaults: ["UserAgent": originalUserAgent])
                                self.webView?.customUserAgent = headerValue
                                
                                self.checkIfResetIsRequired();
                                DispatchQueue.main.asyncAfter(deadline: .now() + self.timeoutSecond, execute: {
                                    self.forceLogout()
                                })
                                self.webView?.load(request)
                            }
                            
                        }
                    }
                }
            }
        }
        
        if let mainColor = mainColor {
            request.setValue(mainColor, forHTTPHeaderField: "X-NOS-Color")
        }
        
        if(!setUserAgent){
            checkIfResetIsRequired()
            DispatchQueue.main.asyncAfter(deadline: .now() + self.timeoutSecond, execute: {
                self.forceLogout()
            })
            webView?.load(request)
        }
        
        webView?.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil);
        webView?.navigationDelegate = self
        webView?.backgroundColor = backgroundWebViewColor
        
        //self.view.addSubview(webView!)
        
        /*
         webView?.translatesAutoresizingMaskIntoConstraints = false
         webView?.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
         webView?.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
         if(showBottomBar){
         webView?.bottomAnchor.constraint(equalTo: bottomBar.topAnchor).isActive = true
         }else{
         webView?.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
         }
         
         webView?.topAnchor.constraint(equalTo: toolBar.bottomAnchor).isActive = true
         */
        refreshButtonsState()
        
        /*
         
         let alert = UIAlertController(title: nil, message: "a terminar sessão...", preferredStyle: .alert)
         
         let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
         loadingIndicator.hidesWhenStopped = true
         loadingIndicator.style = UIActivityIndicatorView.Style.gray
         loadingIndicator.startAnimating();
         
         alert.view.addSubview(loadingIndicator)
         
         DispatchQueue.main.async {
         self.present(alert, animated: true, completion: nil)
         }
         */
    }
    
    func checkIfResetIsRequired(){
        if(forceResetWebview == false){
            return
        }
        
        let dataStore = WKWebsiteDataStore.default()
        dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), completionHandler: { (records) in for record in records{
            WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record],       completionHandler: {
                print("Clear success\(record)")
            })
            
            }
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("Atmosphere viewWillAppear")
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        refreshButtonsState()
    }
    
    func refreshButtonsState() {
        if(!showBottomBar){
            return
        }
        updateNavigationButton(buttonForward, webView?.canGoForward ?? false)
        updateNavigationButton(buttonBack, webView?.canGoBack ?? false)
    }
    
    func updateNavigationButton(_ button: UIButton,_ isActive: Bool){
        if (isActive == false){
            button.layer.borderColor = colorButtonsDisable.cgColor
            button.tintColor = colorButtonsDisable
        }else{
            button.layer.borderColor = colorButtonsEnable.cgColor
            button.tintColor = colorButtonsEnable
        }
        button.isEnabled = isActive
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            if(showBottomBar){
                progressView.progress = Float(self.webView!.estimatedProgress);
            }
        }
    }
    
    func createButton(_ button: UIButton){
        button.backgroundColor = .clear
        button.layer.cornerRadius = 1
        button.layer.borderWidth = 1
        button.layer.borderColor = colorButtonsEnable.cgColor
    }
    
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        handleRedirect(navigationAction.request)
        decisionHandler(.allow)
        
    }
    
    func handleRedirect(_ request: URLRequest)  -> Void{
        
        
        if let urlString = request.url?.absoluteString {
            
            print(urlString)
            
            //let params = getParameters(urlString)
            
            if urlString.starts(with: returnURL ?? "") {
                //let action = params["action"]
                if let delegate = self.delegate {
                    resetWebView()
                    self.dismiss(animated: true, completion: nil)
                    
                    delegate.logout(routerLogout: true, callbackId: callbackId ?? "")
                    
                    return
                }
            }
            
            
            
        }
        
        return
    }
    
    func forceLogout(){
        print("Force Logout")

        resetWebView()
        if let delegate = self.delegate {
            resetWebView()
                   
            //navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)

            DispatchQueue.main.async {
                
                
                delegate.logout(routerLogout: false, callbackId: self.callbackId ?? "")
                
            }

            
            return
        }
    }
    
    func resetWebView(){
        
        let dataStore = WKWebsiteDataStore.default()
        dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), completionHandler: { (records) in
            for record in records{
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record],       completionHandler: {
                    print("Clear success\(record)")
                })
                
            }
        })
        
    }
    
    
    func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
    
    
    func getParameters(_ urlString: String?) -> [String: String]? {
        
        guard let query = urlString else { return nil}
        
        var queryStrings = [String: String]()
        for pair in query.components(separatedBy: "&") {
            
            let key = pair.components(separatedBy: "=")[0]
            
            let value = pair
                .components(separatedBy:"=")[1]
                .replacingOccurrences(of: "+", with: " ")
                .removingPercentEncoding ?? ""
            
            queryStrings[key] = value
        }
        return queryStrings
    }
    
    func parseColor(hexString: String) -> UIColor{
        var chars = Array(hexString.hasPrefix("#") ? hexString.dropFirst() : hexString[...])
        let red, green, blue, alpha: CGFloat
        switch chars.count {
        case 3:
            chars = chars.flatMap { [$0, $0] }
            fallthrough
        case 6:
            chars = ["F","F"] + chars
            fallthrough
        case 8:
            alpha = CGFloat(strtoul(String(chars[0...1]), nil, 16)) / 255
            red   = CGFloat(strtoul(String(chars[2...3]), nil, 16)) / 255
            green = CGFloat(strtoul(String(chars[4...5]), nil, 16)) / 255
            blue  = CGFloat(strtoul(String(chars[6...7]), nil, 16)) / 255
        default:
            return backgroundColor
        }
        return UIColor.init(red: red, green: green, blue:  blue, alpha: alpha)
        
    }
    
    
}
