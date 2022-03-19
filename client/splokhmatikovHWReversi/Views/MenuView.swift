//
//  MenuView.swift
//  splokhmatikovHWReversi
//
//  Created by Sergey Lokhmatikov on 19.03.2022.
//

import SwiftUI

struct MenuView: View {
    
    @State private var show: Bool = false
    @State private var hard: Bool = false
    @State private var destination: ContentView = ContentView(field: Table.getTable(first: "User", second: "Iphone", hard: false))
    @State private var selection: String? = nil
    @ObservedObject var table = Table.getTable(first: "User", second: "Iphone", hard: false)
    
    var body: some View {
        NavigationView{
            VStack{
                
                NavigationLink(destination: destination, tag: "easy", selection: $selection){}
                NavigationLink(destination: destination, tag: "hard", selection: $selection){}
                
                Text("Reversi game")
                    .padding()
                    .padding(.top, 100)
                    .font(Font.system(size: 25, weight: .semibold))
                
                
                Button(action: {destination.field.hard = false; selection = "easy"}){
                        Text("Easy mode")
                }
                .frame(width: 200, height: 50, alignment: .center)
                .background(Color(UIColor.systemMint))
                .foregroundColor(Color.black)
                .cornerRadius(20)
                .padding()
                .padding(.top, 100)
                
                Button(action: {destination.field.hard = true; selection = "hard"}){
                        Text("Hard mode")
                }
                .frame(width: 200, height: 50, alignment: .center)
                .background(Color(UIColor.systemMint))
                .foregroundColor(Color.black)
                .cornerRadius(20)
                .padding()
                
                Button(action: {
                    withAnimation(.linear(duration: 0.3)) {
                        show = !show
                    }
                    
                }){
                    Text("Show best")
                }
                .frame(width: 200, height: 50, alignment: .center)
                .background(Color(UIColor.systemMint))
                .foregroundColor(Color.black)
                .cornerRadius(20)
                .padding()
                
                PopUpView(title: "Best score:", message: table.bestPlayerOne == nil || table.bestPlayerTwo == nil ? "You have not played yet" : "You: \(table.bestPlayerOne!) Iphone: \(table.bestPlayerTwo!)", buttonText: "Close", method: {}, show: $show)
                Spacer()
            }
        }.navigationBarHidden(true).navigationBarBackButtonHidden(true)
    }
}
