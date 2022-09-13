//
//  ContentView.swift
//  Lightie
//
//  Created by Amir Yalchi on 2022-09-06.
//

import SwiftUI
import SlidingRuler

struct ContentView: View {

    @State private var selectedTab = 0
    @State private var shutterValue: Double = 125
    @State private var apertureValue: Double = 2.8
    @State private var isoValue: Double = 100
    @State var EV: Double = 0.0
    @State private var pickedImage: Bool = false
    @State var reTakePhoto = false
    @State var imageSelected = UIImage()
    @State var selector: Bool = false
    
//    @State var width: CGRect
//    @State var height: CGRect
//
//    init(){
//        width = Image.siz
//
//    }
//
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
        
        var liveView = HostedViewController()
        
        VStack {
            Picker("Selected Mode", selection: $selectedTab, content: {
                Text("Aperture").tag(0)
                Text("Shutter").tag(1)
            })
            .pickerStyle(SegmentedPickerStyle())
            Spacer()
            ZStack{
                Image(uiImage: imageSelected)
                    .frame(width: 300, height: 400, alignment: .center)
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .padding(.horizontal, 3.0)
//                    .border( .black, width: 5)
                    .cornerRadius(10)
                liveView
                    .frame(width: 300, height: 400, alignment: .center)
                    .cornerRadius(10)
                
            }
            
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
