//
//  Untitled.swift
//  BeyondApp
//
//  Created by Ghadeer Fallatah on 07/04/1447 AH.
//
import SwiftUI

struct Popup: View {
    let icon: String
    let title: String
    let messge: String
    let onClose: () -> Void
    
    var body: some View {
        VStack(spacing:0){
            // top sction (Purple)
            ZStack(alignment: .topLeading){
                Rectangle()
                    .fill(Color.purple)
                    .frame(width:350,height: 100)
                    .cornerRadius(16)
                
                // close button
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.title2)
                        .padding()
                }
                
            }
            Text("")
        }
        VStack{
            Circle()
                .fill(Color.white)
                .frame(width:80, height:80)
                .overlay(
                    Image("rocket")
                        .resizable()
                        .scaledToFit()
                        .frame(width:40, height:40)
                        .foregroundColor(.yellow)
                )
        }
        VStack(spacing: 8){
            Text(title)
                .font(.headline)
                .bold()
                .foregroundColor(.black)
            Text(messge)
                .font(.subheadline)
                .foregroundColor(.gray)
            
        }
        .padding(.top, 60)
        .padding(.bottom,20)
        frame(maxWidth: .infinity)
        
    }
}
struct Popup_preview: PreviewProvider {
    static var previews: some View {
        Popup(icon: "", title: "", messge: "", onClose: {})
    }
}
