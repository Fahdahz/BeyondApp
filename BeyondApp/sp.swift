//
//  sp.swift
//  BeyondApp
//
//  Created by Noura bin dukheen on 10/04/1447 AH.
//
import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0.0
    @State private var textOpacity: Double = 0.0
 

    var body: some View {
        if isActive {
          
            Text("Main App View")
                .font(.title)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
        } else {
            GeometryReader { geometry in
                ZStack {
                    LinearGradient(colors: [
                       Color(red: 1.0,  green: 0.5843, blue: 0.0,    opacity: 0.18), // orange  #FF9500 @ 18%
                       Color(red: 1.0,  green: 0.4118, blue: 0.7059, opacity: 0.12)  // pink    #FF69B4 @ 12%
                   ], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                    VStack {
                        Spacer().frame(height: 250)

                        Image("beyondLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 400, height: 400)
                            .scaleEffect(logoScale)
                            .opacity(logoOpacity)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top,-150)
                        Spacer()
                    }

                    VStack {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(Color(red: 1.0, green: 0.98, blue: 0.95))
                                .frame(width: geometry.size.width * 1,
                                       height: geometry.size.width * 1.5)
                                .opacity(0.7)
                            Text("BEYOND the limits")
                                .font(.system(size: 25, weight: .bold))
                                .foregroundColor(.gray)
                                .opacity(textOpacity)
                                .multilineTextAlignment(.center)
                        }
                        .frame(height: 100)
                    }
                }
                .onAppear {
                    withAnimation(.easeIn(duration: 1.2)) {
                        logoScale = 1.0
                        logoOpacity = 1.0
                    }
                    withAnimation(.easeIn(duration: 1.8).delay(0.5)) {
                        textOpacity = 1.0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation {
                            isActive = true
                        }
                    }
                }
            }
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}

