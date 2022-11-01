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
    
    // Inserting View Model environmental object to be accessible globally
    
    @EnvironmentObject var viewModel: AppViewModel
    @State var pickedImage: Bool = false
    @State var imageSelected = UIImage()
    var value: Double = 2.0
    
    private var formatter: NumberFormatter {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.generatesDecimalNumbers = true
        f.maximumFractionDigits = 1
        return f
       }

    var body: some View {
        
        let liveView = HostedViewController()
        Spacer()
        VStack {
            ZStack{
    //  liveView object is displaying live video from the camera in a frame 300 * 200
                liveView
                    .frame(width: 300, height: 200, alignment: .center)
                    .cornerRadius(10)
                Image(uiImage:  self.imageSelected)
                    .frame(width: 300, height: 200, alignment: .center)
                    .cornerRadius(10)
                
                Spacer()
            }

            Divider().background(Color.white)
            Picker("Selected Mode", selection: $viewModel.selectedTab, content: {
                Text("Aperture").tag(0)
                Text("Shutter").tag(1)
            })
            .onChange(of: viewModel.selectedTab, perform: { newValue in

                viewModel.shutterOrAperture()
            })
            .pickerStyle(SegmentedPickerStyle())
            Spacer()
            
            VStack{
                VStack {
                    Divider().background(Color.white)
                    if viewModel.shutterValue < 0.5 {
                        Text("Shutter Speed  1/ " + String(format:"%.0f",viewModel.shutterPowerScale(shutter: viewModel.shutterDisplay)) + "  S")

                    } else {
                        Text("Shutter Speed  " + String(format:"%.0f",round(viewModel.shutterValue)) + "   S")
                    }
                    
                    ZStack(alignment: .bottom) {
                        SlidingRuler(value: $viewModel.shutterDisplay,
                                     in: -3...3,
                                     step: 0.3,
                                     snap: .half,
                                     tick: .half,
                                     onEditingChanged: { Bool in
                            viewModel.shutterValue = 1 / viewModel.shutterPowerScale(shutter: viewModel.shutterDisplay)
                            viewModel.apertureValue =  viewModel.calculateFNumber(aprSpeed: viewModel.shutterValue,
                                                                  ev: viewModel.EV,
                                                                  iso: viewModel.isoValue,
                                                                             compensation:  viewModel.compensationValues[ viewModel.selectedCompensation])
                        },
                                     formatter: formatter).allowsHitTesting(viewModel.selector)
                        Rectangle()
                            .fill(.background)
                            .frame(height: 15)
                            
                    }
                    
                    
                    
                }
                Divider().background(Color.white)
                VStack {
                    Text("F Stop  " + String(format:"%.1f",viewModel.apertureValue))
                    
                    SlidingRuler(value: $viewModel.apertureValue,
                                 in: 1...32,
                                 step: 1.0,
                                 snap: .unit,
                                 tick: .fraction,
                                 onEditingChanged: { Bool in
                        viewModel.shutterValue =  viewModel.calculateShutterSpeed(fNumber: viewModel.apertureValue,
                                                                  ev: viewModel.EV ,
                                                                  iso: viewModel.isoValue,
                                                                             compensation:  viewModel.compensationValues[ viewModel.selectedCompensation])
                        viewModel.shutterDisplay = viewModel.shutterLogScale(shutter: 1 / viewModel.shutterValue)

                    },
                                 formatter: formatter).allowsHitTesting(!viewModel.selector)
                }
                Divider().background(Color.white)
                VStack (alignment: .custom) {
                    Text("ISO  " + String(format:"%.0f",round(viewModel.isoValue)))
                        .alignmentGuide(VerticalAlignment.custom) { d in d[.top] }
                    SlidingRuler(value: $viewModel.isoValue,
                                 in: 50...128000,
                                 step: 100,
                                 snap: .none,
                                 tick: .fraction,
                                 onEditingChanged: { Bool in
                        viewModel.shutterOrAperture()
                        },
                                     formatter: formatter)
                    Divider().background(Color.white)
                }
                
            }
            
                Spacer()
                HStack {
                    Spacer()
                    Text("EV")
                    Text(formatter.string(from: NSNumber(value: viewModel.EV))!)
                    Spacer()
                    Text("Compensation :")
                    Picker("Compensation Value", selection: $viewModel.selectedCompensation, content: {
                        ForEach(0..<viewModel.compensationValues.count, id: \.self ,content:{ index in
                            Text(String( viewModel.compensationValues[index]))
                        })
                    })
                    .frame(width: 50, height: 100)
                    .clipped()
                    .compositingGroup()
                    .onChange(of:  viewModel.selectedCompensation, perform: { selected in
                        print("selected value is :",  viewModel.compensationValues[selected])
                        viewModel.shutterOrAperture()
                    })
                    .pickerStyle(InlinePickerStyle())
                    Spacer()
                }
            
            Spacer()
            Button("Calculate"){
                print("HOI")
                if viewModel.selectedTab == 0 {
                    viewModel.selector = false
                } else {
                    viewModel.selector = true
                }
                self.pickedImage = true
            }
            .foregroundColor(.white)
            .frame(width: 300, height: 50)
            .background(Color.orange)
            .cornerRadius(10)
            .sheet(isPresented: self.$pickedImage) {
                ImagePicker(selectedImage: self.$imageSelected, eV: $viewModel.EV)
            }
            Spacer()
        }

        }
}

 // expension for alignment method for stacks 

extension HorizontalAlignment {
    enum Custom: AlignmentID {
        static func defaultValue(in d: ViewDimensions) -> CGFloat {
            d[HorizontalAlignment.center]
        }
    }
    static let custom = HorizontalAlignment(Custom.self)
}
extension VerticalAlignment {
    enum Custom: AlignmentID {
        static func defaultValue(in d: ViewDimensions) -> CGFloat {
            d[VerticalAlignment.center]
        }
    }
    static let custom = VerticalAlignment(Custom.self)
}
extension Alignment {
    static let custom = Alignment(horizontal: .custom,
                                  vertical: .custom)
}

