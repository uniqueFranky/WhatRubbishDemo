//
//  ViewController.swift
//  WhatRubbishDemo
//
//  Created by 闫润邦 on 2022/4/7.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureTabBar()
    }

    func configureTabBar() {
        let rvc = RecgonitionViewController()
        let ivc = IntroductionViewController()
        let pvc = PuzzleViewController()
        
        rvc.title = "Recgonition"
        ivc.title = "Introduction"
        pvc.title = "Puzzle"
        
        self.setViewControllers([rvc, ivc, pvc], animated: true)
        
        guard let items = self.tabBar.items else {  return}
        let imageNames = ["brain.head.profile", "book.closed", "questionmark"]
        
        for i in 0..<items.count {
            items[i].image = UIImage(systemName: imageNames[i])
        }
    }

}

