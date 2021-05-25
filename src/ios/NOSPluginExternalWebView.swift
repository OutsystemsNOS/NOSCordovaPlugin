import UIKit
import WebKit

class NOSPluginExternalWebView: UIViewController, WKNavigationDelegate {
    
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
    
    var delegate: ModalDelegate?
    var callbackId: String?
    
    var mainColor: String?
    var logging: Bool = false
    var returnURL: String?
    var buttonsAlignment: String?
    var showBottomBar: Bool = true
    
    var forceResetWebview: Bool = false
    
    var feraScheme = "fera://"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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
        UINavigationBar.appearance().barStyle = .default
        self.setNeedsStatusBarAppearanceUpdate()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        view.backgroundColor = backgroundColor
        
        createToolbar()
        
        if(showBottomBar){
            createBottomBar()
        }
        
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
            webView?.load(request)
        }
        
        webView?.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil);
        webView?.navigationDelegate = self
        webView?.backgroundColor = backgroundWebViewColor
        
        self.view.addSubview(webView!)
        
        webView?.translatesAutoresizingMaskIntoConstraints = false
        webView?.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        webView?.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        if(showBottomBar){
            webView?.bottomAnchor.constraint(equalTo: bottomBar.topAnchor).isActive = true
        }else{
            webView?.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        }
        
        webView?.topAnchor.constraint(equalTo: toolBar.bottomAnchor).isActive = true
        
        refreshButtonsState()
    }
    
    func checkIfResetIsRequired(){
        if(forceResetWebview == false){
            return
        }
        
        let dataStore = WKWebsiteDataStore.default()
        dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), completionHandler: { (records) in
            for record in records{
                    WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record],       completionHandler: {
                                         print("Clear success\(record)")
                })
               
            }
        })

    }
    
    @objc func buttonWebViewRefresh(sender: UIButton!){
        webView?.reload()
    }
    
    @objc func buttonWebViewBack(sender: UIButton!){
        if (webView?.canGoBack) != nil{
            webView?.goBack()
        }
    }
    
    @objc func buttonWebViewForward(sender: UIButton!){
        if (webView?.canGoForward) != nil{
            webView?.goForward()
        }
    }
    
    func createBottomBar(){
        bottomBar.backgroundColor = UIColor(red: CGFloat(229.0/255.0), green: CGFloat(229.0/255.0), blue: CGFloat(233.0/255.0), alpha: CGFloat(1.0))
        self.view.addSubview(bottomBar)
        
        
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        bottomBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        bottomBar.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        bottomBar.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        buttonBack = UIButton(frame: CGRect(x: 100, y: 100, width: 200, height: 20))
        buttonBack.setImage(UIImage(named: "icon-webview-left.png")?.withRenderingMode(.alwaysTemplate), for: .normal)
        buttonBack.tintColor = colorButtonsEnable
        
        buttonBack.addTarget(self, action: #selector(buttonWebViewBack), for: .touchUpInside)
        
        buttonBack.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.addSubview(buttonBack)
        
        
        buttonBack.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 20).isActive = true
        buttonBack.heightAnchor.constraint(equalTo: bottomBar.heightAnchor, constant: -20).isActive = true
        buttonBack.widthAnchor.constraint(equalToConstant: 30).isActive = true
        buttonBack.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor).isActive = true
        buttonBack.contentEdgeInsets = UIEdgeInsets(top: 5,left: 5,bottom: 5,right: 5)
        
        createButton(buttonBack)
        
        
        buttonForward = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
        buttonForward.setImage(UIImage(named: "icon-webview-right.png")?.withRenderingMode(.alwaysTemplate), for: .normal)
        buttonForward.tintColor = colorButtonsEnable
        buttonForward.addTarget(self, action: #selector(buttonWebViewForward), for: .touchUpInside)
        buttonForward.translatesAutoresizingMaskIntoConstraints = false
        
        bottomBar.addSubview(buttonForward)
        
        buttonForward.widthAnchor.constraint(equalToConstant: 30).isActive = true
        buttonForward.leadingAnchor.constraint(equalTo: buttonBack.trailingAnchor, constant: 20).isActive = true
        buttonForward.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor).isActive = true
        buttonForward.heightAnchor.constraint(equalTo: bottomBar.heightAnchor, constant: -20).isActive = true
        buttonForward.contentEdgeInsets = UIEdgeInsets(top: 5,left: 5,bottom: 5,right: 5)
        
        createButton(buttonForward)
        
        let buttonRefresh:UIButton = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
        buttonRefresh.setImage(UIImage(named: "icon-webview-refresh.png")?.withRenderingMode(.alwaysTemplate), for: .normal)
        buttonRefresh.tintColor = colorButtonsEnable
        buttonRefresh.addTarget(self, action: #selector(buttonWebViewRefresh), for: .touchUpInside)
        buttonRefresh.translatesAutoresizingMaskIntoConstraints = false
        
        bottomBar.addSubview(buttonRefresh)
        
        buttonRefresh.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
        buttonRefresh.widthAnchor.constraint(equalToConstant: 30).isActive = true
        buttonRefresh.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor).isActive = true
        buttonRefresh.heightAnchor.constraint(equalTo: bottomBar.heightAnchor, constant: -20).isActive = true
        buttonRefresh.contentEdgeInsets = UIEdgeInsets(top: 5,left: 5,bottom: 5,right: 5)
        
        createButton(buttonRefresh)
        
        progressView = UIProgressView(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        bottomBar.addSubview(progressView)
        
        progressView.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 0).isActive = true
        progressView.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: 0).isActive = true
        progressView.topAnchor.constraint(equalTo: bottomBar.topAnchor, constant: 0).isActive = true
        progressView.progressTintColor = backgroundColor
        progressView.trackTintColor = backgroundWebViewColor
        progressView.progress = 0.5
    }
    
    func createToolbar(){
        
        toolBar.backgroundColor = backgroundColor
        toolBar.tintColor = UIColor.white
        toolBar.sizeToFit()
        
        let buttonToolbarClose:UIButton = UIButton(frame: CGRect(x: 100, y: 100, width: 50, height: 50))
        buttonToolbarClose.setImage(UIImage(named: "icon_toolbar_close")?.withRenderingMode(.alwaysTemplate), for: .normal)
        
        buttonToolbarClose.addTarget(self, action: #selector(buttonClose), for: .touchUpInside)
        //buttonToolbarClose.backgroundColor = UIColor.green

        
        
        buttonToolbarClose.contentVerticalAlignment = .fill
        buttonToolbarClose.contentHorizontalAlignment = .fill
        buttonToolbarClose.imageView?.contentMode = .scaleAspectFit

        buttonToolbarClose.imageEdgeInsets =  UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        toolBar.addSubview(buttonToolbarClose)

        


        
        buttonToolbarClose.translatesAutoresizingMaskIntoConstraints = false
        
        if(buttonsAlignment?.contains("right") ?? false){
            buttonToolbarClose.trailingAnchor.constraint(equalTo: toolBar.trailingAnchor, constant: -15).isActive = true
        }else if(buttonsAlignment?.contains("left") ?? false){
            buttonToolbarClose.leadingAnchor.constraint(equalTo: toolBar.leadingAnchor, constant: 15).isActive = true
        }
        
        buttonToolbarClose.widthAnchor.constraint(equalToConstant: 40).isActive = true
        buttonToolbarClose.topAnchor.constraint(equalTo: toolBar.topAnchor).isActive = true
        buttonToolbarClose.bottomAnchor.constraint(equalTo: toolBar.bottomAnchor).isActive = true

        /////////////////////////////////
        if(!showBottomBar){
            let buttonToolbarRefresh:UIButton = UIButton(frame: CGRect(x: 100, y: 100, width: 50, height: 50))
            buttonToolbarRefresh.setImage(UIImage(named: "icon_toolbar_refresh")?.withRenderingMode(.alwaysTemplate), for: .normal)
            
            buttonToolbarRefresh.addTarget(self, action: #selector(buttonWebViewRefresh), for: .touchUpInside)


            //buttonToolbarRefresh.backgroundColor = UIColor.red
            
            
            buttonToolbarRefresh.contentVerticalAlignment = .fill
            buttonToolbarRefresh.contentHorizontalAlignment = .fill
            buttonToolbarRefresh.imageView?.contentMode = .scaleAspectFit

            buttonToolbarRefresh.imageEdgeInsets =  UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

            toolBar.addSubview(buttonToolbarRefresh)
            
            buttonToolbarRefresh.translatesAutoresizingMaskIntoConstraints = false
            buttonToolbarRefresh.trailingAnchor.constraint(equalTo: buttonToolbarClose.leadingAnchor, constant: -15).isActive = true
            buttonToolbarRefresh.widthAnchor.constraint(equalToConstant: 40).isActive = true
            buttonToolbarRefresh.topAnchor.constraint(equalTo: toolBar.topAnchor).isActive = true
            buttonToolbarRefresh.bottomAnchor.constraint(equalTo: toolBar.bottomAnchor).isActive = true
        }
        /////////////////////////////////

        
        
        
        
        let labelTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
        labelTitle.textAlignment = .center
        labelTitle.text = pageTitle
        labelTitle.textColor = UIColor.white
        
        toolBar.addSubview(labelTitle)
        
        labelTitle.translatesAutoresizingMaskIntoConstraints = false
        labelTitle.leadingAnchor.constraint(equalTo: toolBar.leadingAnchor).isActive = true
        labelTitle.trailingAnchor.constraint(equalTo: toolBar.trailingAnchor).isActive = true
        labelTitle.topAnchor.constraint(equalTo: toolBar.topAnchor).isActive = true
        labelTitle.bottomAnchor.constraint(equalTo: toolBar.bottomAnchor).isActive = true
        labelTitle.center = toolBar.center
        
        toolBar.isUserInteractionEnabled = true
        
        self.view.addSubview(toolBar)
        
        let standardSpacing: CGFloat = 0.0
        
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        toolBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        toolBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        toolBar.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: standardSpacing).isActive = true
        toolBar.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
    }
    
    @objc func cancelClick() {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
        
        if let delegate = self.delegate {
            delegate.returnValue(success: true, callbackId: callbackId ?? "", statusCode: "")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("Atmosphere viewWillAppear")
        
    }
    
    @objc func buttonClose() {
        dismiss(animated: true, completion: nil)
        //print("**" + (returnURL ?? ""))
        if let delegate = self.delegate {
            if let url = webView?.url {
                if url.absoluteString.hasSuffix(returnURL!){
                    delegate.returnValue(success: true, callbackId: callbackId ?? "", statusCode: "")
                }else{
                    delegate.returnValue(success: false, callbackId: callbackId ?? "", statusCode: "0")
                }
            }
        }
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
    
    
    
    func handleRedirect(_ request: URLRequest)  -> Void{
        
        
        if let urlString = request.url?.absoluteString {
            
            print(urlString)
            
            //let params = getParameters(urlString)
            
            if urlString.starts(with: scheme + "success") {
                //let action = params["action"]
                if let delegate = self.delegate {
                    delegate.returnValue(success: true, callbackId: callbackId ?? "", statusCode: "")
                    dismiss(animated: true, completion: nil)
                    
                    return
                }
            }
            
            if urlString.starts(with: scheme + "error") {
                //let action = params["action"]
                if let delegate = self.delegate {
                    delegate.returnValue(success: false, callbackId: callbackId ?? "", statusCode: "")
                    dismiss(animated: true, completion: nil)
                    
                    return
                }
            }
            
            if urlString.starts(with: scheme + "webview_response") {
                let statuscode = getQueryStringParameter(url: urlString, param: "statuscode") ?? ""
                checkStatusCode(Int(statuscode)!)
            }
                        
            if urlString.starts(with: feraScheme + "openurl") {

                if let urlOpenInBrownserString = getQueryStringParameter(url: urlString, param: "url") {
                    if let urlOpenInBrownser = URL(string: urlOpenInBrownserString){
                        UIApplication.shared.open(urlOpenInBrownser)
                    }
                }
                
                
            }
            
            
        }
        
        return
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        handleRedirect(navigationAction.request)
        decisionHandler(.allow)
        
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse,
                 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        if let response = navigationResponse.response as? HTTPURLResponse {
            checkStatusCode(response.statusCode)
        }
        decisionHandler(.allow)
    }
    
    func checkStatusCode(_ statusCode: Int){
        
        if statusCode >= 400 {
            if let delegate = self.delegate {
                delegate.returnValue(success: false, callbackId: callbackId ?? "", statusCode: String(statusCode))
            }
            dismiss(animated: true, completion: nil)
        }
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
