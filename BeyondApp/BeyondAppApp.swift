//
//  BeyondAppApp.swift
//  BeyondApp
//
//  Created by Fahdah Alsamari on 07/04/1447 AH.
//

import SwiftUI

@main
struct BeyondAppApp: App {
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}
