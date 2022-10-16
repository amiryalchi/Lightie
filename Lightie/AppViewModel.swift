//
//  AppViewModel.swift
//  Lightie
//
//  Created by Amir Yalchi on 2022-10-05.
//

import Foundation
import SwiftUI

class AppViewModel: ObservableObject {
    
    @Published var selectedTab = 0
    @Published var shutterValue: Double = 125
    @Published var apertureValue: Double = 2.8
    @Published var isoValue: Double = 100
    @Published var EV: Double = 0.0
    @Published var selector: Bool = false
    @Published var shutterDisplay: Double = 125
    
    let compensationValues: [Double] = [-6.0, -5.0, -4.0, -3.0, -2.0, -1.0, 0.0, +1.0, +2.0, +3.0, +4.0, +5.0, +6.0]
    @Published var selectedCompensation = 6
    
    func calculateShutterSpeed(fNumber: Double, ev: Double, iso: Double, compensation: Double) -> Double {
        let newEv = (-0.33 * compensation) + ev
        let ss = (100 * pow(fNumber, 2.0)) / (iso * pow(2.0, newEv))
        
        print("Calculated Sutter Speed: ", ss)
        print("ISO IS: ", isoValue)
        print("F NUMBER: ", apertureValue)
        return ss
    }
    
    func calculateFNumber(aprSpeed: Double, ev: Double, iso: Double, compensation: Double) -> Double {
        let newEv = (-0.33 * compensation) + ev
        let FN = sqrt((aprSpeed * iso * pow(2.0, newEv)) / 100)
        
        print ("Calculated F Number: ", FN)
        print("ISO IS : ", isoValue)
        print("SHUTTER SPEED : ", shutterValue)
        return FN
    }
    
    func shutterOrAperture(){
        if selectedTab == 0 {
            self.selector = false
            self.shutterValue = self.calculateShutterSpeed(fNumber: apertureValue, ev: EV , iso: isoValue, compensation: compensationValues[selectedCompensation])
            self.shutterDisplay = self.shutterLogScale(shutter: 1 / shutterValue)
        } else {
            self.selector = true
            self.apertureValue = self.calculateFNumber(aprSpeed: shutterValue, ev: EV, iso: isoValue, compensation: compensationValues[selectedCompensation])
        }
    }
    
    func shutterPowerScale(shutter: Double) -> Double {
        return Double(powf(10,Float(shutter)))
    }
    
    func shutterLogScale(shutter: Double) -> Double {
        return log10(shutter)
    }
    
}
