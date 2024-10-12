//
//  WebsiteManager.swift
//  Aura
//
//  Created by Reyna Myers on 8/7/24.
//

import SwiftUI
import UIKit
import WebKit
//import WebViewSwiftUI
import LinkPresentation

class WebsiteManager: ObservableObject {
    @Published var webViewStores: [String: WebViewStore] = [:]
    
    @Published var selectedWebView: WebViewStore?
    
    func addWebViewStore(id: String, webViewStore: WebViewStore) {
        webViewStores[id] = webViewStore
    }
    
    func getWebViewStore(id: String) -> WebViewStore? {
        return webViewStores[id]
    }
    
    func selectOrAddWebView(urlString: String) {
        if let existingStore = webViewStores.values.first(where: { $0.webView.url?.absoluteString == urlString }) {
            // Set the found WebViewStore as the selected WebView
            selectedWebView = existingStore
            selectedWebView?.webView.allowsBackForwardNavigationGestures = true
        } else {
            // Create a new WebViewStore if not found and add it to the dictionary
            let newWebViewStore = WebViewStore()
            newWebViewStore.webView.allowsBackForwardNavigationGestures = true
            newWebViewStore.webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Safari/605.1.15"
            
            newWebViewStore.loadIfNeeded(url: URL(string: urlString) ?? URL(string: "https://example.com")!)
            webViewStores[urlString] = newWebViewStore
            
            let customMenu = UIMenu(title: "Custom Actions", image: nil, identifier: UIMenu.Identifier("com.yourapp.customMenu"), options: .displayInline, children: [
                UIAction(title: "Custom Action 1", image: UIImage(systemName: "star"), handler: { _ in
                    // Handle custom action 1
                    print("Custom action 1 tapped")
                }),
                UIAction(title: "Custom Action 2", image: UIImage(systemName: "heart"), handler: { _ in
                    // Handle custom action 2
                    print("Custom action 2 tapped")
                })
            ])
            
            // Add the refresh control
            addRefreshControl(to: newWebViewStore.webView.scrollView)
            
            selectedWebView = newWebViewStore
            
            
            
            //selectedWebView?.JSperformScript(script: forceDarkMode)
            
            if UserDefaults.standard.bool(forKey: "adBlockEnabled") {
                loadContentBlockingRules(selectedWebView?.webView ?? WKWebView())
            }
        }
        
        if webViewStores.count > Int(UserDefaults.standard.double(forKey: "preloadingWebsites")) {
            webViewStores = Dictionary(webViewStores.keys.prefix(Int(UserDefaults.standard.double(forKey: "preloadingWebsites"))).map { ($0, webViewStores[$0]!) }, uniquingKeysWith: { first, _ in first })
        }
    }
    
