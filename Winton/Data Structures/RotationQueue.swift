//
//  RotationQueue.swift
//  Winton
//
//  Created by Alex Teague on 03/04/2018.
//  Copyright © 2018 Former Yugoslavic Republic of Asgaard. All rights reserved.
//

import Foundation

// N.B. See note at bottom about why it isn't currently possible to use a delegate instead of specifying a 'rotationMethod'. ToDo - rewrite using that pattern when possible.

class RotationQueue<T>
{
    private var queue: [T] = []
    private let queueMaxSize: Int?
    private var isRotating = false
    
    let doRotation: (_: T, _ completion: @escaping () -> Void) -> Void
    
    init(size: Int?, rotationMethod: @escaping (_: T, _ completion: @escaping () -> Void) -> Void)
    {
        queueMaxSize = size
        doRotation = rotationMethod
    }
    
    func enqueue(_ rotation: T)
    {
        if queueMaxSize == nil || queue.count < queueMaxSize!
        {
            queue.append(rotation)
            if !isRotating
            {
                checkQueue()
            }
        }
    }
    
    func enqueue(_ rotations: [T])
    {
        for rotation in rotations
        {
            enqueue(rotation)
        }
    }
    
    private func checkQueue()
    {
        if !queue.isEmpty
        {
            let rotation = queue.remove(at: 0)
            rotate(rotation)
        }
    }
    
    private func rotate(_ rotation: T)
    {
        isRotating = true
        doRotation(rotation, {
            self.isRotating = false
            self.checkQueue()
            
        })
    }
}

/* Ideally would implement with a generic delegate to do the actual rotation part. However, Swift doesn't currently allow this. Specifically, suppose we had:
 
 protocol RotationQueueDelegate
 {
    associatedType U
    func rotate(rotation: U)
 }
 
 And tried to include this as a property on our RotationQueue<T> class like so:
 
 class RotationQueue<T>
 {
    var delegate: RotationQueueDelegate
    ...
 }
 
 Then we get an error; we can't specify that the RotationQueueDelegate is going to be of type T as well. What we need is something like:
 
 protocol RotationQueueDelegate<U>
 {
    func rotate(rotation: U)
 }
 
 IMPORTANT: However, if what we were going to use as the delegate was specialised for the role (i.e. would implement the protocol and nothing more - wouldn't be a sublass of anything)
 then this approach works; make a generic wrapper class that just implements the protocol, then subclass this. RotationQueue would then look like:
 
 class RotationQueue<T>
 {
    var delegate: RotationQueueDelegateWrapper<T>
    ...
 }
 
 */
