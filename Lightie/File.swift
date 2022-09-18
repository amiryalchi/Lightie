//
//  RulerSlider.swift
//  lighty
//
//  Created by Amir Yalchi on 2022-09-12.
//

import SwiftUI
import SlidingRuler

struct CoontentView: View {

    @State private var selectedTab = 0
    @State private var shutterValue: Double = 125
    @State private var apertureValue: Double = 2.8
    @State private var isoValue: Double = 100
    @State var EV: Double = 0.0
    @State private var pickedImage: Bool = false
    @State var reTakePhoto = false
    @State var imageSelected = UIImage()
    @State var selector: Bool = false
    
    private var formatter: NumberFormatter {
        let f = NumberFormatter()
        f.numberStyle = .none
        f.generatesDecimalNumbers = true
        f.maximumFractionDigits = 0
        return f
       }
    
    func calculateShutterSpeed(fNumber: Double, ev: Double, iso: Double) -> Double {

        let ss = exp(2 * log2(fNumber) - ev - log2(iso / 3.125))

        print("Calculated Sutter Speed: ", ss)
        print("ISO IS: ", isoValue)
        print("F NUMBER: ", apertureValue)
        return ss
    }
    
    func calculateFNumber(aprSpeed: Double, ev: Double, iso: Double) -> Double {

        let FN = exp((ev + log2(aprSpeed) + log2(iso / 3.125)) / 2 )
        
        print ("Calculated F Number: ", FN)
        print("ISO IS : ", isoValue)
        print("SHUTTER SPEED : ", shutterValue)
        return FN
    }
        
    var body: some View {
        
        
        VStack {
            Spacer()
            
            SlidingRuler(value: $shutterValue,
                         in: 0...100,
                         step: 0.1,
                         snap: .unit,
                         tick: .fraction,
                         onEditingChanged: { Bool in
                self.apertureValue = calculateFNumber(aprSpeed: shutterValue, ev: EV, iso: isoValue)
            },
                         formatter: formatter).allowsHitTesting(selector)
            SlidingRuler(value: $apertureValue,
                         in: 0...32,
                         step: 1.0,
                         snap: .unit,
                         tick: .fraction,
                         onEditingChanged: { Bool in
                self.shutterValue = calculateShutterSpeed(fNumber: apertureValue, ev: EV , iso: isoValue)

            },
                         formatter: formatter).allowsHitTesting(!selector)
            SlidingRuler(value: $isoValue,
                         in: 50...128000,
                         step: 100,
                         snap: .none,
                         tick: .fraction,
                         onEditingChanged: { Bool in
                if selectedTab == 0 {
                    self.apertureValue = calculateFNumber(aprSpeed: shutterValue, ev: EV, iso: isoValue)
                } else {
                    self.shutterValue = calculateShutterSpeed(fNumber: apertureValue, ev: EV , iso: isoValue)
                }
            },
                         formatter: formatter)
            SlidingRuler(value: $EV,
                         in: -7...17,
                         step: 1.0,
                         snap: .fraction,
                         tick: .fraction,
                         onEditingChanged: { Bool in
                if selectedTab == 0 {
                    self.apertureValue = calculateFNumber(aprSpeed: shutterValue, ev: EV, iso: isoValue)
                } else {
                    self.shutterValue = calculateShutterSpeed(fNumber: apertureValue, ev: EV , iso: isoValue)
                }
            },
                         formatter: formatter).allowsHitTesting(false)
            Spacer()
        }

        }
}
var child = UIHostingController(rootView: ContentView())


