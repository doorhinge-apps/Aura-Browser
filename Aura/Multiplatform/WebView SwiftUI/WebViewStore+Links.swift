//
//  File.swift
//  
//
//  Created by hassan uriostegui on 2/27/23.
//

import Foundation
import WebKit

extension WebViewStore {
    //        @constant WKNavigationTypeLinkActivated    A link with an href attribute was activated by the user.
    //        @constant WKNavigationTypeFormSubmitted    A form was submitted.
    //        @constant WKNavigationTypeBackForward      An item from the back-forward list was requested.
    //        @constant WKNavigationTypeReload           The webpage was reloaded.
    //        @constant WKNavigationTypeFormResubmitted  A form was resubmitted (for example by going back, going forward, or reloading).
    //        @constant WKNavigationTypeOther            Navigation is taking place for some other reason.
          
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard (navigationAction.navigationType == .linkActivated ||
              navigationAction.navigationType == .formSubmitted ||
              navigationAction.navigationType == .formResubmitted ||
              navigationAction.navigationType == .backForward),
              let linkHandler = linkHandler,
              let url = navigationAction.request.url else{
            decisionHandler(.allow)
            return
        }
       
        let result = linkHandler(url)
        switch result{
        case .allow:
            decisionHandler(.allow)
        case .deny:
            decisionHandler(.cancel)
        case .openExternal:
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
        }
    }
   
    public func openInExternalBrowser() {
        guard let url = webView.url else { return }
        UIApplication.shared.open(url)
    }
}

