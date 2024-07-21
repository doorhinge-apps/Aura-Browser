//
//  File.swift
//  
//
//  Created by hassan uriostegui on 2/27/23.
//

import Foundation

extension WebViewStore {
    public func getHTML(completion: @escaping (String?) -> Void) {
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()", completionHandler: { (html: Any?, _: Error?) in
            completion(html as? String)
        })
    }
}

extension WebViewStore {
    public func JSselectorComposableString(tag: String, value: String?, partial: Bool = true, caseInsensitive: Bool = true) -> String {
        let operation = partial ? "*=" : "="
        let caseConcern = caseInsensitive ? "i" : ""
        let selector = value == nil ? tag : "[\(tag)\(operation)\(value!) \(caseConcern)]"
        let script = "var result = document.querySelectorAll('\(selector)')"
        
        return script
    }
}

extension WebViewStore {
    public func JSsearchFor(tag: String, value: String? = nil, partial: Bool = true, caseInsensitive: Bool = true, completion: @escaping (Bool) -> Void) {
        let selector = JSselectorComposableString(tag: tag, value: value, partial: partial, caseInsensitive: caseInsensitive)
        let result = "result.length > 0;"
        JSperformScript(script: selector, result) { completion($0 as! Bool) }
    }
}

extension WebViewStore {
    static let JSRemoveScriptSufix = ".forEach(e => e.parentNode.removeChild(e));"
    public func JSremove(tag: String, value: String? = nil, partial: Bool = true, caseInsensitive: Bool = true, completion: @escaping (Bool) -> Void) {
        let remove = { [weak self] in
            
            guard let this = self else { return }
            
            let selector = this.JSselectorComposableString(tag: tag, value: value, partial: partial, caseInsensitive: caseInsensitive)
            let result = Self.JSRemoveScriptSufix
            let script = "\(selector)\(result)"
            
            this.JSperformScript(script: script) { _ in completion(true) }
        }
        
        JSsearchFor(tag: tag, value: value, partial: partial, caseInsensitive: caseInsensitive) { result in
            if result == false {
                assert(false, "Not found \(tag) or \(String(describing: value))")
                completion(false)
                return
            } else {
                remove()
            }
        }
    }
}

extension WebViewStore {
    public func JSperformScript(script: String..., completion: ((Any?) -> Void)? = nil) {
        let singleScript = script.joined(separator: ";")
        webView.evaluateJavaScript(singleScript) { (result: Any?, error: Error?) in
            if let error = error {
                print("Script failed: '\(singleScript)' with error: \(error.localizedDescription)")
                completion?(nil)
                return
            }
            completion?(result)
        }
    }
}

