//
//  ContentView.swift
//  splokhmatikovHWReversi
//
//  Created by Sergey Lokhmatikov on 08.03.2022.
//

import SwiftUI

let FIELDMAP: [Int:String] = [
    0: "You",
    1: "Enemy",
    2: "Vacant",
    3: "Empty"
]

struct SquareView : View {
    @ObservedObject var dataSource : Cell
    var turn: Bool
    var body: some View {
        Button(action: {
            dataSource.fillCell(player: (turn ? Table.getTableWithoutChecks().playerOne : Table.getTableWithoutChecks().playerTwo))
        }, label: {
            Image(FIELDMAP[dataSource.whoose(player: Table.getTableWithoutChecks().playerOne)] ?? "Empty").resizable()
                .frame(width: 30, height: 30, alignment: .center)
        })
    }
}

struct ContentView: View {
    @ObservedObject public var field: Table
    private var showPopUp: Bool = Table.getTableWithoutChecks().shouldFinish
    private var turn: Bool = true
    
    public init (field: Table) {
        self.field = field
    }
    
    var body: some View{
        VStack {
            Text("Reversi")
                .font(.largeTitle)
                .bold()
            
            PopUpView(title: "Game over", message: "Score:\n You:\(field.playerOne.score)\nIphone:\(field.playerTwo.score)", buttonText: "OK", method: {Table.reset(field: field)}, show: ($field.shouldFinish))
            
            ForEach(0..<8) { row in
                HStack {
                    ForEach(0..<8) { column in
                        SquareView(dataSource: field.getSceme()[row][column], turn: turn)
                    }
                }
            }
        }
        
    }
    
}
/*
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(hard: false)
    }
}*/