    func addRefreshControl(to scrollView: UIScrollView) {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadWebView(_:)), for: .valueChanged)
        //refreshControl.tintColor = UIColor.white
        scrollView.addSubview(refreshControl)
    }

    @objc func reloadWebView(_ sender: UIRefreshControl) {
        selectedWebView?.webView.reload()
        sender.endRefreshing()
    }

    
    
    @Published var linksWithTitles: [String: String] = [:]
    
    func fetchTitles(for urls: [String]) {
        for urlString in urls {
            guard let url = URL(string: urlString) else { continue }
            
            let metadataProvider = LPMetadataProvider() // Create a new instance for each URL
            metadataProvider.startFetchingMetadata(for: url) { (metadata, error) in
                guard error == nil, let title = metadata?.title else {
                    print("Failed to fetch metadata for url: \(urlString)")
                    return
                }
                DispatchQueue.main.async {
                    self.linksWithTitles[urlString] = title.replacingOccurrences(of: UserDefaults.standard.bool(forKey: "hideMagnifyingGlassSearch") ? "🔎": "", with: "")
                }
            }
        }
    }
    
    func fetchTitlesIfNeeded(for urls: [String]) {
        for urlString in urls {
            if linksWithTitles[urlString] == nil {
                guard let url = URL(string: urlString) else { continue }
                
                let metadataProvider = LPMetadataProvider() // Create a new instance for each URL
                metadataProvider.startFetchingMetadata(for: url) { (metadata, error) in
                    guard error == nil, let title = metadata?.title else {
                        print("Failed to fetch metadata for url: \(urlString)")
                        return
                    }
                    DispatchQueue.main.async {
                        self.linksWithTitles[urlString] = title.replacingOccurrences(of: UserDefaults.standard.bool(forKey: "hideMagnifyingGlassSearch") ? "🔎": "", with: "")
                    }
                }
            }
        }
    }
    
    func fetchTitle(for urlString: String, completion: @escaping (String?) -> Void) {
        // Check if the URL is valid
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        let metadataProvider = LPMetadataProvider() // Create a new instance for each URL
        metadataProvider.startFetchingMetadata(for: url) { (metadata, error) in
            guard error == nil, let title = metadata?.title else {
                print("Failed to fetch metadata for url: \(urlString)")
                completion(nil)
                return
            }
            
            let formattedTitle = title.replacingOccurrences(of: UserDefaults.standard.bool(forKey: "hideMagnifyingGlassSearch") ? "🔎": "", with: "")
            DispatchQueue.main.async {
                completion(formattedTitle)
            }
        }
    }

    
    private func loadContentBlockingRules(_ webView: WKWebView) {
        //guard let filePath = Bundle.main.path(forResource: "Adaway", ofType: "json") else {
        guard let filePath = Bundle.main.path(forResource: "adblock", ofType: "json") else {
            print("Error: Could not find rules.json file.")
            return
        }
        
        do {
            let jsonString = try String(contentsOfFile: filePath, encoding: .utf8)
            WKContentRuleListStore.default().compileContentRuleList(forIdentifier: "ContentBlockingRules", encodedContentRuleList: jsonString) { ruleList, error in
                if let error = error {
                    print("Error compiling content rule list: \(error.localizedDescription)")
                    return
                }
                
                guard let ruleList = ruleList else {
                    print("Error: Rule list is nil.")
                    return
                }
                
                let configuration = webView.configuration
                configuration.userContentController.add(ruleList)
            }
        } catch {
            print("Error loading rules.json file: \(error.localizedDescription)")
        }
    }
    
    @AppStorage("selectedSpaceIndex") var selectedSpaceIndex = 0
    
    @Published var hoverTab = ""
    
    @Published var selectedTabIndex: Int = -1
    @Published var hoverTabIndex = -1
    @Published var hoverCloseTabIndex = -1
    
    @Published var draggedIndex: Int?
    
    @Published var selectedTabLocation: TabLocations = .tabs
    @Published var hoverTabLocation: TabLocations = .tabs
    @Published var dragTabLocation: TabLocations = .tabs
    
    @StateObject var history = HistoryObservable()
}


let forceDarkModeBasic = """
(function() {
    // Function to check if the color is black
    function isBlack(color) {
        return color === 'rgb(0, 0, 0)' || color === '#000000' || color === '#1f1f1f' || color.toLowerCase() === 'black';
    }

    // Function to check if the color is white
    function isWhite(color) {
        return color === 'rgb(255, 255, 255)' || color === '#ffffff' || color.toLowerCase() === 'white';
    }

    // Function to invert the colors of an element
    function invertColor(element) {
        // Get the computed styles of the element
        const computedStyle = window.getComputedStyle(element);

        // Invert text color
        const textColor = computedStyle.color;
        if (isBlack(textColor)) {
            element.style.setProperty('color', 'white', 'important');
        } 
//else if (isWhite(textColor)) {
//            element.style.setProperty('color', 'black', 'important');
//        }

        // Invert background color
        const bgColor = computedStyle.backgroundColor;
//        if (isBlack(bgColor)) {
//            element.style.setProperty('background-color', 'white', 'important');
//        } else 
if (isWhite(bgColor)) {
            element.style.setProperty('background-color', '#333333', 'important');
        }
    }

    // Iterate through all elements on the page
    const elements = document.querySelectorAll('*');
    elements.forEach(function(element) {
        invertColor(element);
    });
})();
"""


