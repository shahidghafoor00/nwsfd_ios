//
//  SubscriptionViewController.swift
//  AdvanceWebApp
//
//  Created by Ayaz Rafai on 25/07/21.
//  Copyright © 2021 Shahid Ghafoor. All rights reserved.
//

import UIKit

extension SubscriptionViewController {
    static func shared() -> SubscriptionViewController {
        UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SubscriptionViewController") as! SubscriptionViewController
    }
}

class SubscriptionViewController: UIViewController {

    @IBOutlet weak var btnSubscribe: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        btnSubscribe.layer.cornerRadius = btnSubscribe.frame.size.height / 2
    }
    
    @IBAction func btnBackTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSubscribeTapped(_ sender: Any) {
    }
}
