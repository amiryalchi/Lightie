//
//  ContentView.swift
//  Lightie
//
//  Created by Amir Yalchi on 2022-09-06.
//

import SwiftUI
import SlidingRuler
import Combine

struct ContentView: View {

    @State private var selectedTab = 0
    @State private var shutterValue: Double = 125
    @State private var apertureValue: Double = 2.8
    @State private var isoValue: Double = 100
    @State private var nDValue: Double = 0.0
    @State var EV: Double = 0.0
    @State private var pickedImage: Bool = false
    @State var reTakePhoto = false
    @State var imageSelected = UIImage()
    @State var selector: Bool = false
    
    private let compensationValues = [-6.0, -5.0, -4.0, -3.0, -2.0, -1.0, 0.0, +1.0, +2.0, +3.0, +4.0, +5.0, +6.0]
    @State private var selectedCompensation = 6

    private var formatter: NumberFormatter {
        let f = NumberFormatter()
        f.numberStyle = .none
        f.generatesDecimalNumbers = true
        f.maximumFractionDigits = 0
        return f
       }
    
    func calculateShutterSpeed(fNumber: Double, ev: Double, iso: Double) -> Double {

        let ss = (100 * pow(fNumber, 2.0)) / (iso * pow(2.0, ev))

        print("Calculated Sutter Speed: ", ss)
        print("ISO IS: ", isoValue)
        print("F NUMBER: ", apertureValue)
        return ss
    }
    
    func calculateFNumber(aprSpeed: Double, ev: Double, iso: Double) -> Double {

        let FN = sqrt((aprSpeed * (iso * pow(2.0, ev))) / 100)
        
        print ("Calculated F Number: ", FN)
        print("ISO IS : ", isoValue)
        print("SHUTTER SPEED : ", shutterValue)
        return FN
    }
        
    var body: some View {
        
        let liveView = HostedViewController()
        
        VStack {
            ZStack{
                Image(uiImage: imageSelected)
                    .frame(width: 300, height: 200, alignment: .center)
                    .cornerRadius(10)
                liveView
                    .frame(width: 300, height: 200, alignment: .center)
                    .cornerRadius(10)
            }

            Spacer()
            Picker("Selected Mode", selection: $selectedTab, content: {
                Text("Aperture").tag(0)
                Text("Shutter").tag(1)
            })
            .onChange(of: selectedTab, perform: { newValue in
                if selectedTab == 0 {
                    self.selector = false
                    self.apertureValue = calculateFNumber(aprSpeed: shutterValue, ev: EV, iso: isoValue)
                } else {
                    self.selector = true
                    self.shutterValue = calculateShutterSpeed(fNumber: apertureValue, ev: EV , iso: isoValue)
                }

            })
            .pickerStyle(SegmentedPickerStyle())

            
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
                    self.shutterValue = calculateShutterSpeed(fNumber: apertureValue, ev: EV , iso: isoValue)
                } else {
                    self.apertureValue = calculateFNumber(aprSpeed: shutterValue, ev: EV, iso: isoValue)
                }
            },
                         formatter: formatter)
            HStack {
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
                             formatter: formatter)
                .allowsHitTesting(false)
                Spacer()
                Picker("Please choose a color", selection: $selectedCompensation, content: {
                    ForEach(0..<compensationValues.count ,content:{ index in
                        Text(String(compensationValues[index]))
                    })
                })
                .pickerStyle(WheelPickerStyle())
            }
            
            Spacer()
            Button("Calculate") {
                print("HOI")
                if selectedTab == 0 {
                    self.selector = false
                } else {
                    self.selector = true
                }
                pickedImage = true
            }.sheet(isPresented: $pickedImage) {
                ImagePicker(selectedImage: self.$imageSelected, eV: self.$EV)
            }
            Spacer()
        }

        }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(EV: 10.0)
    }
}
 

