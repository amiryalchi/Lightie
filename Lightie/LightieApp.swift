//
//  LightieApp.swift
//  Lightie
//
//  Created by Amir Yalchi on 2022-09-06.
//

import SwiftUI

@main
struct LightieApp: App {
    
    @StateObject var viewModel = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
