//
// Aura
// Sharing.swift
//
// Created by Reyna Myers on 17/7/24
//
// Copyright ©2024 DoorHinge Apps.
//


import SwiftUI
import WebKit

struct ActivityViewController: UIViewControllerRepresentable {
    var webView: WKWebView

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        let activityItems: [Any] = [webView]
        let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        uiViewController.present(activityController, animated: true, completion: nil)
    }
}

