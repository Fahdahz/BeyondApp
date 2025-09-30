//
//  Untitled.swift
//  BeyondApp
//
//  Created by Ghadeer Fallatah on 07/04/1447 AH.
//
import SwiftUI
import UIKit

struct Popup: View {
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
                        .fill(Color(red: 255/255, green: 250/255, blue: 238/255))
                        .frame(width: 350, height: 300)
                        .cornerRadius(16) // all corners → use built-in
                        //.clipShape(RoundedCorner(radius: 16, corners: [.topLeft, .topRight, .bottomLeft, .bottomRight]))
                        //.cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 10)
                    
                    VStack {
                        VStack(spacing: 16) {
                            // top sction (Purple)
                            ZStack(alignment: .topLeading) {
                                Rectangle()
                                    .fill(Color(red: 207/255, green: 214/255, blue: 237/255))
                                    .frame(width: 350, height: 100)
                                    .clipShape(RoundedCorner(radius: 16, corners: [.topLeft, .topRight]))
                                   
                                    .overlay(
                                        VStack {
                                            Circle()
                                                .fill(Color(red: 255/255, green: 250/255, blue: 238/255))
                                                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 10)
                                                .frame(width: 110, height: 110)
                                                .overlay(
                                                    Image(systemName: icon)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 70, height: 70)
                                                        .foregroundStyle(.yellow)
                                                )
                                                .padding(.top, 78)
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
                        .padding(.top, -149.7)
                    }
                    
                    VStack(spacing: 8) {
                        Text("CONGRATULATIONS!")
                            .font(.headline)
                            .bold()
                            .foregroundColor(.black)
                        Text("Well done, you did it!")
                        Text("Keep up the good work!")
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
    Popup(icon: "trophy.fill", title: "Title", messge: "Message text goes here.", onClose: {})
}
