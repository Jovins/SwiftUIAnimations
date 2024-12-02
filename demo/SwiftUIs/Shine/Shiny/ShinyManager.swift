//
//  ShinyManager.swift
//  Shine
//
//  Created by Jovins on 2021/8/1.
//

import SwiftUI
import CoreMotion

class ShinyManager: ObservableObject {
    
    var motionInput = CMMotionManager()
    
    @Published var yaw: CGFloat = 0
    @Published var pitch: CGFloat = 0
    @Published var roll: CGFloat = 0
    
    static let shared = ShinyManager()
    init() {
        
        motionInput.deviceMotionUpdateInterval = 0.2
        motionInput.startDeviceMotionUpdates()
        motionInput.startDeviceMotionUpdates(to: OperationQueue.current!) { _,_  in
            
            if let yaw = self.motionInput.yaw,
                let pitch = self.motionInput.pitch,
                let roll = self.motionInput.roll
            {
                self.yaw = CGFloat(yaw)
                self.pitch = CGFloat(pitch)
                self.roll = CGFloat(roll)
            }
        }
    }
}

extension CMMotionManager {
    
    var yaw: Double? {
        get {
            return deviceMotion?.attitude.yaw
        }
    }
    
    var pitch: Double? {
        get {
            return deviceMotion?.attitude.pitch
        }
    }
    
    var roll: Double? {
        get {
            return deviceMotion?.attitude.roll
        }
    }
}
