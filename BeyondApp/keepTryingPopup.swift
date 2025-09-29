//
//  Untitled.swift
//  BeyondApp
//
//  Created by Ghadeer Fallatah on 08/04/1447 AH.
//

//
//  Untitled.swift
//  BeyondApp
//
//  Created by Ghadeer Fallatah on 07/04/1447 AH.
//
import SwiftUI
import UIKit

struct PopupTry: View {
    let icon: String
    let title: String
    let messge: String
    let onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                // background overlay
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                ZStack {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 350, height: 300)
                        .cornerRadius(16) // all corners → use built-in
                        //.clipShape(RoundedCorner(radius: 16, corners: [.topLeft, .topRight,.bottomLeft, .bottomRight]))
                        //.cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 10)
                    
                    VStack {
                        VStack(spacing: 16) {
                            // top sction (Purple)
                            ZStack(alignment: .topLeading) {
                                Rectangle()
                                    .fill(Color.purple)
                                    .frame(width: 350, height: 100)
                                    .clipShape(RoundedCorner(radius: 16, corners: [.topLeft, .topRight]))
                                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 10)
                                    .overlay(
                                        
                                        VStack {
                                            Circle()
                                                .fill(Color.white)
                                                .frame(width: 110, height: 110)
                                                .overlay(
                                                    Image(icon)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 85, height: 85)
                                                    
                                                )
                                                .padding(.top,78)
                                        }
                                    )
                                
                                // close button
                                Button(action: onClose) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.white)
                                        .font(.title2)
                                        .padding()
                                }
                            }
                            
                        }
                        .padding(.top,-149.7)
                    }
                    
                    VStack(spacing: 8) {
                        Text("Don't give up!")
                            .font(.headline)
                            .bold()
                            .foregroundColor(.black)
                        Text("You can do it!, keep trying.")
                        Text("Good luck!")
                            .font(.subheadline)
                            .foregroundColor(.black)
                    }
                    .padding(.top, 120)
                    .padding(.bottom, 20)
                    .frame(maxWidth: .infinity)
                }
                .padding(.top, -150)
            }
        }
    }
    
}

#Preview {
    PopupTry(icon: "rocket", title: "Title", messge: "Message text goes here.", onClose: {})
}