//let forceDarkMode = """
//(function() {
//    function rgbToHsl(r, g, b) {
//        r /= 255;
//        g /= 255;
//        b /= 255;
//        let max = Math.max(r, g, b), min = Math.min(r, g, b);
//        let h, s, l = (max + min) / 2;
//        if (max === min) {
//            h = s = 0;
//        } else {
//            let d = max - min;
//            s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
//            switch (max) {
//                case r: h = (g - b) / d + (g < b ? 6 : 0); break;
//                case g: h = (b - r) / d + 2; break;
//                case b: h = (r - g) / d + 4; break;
//            }
//            h /= 6;
//        }
//        return [h * 360, s * 100, l * 100];
//    }
//
//    function hslToRgb(h, s, l) {
//        s /= 100;
//        l /= 100;
//        let c = (1 - Math.abs(2 * l - 1)) * s;
//        let x = c * (1 - Math.abs((h / 60) % 2 - 1));
//        let m = l - c / 2;
//        let r = 0, g = 0, b = 0;
//
//        if (h >= 0 && h < 60) {
//            r = c; g = x; b = 0;
//        } else if (h >= 60 && h < 120) {
//            r = x; g = c; b = 0;
//        } else if (h >= 120 && h < 180) {
//            r = 0; g = c; b = x;
//        } else if (h >= 180 && h < 240) {
//            r = 0; g = x; b = c;
//        } else if (h >= 240 && h < 300) {
//            r = x; g = 0; b = c;
//        } else if (h >= 300 && h < 360) {
//            r = c; g = 0; b = x;
//        }
//
//        r = Math.round((r + m) * 255);
//        g = Math.round((g + m) * 255);
//        b = Math.round((b + m) * 255);
//
//        return `rgb(${r}, ${g}, ${b})`;
//    }
//
//    function isVeryLight(color) {
//        let [r, g, b] = color.match(/\\d+/g).map(Number);
//        let [, , l] = rgbToHsl(r, g, b);
//        return l > 85;
//    }
//
//    function isVeryDark(color) {
//        let [r, g, b] = color.match(/\\d+/g).map(Number);
//        let [, , l] = rgbToHsl(r, g, b);
//        return l < 15;
//    }
//
//    function darkenColor(color) {
//        let [r, g, b] = color.match(/\\d+/g).map(Number);
//        let [h, s, l] = rgbToHsl(r, g, b);
//        l = Math.max(0, l - 50);
//        return hslToRgb(h, s, l);
//    }
//
//    function lightenColor(color) {
//        let [r, g, b] = color.match(/\\d+/g).map(Number);
//        let [h, s, l] = rgbToHsl(r, g, b);
//        l = Math.min(100, l + 50);
//        return hslToRgb(h, s, l);
//    }
//
//    function invertColor(element) {
//        const computedStyle = window.getComputedStyle(element);
//        let textColor = computedStyle.color;
//        if (isVeryDark(textColor)) {
//            element.style.setProperty('color', lightenColor(textColor), 'important');
//        } else if (isVeryLight(textColor)) {
//            element.style.setProperty('color', darkenColor(textColor), 'important');
//        } else {
//            element.style.setProperty('color', '#f0e000', 'important');
//        }
//
//        let bgColor = computedStyle.backgroundColor;
//        if (isVeryDark(bgColor)) {
//            element.style.setProperty('background-color', lightenColor(bgColor), 'important');
//        } else if (isVeryLight(bgColor)) {
//            element.style.setProperty('background-color', darkenColor(bgColor), 'important');
//        } else {
//            element.style.setProperty('background-color', 'black', 'important');
//        }
//    }
//
//    const tags = [
//        "FOOTER", "HEADER", "MAIN", "SECTION", "NAV", "FORM", "FONT", "EM", "B", "I", "U", "INPUT", "P", "BUTTON", "OL", "UL", "A", "DIV", "TD", "TH", "SPAN", "LI", "H1", "H2", "H3", "H4", "H5", "H6", "DD", "DT", "ARTICLE"
//    ];
//
//    for (let tag of tags) {
//        for (let item of document.getElementsByTagName(tag)) {
//            invertColor(item);
//        }
//    }
//
//    const codeTags = ["CODE", "PRE"];
//    for (let tag of codeTags) {
//        for (let item of document.getElementsByTagName(tag)) {
//            item.style.backgroundColor = 'black';
//            item.style.color = 'green';
//        }
//    }
//
//    const inputs = document.getElementsByTagName("INPUT");
//    for (let input of inputs) {
//        input.style.border = "solid 1px #bbb";
//    }
//
//    const videos = document.getElementsByTagName("VIDEO");
//    for (let video of videos) {
//        video.style.backgroundColor = "black";
//    }
//
//    const links = document.getElementsByTagName("A");
//    for (let link of links) {
//        link.style.color = "cyan";
//    }
//
//    const thTags = document.getElementsByTagName("TH");
//    for (let th of thTags) {
//        th.style.borderBottom = "solid 1px yellow";
//    }
//})();
//"""

