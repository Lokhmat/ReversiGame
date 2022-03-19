//
//  PopUpView.swift
//  splokhmatikovHWReversi
//
//  Created by Sergey Lokhmatikov on 10.03.2022.
//

import SwiftUI

struct PopUpView: View {
    var title: String
    var message: String
    var buttonText: String
    var method: () -> Void
    @Binding var show: Bool
    
    var body: some View {
        ZStack {
            if show {
                
                // PopUp Window
                VStack(alignment: .center, spacing: 0) {
                    Text(title)
                        .frame(maxWidth: .infinity)
                        .frame(height: 45, alignment: .center)
                        .font(Font.system(size: 23, weight: .semibold))
                        .foregroundColor(Color.black)
                        .background(Color.clear)
                    
                    Text(message)
                        .multilineTextAlignment(.center)
                        .font(Font.system(size: 16, weight: .semibold))
                        .padding(EdgeInsets(top: 20, leading: 25, bottom: 20, trailing: 25))
                        .foregroundColor(Color.black)
                    
                    Button(action: {
                        // Dismiss the PopUp
                        withAnimation(.linear(duration: 0.3)) {
                            show = false
                            method()
                        }
                    }, label: {
                        Text(buttonText)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54, alignment: .center)
                            .foregroundColor(Color.black)
                            .background(Color.clear)
                            .font(Font.system(size: 23, weight: .semibold))
                    }).buttonStyle(PlainButtonStyle())
                }
                .frame(maxWidth: 300)
                .cornerRadius(50)
                .background(Color.clear)
            }
        }
    }
}
