//
//  ViewController.swift
//  AdvanceWebApp
//
//  Created by Shahid Ghafoor on 01/05/2019.
//  Copyright © 2019 Shahid Ghafoor. All rights reserved.
//

import UIKit
import WebKit
import Foundation
import SystemConfiguration
import SafariServices
import AppLovinSDK

import GoogleMobileAds


class ViewController: UIViewController, WKUIDelegate ,WKNavigationDelegate, GADBannerViewDelegate, GADFullScreenContentDelegate {

    let source: String = "javascript:(function() {document.getElementsByClassName('banner sidebar')[0].style.display='none';})(); javascript:(function() {document.getElementsByClassName('col-sm-3')[0].style.visibility='hidden';})();javascript:(function() {document.getElementsByClassName('mobile-ad-banner')[0].style.display='none';})();";
    
    @IBOutlet weak var laodingView: UIActivityIndicatorView!
    @IBOutlet weak var webView: WKWebView!
    
    // Admob
    var bannerView: GADBannerView!
    private var interstitial: GADInterstitialAd?
    
    // Applovin
    private let kBannerHeight: CGFloat = 50
    private let adView = ALAdView(size: .banner)


    override func viewDidLoad() {
        super.viewDidLoad()
        
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        addBannerViewToView(bannerView)
        bannerView.adUnitID = "ca-app-pub-6812853586050394/9126435384"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        
        let request = GADRequest()
            GADInterstitialAd.load(withAdUnitID:"ca-app-pub-6812853586050394/9131687702",
                                        request: request,
                              completionHandler: { [self] ad, error in
                                if let error = error {
                                  print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                                  return
                                }
                                interstitial = ad
                              }
            )
        
        if isInternetAvailable() {
            // webview navigation
            webView.navigationDelegate = self
            webView.uiDelegate = self
            webView.scrollView.bounces = true
            let myURL = URL(string:"https://nwsfd.com/")
            let myRequest = URLRequest(url: myURL!)
            let script: WKUserScript = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            webView.configuration.userContentController.addUserScript(script)
            webView.load(myRequest)
            // swipe left or right for going back or forward
            webView.allowsBackForwardNavigationGestures = true
            webView.evaluateJavaScript(source, completionHandler: nil)
            let source: String = "var meta = document.createElement('meta');" +
                        "meta.name = 'viewport';" +
                        "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
                        "var head = document.getElementsByTagName('head')[0];" + "head.appendChild(meta);";
            let zoomScript: WKUserScript = WKUserScript(source: source, injectionTime: .atDocumentEnd,forMainFrameOnly: true)
            webView.configuration.userContentController.addUserScript(zoomScript)
        } else {
            showAlert()
        }
        
        ALPrivacySettings.setHasUserConsent(true)
    }

    func addBannerViewToView(_ bannerView: GADBannerView) {
      bannerView.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview(bannerView)
      view.addConstraints(
        [NSLayoutConstraint(item: bannerView,
                            attribute: .bottom,
                            relatedBy: .equal,
                            toItem: bottomLayoutGuide,
                            attribute: .top,
                            multiplier: 1,
                            constant: 0),
         NSLayoutConstraint(item: bannerView,
                            attribute: .centerX,
                            relatedBy: .equal,
                            toItem: view,
                            attribute: .centerX,
                            multiplier: 1,
                            constant: 0)
        ])
     }
    
    func webView(_ webView: WKWebView,
didStartProvisionalNavigation navigation: WKNavigation!) {
        
        print("provision nev ..receiving.....")
        webView.evaluateJavaScript(source, completionHandler: nil)
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        laodingView.isHidden = true
        print("finish..loading")
        webView.evaluateJavaScript(source, completionHandler: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if interstitial != nil {
            interstitial?.present(fromRootViewController: self)
          } else {
            print("Ad wasn't ready")
          }
    }

    override func viewWillDisappear(_ animated: Bool) {
        if interstitial != nil {
            interstitial?.present(fromRootViewController: self)
          } else {
            print("Ad wasn't ready")
          }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if navigationAction.navigationType == .linkActivated  {
                if let url = navigationAction.request.url,
                    let host = url.host, !host.hasPrefix("nwsfd.com"),
                    UIApplication.shared.canOpenURL(url) {
                    let safariVC = SFSafariViewController(url: url)
                            present(safariVC, animated: true, completion: nil)
                    decisionHandler(.cancel)
                } else {
                    print("Open it locally")
                    decisionHandler(.allow)
                }
            } else {
                decisionHandler(.allow)
            }
        }
    
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    func showAlert() {
        if !isInternetAvailable() {
            let alert = UIAlertController(title: "Warning", message: "The Internet is not available", preferredStyle: .alert)
            let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: true)
    }
    
    /// Tells the delegate that the ad failed to present full screen content.
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
      print("Ad did fail to present full screen content.")
    }

    /// Tells the delegate that the ad presented full screen content.
    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
      print("Ad did present full screen content.")
    }

    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
      print("Ad did dismiss full screen content.")
    }
    
}

