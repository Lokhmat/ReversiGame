//
//  Cell.swift
//  splokhmatikovHWReversi
//
//  Created by Sergey Lokhmatikov on 08.03.2022.
//

import Foundation

class Cell: ObservableObject, NSCopying{
    
    func copy(with zone: NSZone? = nil) -> Any {
        return Cell(occupiedBy: occupiedBy, isVacantNow: isVacantNow, row: row, column: column)
    }
    
    @Published var occupiedBy: Player?
    @Published var isVacantNow: Bool
    var row: Int
    var column: Int
    
    public init(occupiedBy: Player?, isVacantNow: Bool, row: Int, column: Int){
        self.occupiedBy = occupiedBy
        self.isVacantNow = isVacantNow
        self.row = row
        self.column = column
    }
    
    public func fillCell(player: Player){
        if occupiedBy == nil && isVacantNow == true{
            let table = Table.getTableWithoutChecks()
            table.capture(cell: self, player: player)
            isVacantNow = false
            occupiedBy = player
            table.updateScore()
            table.checkEndGame()
            table.setVacant(player: player == table.playerTwo ? table.playerOne : table.playerTwo)
            if (player == table.playerOne){
                table.goSecond()
            }
            table.setVacant(player: player)
            table.checkEndGame()
        }
    }
    
    public func checkMonoton(direction: Direction, player: Player) -> Bool{
        let scheme = Table.getTableWithoutChecks().getSceme()
        let another = (Table.getTableWithoutChecks().playerOne == player ? Table.getTableWithoutChecks().playerTwo : Table.getTableWithoutChecks().playerOne)
        var delta = 1
        switch(direction){
        case Direction.left:
            var cur = scheme[self.row][self.column - 1]
            while(cur.occupiedBy != player){
                if cur.occupiedBy != another{
                    return false
                }
                delta += 1
                cur = scheme[self.row][self.column - delta]
            }
            return true
        case Direction.right:
            var cur = scheme[self.row][self.column + 1]
            while(cur.occupiedBy != player){
                if cur.occupiedBy != another{
                    return false
                }
                delta += 1
                cur = scheme[self.row][self.column + delta]
            }
            return true
        case Direction.top:
            var cur = scheme[self.row - 1][self.column]
            while(cur.occupiedBy != player){
                if cur.occupiedBy != another{
                    return false
                }
                delta += 1
                cur = scheme[self.row - delta][self.column]
            }
            return true
        case Direction.bottom:
            var cur = scheme[self.row + 1][self.column]
            while(cur.occupiedBy != player){
                if cur.occupiedBy != another{
                    return false
                }
                delta += 1
                cur = scheme[self.row + delta][self.column]
            }
            return true
        case Direction.bottomLeft:
            var cur = scheme[self.row + 1][self.column - 1]
            while(cur.occupiedBy != player){
                if cur.occupiedBy != another{
                    return false
                }
                delta += 1
                cur = scheme[self.row + delta][self.column - delta]
            }
            return true
        case Direction.bottomRight:
            var cur = scheme[self.row + 1][self.column + 1]
            while(cur.occupiedBy != player){
                if cur.occupiedBy != another{
                    return false
                }
                delta += 1
                cur = scheme[self.row + delta][self.column + delta]
            }
            return true
        case Direction.topLeft:
            var cur = scheme[self.row  - 1][self.column - 1]
            while(cur.occupiedBy != player){
                if cur.occupiedBy != another{
                    return false
                }
                delta += 1
                cur = scheme[self.row - delta][self.column - delta]
            }
            return true
        case Direction.topRight:
            var cur = scheme[self.row - 1][self.column + 1]
            while(cur.occupiedBy != player){
                if cur.occupiedBy != another{
                    return false
                }
                delta += 1
                cur = scheme[self.row - delta][self.column + delta]
            }
            return true
        }
    }
    
    public func fillOne(player: Player){
        isVacantNow = false
        occupiedBy = player
    }
    
    public func whoose(player: Player) -> Int{
        if occupiedBy != nil && player.name == occupiedBy?.name {
            return 0
        } else if occupiedBy != nil && player.name != occupiedBy?.name{
            return 1
        } else if isVacantNow == true {
            return 2
        }
        return 3
    }
    
}