let forceDarkModeAdvanced = """
(function() {
  const darkModeMain = {
    curr_obj: {
      'rgb(255, 255, 255)': 'rgb(23, 23, 23)',
      'rgb(245, 245, 245)': 'rgb(22, 22, 22)'
    },
    
    getSum: function(total, num) {
      return parseInt(total) + parseInt(num);
    },
    
    getRgbData: function(color) {
      const rgb = color.match(/\\d+/g);
      return {
        'sum': rgb.reduce(this.getSum),
        'value': rgb
      };
    },
    
    getDarkerShade: function(c1, p) {
      const newR = Math.round((parseInt(c1[0]) * p));
      const newG = Math.round((parseInt(c1[1]) * p));
      const newB = Math.round((parseInt(c1[2]) * p));
      return `rgb(${newR},${newG},${newB})`;
    },
    
    isTextNode: function(node) {
      return ['P', 'SPAN', 'H1', 'H2', 'H3', 'H4', 'H5', 'H6', 'A', 'LI', 'TD', 'TH', 'STRONG', 'EM', 'LABEL'].includes(node.tagName);
    },
    
    isGray: function(color) {
      const rgb = color.match(/\\d+/g);
      return rgb && rgb[0] === rgb[1] && rgb[1] === rgb[2];
    },
    
    isDarkGray: function(color) {
      const rgb = color.match(/\\d+/g);
      return this.isGray(color) && parseInt(rgb[0]) < 150;
    },
    
    processNode: function(currentNode) {
      if (currentNode.is_dnm_processed === true) {
        return;
      }
      
      const style = window.getComputedStyle(currentNode, null);
      const backgroundColor = style.backgroundColor;
      const color = style.color;
      
      if (backgroundColor && backgroundColor !== 'rgba(0, 0, 0, 0)') {
        let bgcolor;
        if (!(backgroundColor in this.curr_obj)) {
          const data = this.getRgbData(backgroundColor);
          const sumColor = data.sum;
          let currOpacity;
          
          if (sumColor >= 740 && sumColor <= 765) {
            currOpacity = 0.09;
          } else if (sumColor >= 710 && sumColor < 740) {
            currOpacity = 0.18;
          } else if (sumColor >= 680 && sumColor < 710) {
            currOpacity = 0.24;
          } else if (sumColor >= 580 && sumColor < 680) {
            currOpacity = 0.28;
          } else if (sumColor >= 500 && sumColor < 580) {
            currOpacity = 0.35;
          } else if (sumColor >= 400 && sumColor < 500) {
            currOpacity = 0.45;
          } else if (sumColor >= 300 && sumColor < 400) {
            currOpacity = 0.60;
          } else if (sumColor >= 200 && sumColor < 300) {
            currOpacity = 0.75;
          } else if (sumColor >= 80 && sumColor < 200) {
            currOpacity = 0.90;
          } else if (sumColor < 80) {
            currOpacity = 1;
          }
          
          bgcolor = this.getDarkerShade(data.value, currOpacity);
          this.curr_obj[backgroundColor] = bgcolor;
        } else {
          bgcolor = this.curr_obj[backgroundColor];
        }
        
        currentNode.style.setProperty('background', bgcolor, 'important');
      }
      
      // Handle text color
      if (this.isTextNode(currentNode)) {
        if (this.isDarkGray(color)) {
          currentNode.style.setProperty('color', 'rgb(255, 255, 255)', 'important');
        } else if (!this.isGray(color)) {
          // For non-gray colors, we'll make them slightly brighter
          const rgbValues = color.match(/\\d+/g).map(Number);
          const brighterColor = rgbValues.map(val => Math.min(255, val + 30)).join(',');
          currentNode.style.setProperty('color', `rgb(${brighterColor})`, 'important');
        }
      }
      
      currentNode.is_dnm_processed = true;
    },
    
    updateDocument: function() {
      const nodes = document.body.getElementsByTagName("*");
      for (let i = 0; i < nodes.length; i++) {
        this.processNode(nodes[i]);
      }
    },
    
    setBrightness: function(value) {
      if (value >= 50 && value <= 60) {
        document.body.style.removeProperty('filter');
      } else {
        document.body.style.setProperty('filter', `brightness(${value * 1.8}%)`, 'important');
      }
    },
    
    toggleDarkMode: function(enabled) {
      if (enabled) {
        document.body.style.setProperty('background', 'rgb(23, 23, 23)', 'important');
        this.updateDocument();
      } else {
        document.body.style.removeProperty('background');
        const nodes = document.body.getElementsByTagName("*");
        for (let i = 0; i < nodes.length; i++) {
          nodes[i].style.removeProperty('background');
          nodes[i].style.removeProperty('color');
          nodes[i].is_dnm_processed = false;
        }
      }
    }
  };
  
  // Expose functions to be called from Swift
  window.toggleDarkMode = darkModeMain.toggleDarkMode.bind(darkModeMain);
  window.setBrightness = darkModeMain.setBrightness.bind(darkModeMain);
})();
"""
