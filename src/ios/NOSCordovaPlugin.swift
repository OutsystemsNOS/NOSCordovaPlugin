import SafariServices


protocol ModalDelegate {
    func returnValue(success: Bool, callbackId: String, statusCode: String)
}

protocol NOSCordovaPluginInterface {
    func logout(routerLogout: Bool, callbackId: String)

}

@available(iOS 11.0, *)
@objc(NOSCordovaPlugin) class NOSCordovaPlugin : CDVPlugin, ModalDelegate, SFSafariViewControllerDelegate, NOSCordovaPluginInterface {


    
    func returnValue(success: Bool, callbackId: String, statusCode: String) {
        var pluginResult: CDVPluginResult
        if(success == true){
            pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
        }else{
            pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: statusCode)
        }
        
        self.commandDelegate!.send(
            pluginResult,
            callbackId: callbackId
        )
    }
    
    @objc(showExternalWebViewLogout:)
    func showExternalWebViewLogout(command: CDVInvokedUrlCommand) {
        
        print("Nos Cordova Plugin showExternalWebViewLogout")
        let mainController = NOSPluginExternalWebViewLogout() as NOSPluginExternalWebViewLogout
        var index = 0
        
        if(command.arguments.count > index && command.arguments[index] is Bool){
            let firstArgument = command.arguments[index] as? Bool ?? false
            mainController.logging = firstArgument
        }
        index+=1
        if(command.arguments.count > index && command.arguments[index] is String){
            let firstArgument = command.arguments[index] as? String ?? ""
            mainController.urlLoading = firstArgument
        }
        index+=1
        if(command.arguments.count > index && command.arguments[index] is String){
            let secondArgument = command.arguments[index] as? String ?? ""
            mainController.pageTitle = secondArgument
        }
        index+=1
        if(command.arguments.count > index && command.arguments[index] is String){
            let headers = command.arguments[index]as? String ?? ""
            mainController.headers = headers
        }
        index+=1
        if(command.arguments.count > index && command.arguments[index] is String){
            let color = command.arguments[index] as? String ?? ""
            mainController.mainColor = color
        }
        index+=1
        if(command.arguments.count > index && command.arguments[index] is String){
            let returnURL = command.arguments[index] as? String ?? ""
            mainController.returnURL = returnURL
        }
        index+=1
        if(command.arguments.count > index && command.arguments[index] is Bool){
            let firstArgument = command.arguments[index] as? Bool ?? true
            mainController.showBottomBar = firstArgument
        }
        index+=1
        if(command.arguments.count > index && command.arguments[index] is String){
            let firstArgument = command.arguments[index] as? String ?? ""
            mainController.buttonsAlignment = firstArgument
        }
        index+=1
        if(command.arguments.count > index && command.arguments[index] is Double){
            let firstArgument = command.arguments[index] as? Double ?? 10
            mainController.timeoutSecond = firstArgument
        }
        
        
        mainController.delegate = self
        mainController.callbackId = command.callbackId

      
        let alertView = UIAlertController(title: "Gerir o router", message: "a terminar sessão.......", preferredStyle: .alert)

        alertView.view.tintColor = UIColor.black

        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: alertView.view.frame.width / 2.0, y: alertView.view.frame.height / 2.0, width: 20.0, height: 20.0))
        loadingIndicator.center = CGPoint(x: alertView.view.frame.width / 2.0, y: alertView.view.frame.height / 2.0)
        loadingIndicator.hidesWhenStopped = true

        
        loadingIndicator.startAnimating();

        alertView.view.addSubview(loadingIndicator)
        //self.viewController?.present(alertView, animated: true)
        //logout(routerLogout: false)
        
        
        mainController.delegate = self
        mainController.callbackId = command.callbackId

        mainController.modalPresentationStyle = .overCurrentContext

       self.viewController?.present(
           mainController,
           animated: true,
           completion: nil
       )
    }
    
    
    @objc(showExternalWebView:)
    func showExternalWebView(command: CDVInvokedUrlCommand) {
        
        print("Nos Cordova Plugin showExternalWebView")
        let mainController = NOSPluginExternalWebView() as NOSPluginExternalWebView
        var index = 0
        
        if(command.arguments.count > index && command.arguments[index] is Bool){
            let firstArgument = command.arguments[index] as? Bool ?? false
            mainController.logging = firstArgument
        }
        
        if(mainController.logging == true){
            let stringRepresentation = command.arguments.description
            
            let alert = UIAlertController()
            alert.title = "DEBUG"
            alert.message = stringRepresentation
            
            let dismiss = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(dismiss)
            
            self.viewController?.present(alert, animated: true, completion: nil)
        }
        
        
        index+=1
        if(command.arguments.count > index && command.arguments[index] is String){
            let firstArgument = command.arguments[index] as? String ?? ""
            mainController.urlLoading = firstArgument
        }
        index+=1
        if(command.arguments.count > index && command.arguments[index] is String){
            let secondArgument = command.arguments[index] as? String ?? ""
            mainController.pageTitle = secondArgument
        }
        index+=1
        if(command.arguments.count > index && command.arguments[index] is String){
            let headers = command.arguments[index]as? String ?? ""
            mainController.headers = headers
        }
        index+=1
        if(command.arguments.count > index && command.arguments[index] is String){
            let color = command.arguments[index] as? String ?? ""
            mainController.mainColor = color
        }
        index+=1
        if(command.arguments.count > index && command.arguments[index] is String){
            let returnURL = command.arguments[index] as? String ?? ""
            mainController.returnURL = returnURL
        }
        index+=1
        if(command.arguments.count > index && command.arguments[index] is Bool){
            let firstArgument = command.arguments[index] as? Bool ?? true
            mainController.showBottomBar = firstArgument
        }
        index+=1
        if(command.arguments.count > index && command.arguments[index] is String){
            let firstArgument = command.arguments[index] as? String ?? ""
            mainController.buttonsAlignment = firstArgument
        }
        index+=1
        if(command.arguments.count > index && command.arguments[index] is Bool){
            let firstArgument = command.arguments[index] as? Bool ?? false
            mainController.forceResetWebview = firstArgument
        }

        mainController.delegate = self
        mainController.callbackId = command.callbackId
        
        self.viewController?.present(
            mainController,
            animated: true,
            completion: nil
        )
    }
    
    
    var authSession: SFAuthenticationSession?
    
    
    @objc(showSafariViewController:)
    func showSafariViewController(command: CDVInvokedUrlCommand){
        
        print("Nos Cordova Plugin showSafariViewController")
        
        var index = 0
        var url = ""
        var color = ""
        if(command.arguments.count > index && command.arguments[index] is Bool){
            let firstArgument = command.arguments[index] as? Bool ?? false
            _ = firstArgument
        }
        
        index+=1
        if(command.arguments.count > index && command.arguments[index] is String){
            url = command.arguments[index] as? String ?? ""
        }
        index+=1
        if(command.arguments.count > index && command.arguments[index] is String){
            _ = command.arguments[index] as? String ?? ""
        }
        index+=1
        if(command.arguments.count > index && command.arguments[index] is String){
            _ = command.arguments[index]as? String ?? ""
        }
        index+=1
        if(command.arguments.count > index && command.arguments[index] is String){
            color = command.arguments[index] as? String ?? ""
        }
        
        //ASWebAuthenticationSessionse
        authSession =  SFAuthenticationSession(url: URL(string: url)!, callbackURLScheme: "mynos://",  completionHandler: { (callBack:URL?, error:Error? ) in
            guard error == nil, let successURL = callBack else {
                print(error!)
                //self.cookieLabel.text = "Error retrieving cookie"
                return
            }
            //let cookievalue = getQueryStringParameter(url: (successURL.absoluteString), param: self.cookiename)
            //self.cookieLabel.text = (cookievalue == "None") ? "cookie not set" : "Cookie for key " + self.cookiename + ": " + cookievalue!
        })
        
        
        //(callBack:URL?, error:Error? ) in
        //guard error == nil, let successURL = callBack else {
        //print(error!)
        //self.cookieLabel.text = "Error retrieving cookie"
        //return
        //}
        //let cookievalue = getQueryStringParameter(url: (successURL.absoluteString), param: self.cookiename)
        //self.cookieLabel.text = (cookievalue == "None") ? "cookie not set" : "Cookie for key " + self.cookiename + ": " + cookievalue!
        
        
        if(color != ""){
            //let c = parseColor(hexString: color);
            //authSession.preferredBarTintColor = c
            //vc.preferredControlTintColor = c
        }
        
        authSession?.start()
        
        /*
         
         vc.delegate = self
         
         if(color != ""){
         let c = parseColor(hexString: color);
         vc.preferredBarTintColor = c
         //vc.preferredControlTintColor = c
         }
         
         self.viewController?.present(vc, animated: true)
         
         */
    }
    
    func logout(routerLogout: Bool, callbackId: String) {
        DispatchQueue.main.async {
            self.webViewEngine.evaluateJavaScript("onRouterLogout(false)") { (result, error) in
                if error != nil {
                    print(result)
                }
            }
            self.returnValue(success: true, callbackId: callbackId, statusCode: "")
            
        }
    

    }
    
    var backgroundColor =  UIColor(red: CGFloat(110.0/255.0), green: CGFloat(165.0/255.0), blue: CGFloat(20.0/255.0), alpha: CGFloat(1.0))
    
    
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

