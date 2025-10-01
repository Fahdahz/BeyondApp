//
//  Untitled.swift
//  BeyondApp
//
//  Created by Ghadeer Fallatah on 08/04/1447 AH.
//
import SwiftUI
import UIKit

struct PopupSuffle: View {
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
                    .onTapGesture(perform: onClose) // dismiss on background tap
                
                ZStack {
                    Rectangle()
                        .fill(Color(red: 255/255, green: 250/255, blue: 238/255))
                        .frame(width: 350, height: 300)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 10)
                    
                    VStack {
                        VStack(spacing: 16) {
                            // top section (Purple)
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
                                                        .frame(width: 67, height: 67)
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
                        Text("ALL SHUFFLED USED!")
                            .font(.headline)
                            .bold()
                            .foregroundColor(.black)
                        Text("You used all the avaliable")
                        Text("shuffles, try and do this challenge!")
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

// Shape that rounds only specific corners
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    PopupSuffle(icon: "shuffle", title: "Title", messge: "Message text goes here.", onClose: {})
}
