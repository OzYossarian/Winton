//
//  GameViewController.swift
//  Winton
//
//  Created by Alex Teague on 31/03/2018.
//  Copyright © 2018 Former Yugoslavic Republic of Asgaard. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import SpriteKit

class WelcomeViewController: BaseViewController
{
    private var welcomeView: SCNView!
    private var welcomeHud: WelcomeHud!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        let handInfoExists = defaults.dictionaryRepresentation().keys.contains(Constants.HandednessKey)
        if handInfoExists
        {
            let handHashValue = defaults.integer(forKey: Constants.HandednessKey)
            handedness = handHashValue == InversionController.Handedness.left.hashValue
                ? InversionController.Handedness.left
                : InversionController.Handedness.right
            enterNextView()
        }
        else
        {
            initialiseView()
            initialiseHud()
        }
    }
    
    private func initialiseView()
    {
        welcomeView = self.view as! SCNView
        welcomeView.backgroundColor = UIColor.white
        welcomeView.delegate = self
        
        let welcomeTapRecogniser = UITapGestureRecognizer(target: self, action: #selector(tapRecognised(_:)) )
        
        welcomeView.gestureRecognizers = [welcomeTapRecogniser]
    }
    
    private func initialiseHud()
    {
        welcomeHud = WelcomeHud(size: welcomeView.frame.size, safeSize: welcomeView.safeAreaLayoutGuide.layoutFrame.size, insets: welcomeView.safeAreaInsets)
        
        welcomeView.scene = SCNScene()
        welcomeView.overlaySKScene = welcomeHud
        welcomeHud.run(SKAction.fadeIn(withDuration: 0.5))
    }
    
    @objc private func tapRecognised(_ tap: UITapGestureRecognizer)
    {
        let location = tap.location(in: welcomeView)
        let locationInHud = getLocationInHud(locationInView: location)
        
        if welcomeHud.leftLabelNode.contains(locationInHud)
        {
            handedness = InversionController.Handedness.left
            fadeToNextView()
        }
        else if welcomeHud.rightLabelNode.contains(locationInHud)
        {
            handedness = InversionController.Handedness.right
            fadeToNextView()
        }
    }
    
    private func fadeToNextView()
    {
        UserDefaults.standard.set(handedness.hashValue, forKey: Constants.HandednessKey)
        
        let selectedNode = rightHanded ? welcomeHud.rightLabelNode : welcomeHud.leftLabelNode
        let unselectedNode = rightHanded ? welcomeHud.leftLabelNode : welcomeHud.rightLabelNode
        
        unselectedNode?.run(SKAction.fadeOut(withDuration: 0.25))
        selectedNode?.run(SKAction.fadeOut(withDuration: 0.75), completion: enterNextView)
    }
    
    private func enterNextView()
    {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: Constants.EnterGameView, sender: self.handedness)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let destination = segue.destination as? GameViewController
        {
            if let handedness = sender as? InversionController.Handedness
            {
                destination.handedness = handedness
            }
        }
    }
    
    override var shouldAutorotate: Bool
    {
        return true
    }
    
    override var prefersStatusBarHidden: Bool
    {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask
    {
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            return .landscape
        }
        else
        {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
}
