////
////  TabViewController.swift
////  Winton
////
////  Created by Alex Teague on 03/04/2018.
////  Copyright © 2018 Former Yugoslavic Republic of Asgaard. All rights reserved.
////
//
//import Foundation
//import SceneKit
//
//class TabBarController: UITabBarController
//{
//    var handedness: InversionController.Handedness = InversionController.DefaultHandedness
//    var initialViewController: String!
//
//    private(set) var gameViewController: GameViewController!
//    private(set) var tutorialViewController: TutorialViewController!
//
//    override func viewDidLoad()
//    {
//        super.viewDidLoad()
//        tabBar.isHidden = true
//
//        gameViewController = viewControllers![0] as! GameViewController
//        tutorialViewController = viewControllers![1] as! TutorialViewController
//
//        gameViewController.handedness = handedness
//        tutorialViewController.handedness = handedness
//
//        selectedViewController = initialViewController == Constants.GameViewController
//            ? gameViewController
//            : tutorialViewController
//    }
//
//    // Delegate methods don't fire unless tab bar buttons themselves are pressed. Since tab
//    // bar is hidden, will write own method. Not ideal, and not resuable.
//    func swapViewControllers(sender: BaseGameViewController)
//    {
//        if let newViewController = (sender == viewControllers?[0])
//            ? viewControllers?[1] as? BaseGameViewController
//            : viewControllers?[0] as? BaseGameViewController
//        {
//            newViewController.handedness = sender.handedness
//
//            let transitionOption = UIView.AnimationOptions.transitionCurlUp
//            UIView.transition(from: sender.view, to: newViewController.view, duration: 0.4, options: transitionOption, completion: nil)
//
//            selectedViewController = newViewController
//        }
//    }
//}
