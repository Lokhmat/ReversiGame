//
//  Field.swift
//  splokhmatikovHWReversi
//
//  Created by Sergey Lokhmatikov on 08.03.2022.
//

import SwiftUI
import CoreData

class Player: Equatable{
    var score: Int
    let name: String
    
    public init(score: Int, name: String){
        self.score = score
        self.name = name
    }
    
    static func ==(lhs: Player, rhs: Player) -> Bool {
        return lhs.name == rhs.name
    }
}

class Table: ObservableObject{
    private static var table: Table?
    private var scheme: [[Cell]]
    public var hard: Bool
    public var playerOne: Player
    public var playerTwo: Player
    @Published public var shouldFinish: Bool = false
    public var bestPlayerOne: Int?
    public var bestPlayerTwo: Int?
    
    private static let context: NSManagedObjectContext = {
            let container = NSPersistentContainer(name: "Score")
            container.loadPersistentStores{ _, error in
                if let error = error {
                    fatalError("Container loading failed")
                }
            }
            return container.viewContext
    }()
    
    private init(first: String, second: String, hard: Bool){
        scheme = []
        for row in 0...7{
            var temp:[Cell] = []
            for column in 0...7{
                temp.append(Cell(occupiedBy: Optional<Player>.none, isVacantNow: false, row: row, column: column))
            }
            scheme.append(temp)
        }
        playerOne = Player(score: 2, name: first)
        playerTwo = Player(score: 2, name: second)
        self.hard = hard
        getBestScore()
    }
    
    public static func getTableWithoutChecks() -> Table{
        return table!
    }
    
    public static func getTable(first: String, second: String, hard: Bool) -> Table{
        if table == nil || table?.hard != hard{
            table = Table(first: first, second: second, hard: hard)
            table!.initField()
        }
        return table!
    }
    
    public func getSceme() -> [[Cell]]{
        return scheme
    }
    
    public func initField(){
        scheme[3][3].occupiedBy = playerOne
        scheme[3][4].occupiedBy = playerTwo
        scheme[4][3].occupiedBy = playerTwo
        scheme[4][4].occupiedBy = playerOne
        setVacant(player: playerOne)
    }
    
    public func setVacant(player: Player){
        for row in scheme{
            for element in row{
                if traverseAndFind(cell: element, player: player).count != 0 && !shouldFinish{
                    element.isVacantNow = true
                } else{
                    element.isVacantNow = false
                }
            }
        }
    }
    
    public func traverseAndFind(cell: Cell, player: Player) -> [Direction]{
        var directions:[Direction] = []
        if cell.occupiedBy != nil{
            return directions
        }
        let another = (playerOne == player ? playerTwo : playerOne)
        for row in 0...7 where row != cell.row{
            if (scheme[row][cell.column].occupiedBy != nil && scheme[row][cell.column].occupiedBy! == player){
                if row < cell.row{
                    for el in row...cell.row{
                        if scheme[el][cell.column].occupiedBy == another && abs(el - cell.row) == 1 && cell.checkMonoton(direction: Direction.top, player: player){
                            directions.append(Direction.top)
                        }
                    }
                } else {
                    for el in cell.row...row{
                        if scheme[el][cell.column].occupiedBy == another && abs(el - cell.row) == 1 && cell.checkMonoton(direction: Direction.bottom, player: player){
                            directions.append(Direction.bottom)
                        }
                    }
                }
            }
        }
        for column in 0...7 where column != cell.column{
            if (scheme[cell.row][column].occupiedBy != nil && scheme[cell.row][column].occupiedBy! == player){
                if column < cell.column{
                    for el in column...cell.column{
                        if scheme[cell.row][el].occupiedBy == another && abs(el - cell.column) == 1 && cell.checkMonoton(direction: Direction.left, player: player){
                            directions.append(Direction.left)
                        }
                    }
                } else {
                    for el in cell.column...column{
                        if scheme[cell.row][el].occupiedBy == another && abs(el - cell.column) == 1 && cell.checkMonoton(direction: Direction.right, player: player){
                            directions.append(Direction.right)
                        }
                    }
                }
            }
        }
        for elem in 2...7 where (cell.row + elem < 8 && cell.column + elem < 8){
            if (scheme[cell.row + elem][cell.column + elem].occupiedBy != nil && scheme[cell.row + elem][cell.column + elem].occupiedBy! == player){
                if cell.row + 1 < 8 && cell.column + 1 < 8 && scheme[cell.row + 1][cell.column + 1].occupiedBy == another && cell.checkMonoton(direction: Direction.bottomRight, player: player){
                    directions.append(Direction.bottomRight)
                    break
                } else {
                    break
                }
            }
        }
        for elem in 2...7 where (cell.row - elem > -1 && cell.column - elem > -1){
            if (scheme[cell.row - elem][cell.column - elem].occupiedBy != nil && scheme[cell.row - elem][cell.column - elem].occupiedBy! == player){
                if cell.row - 1 > -1 && cell.column - 1 > -1 && scheme[cell.row - 1][cell.column - 1].occupiedBy == another && cell.checkMonoton(direction: Direction.topLeft, player: player){
                    directions.append(Direction.topLeft)
                    break
                } else {
                    break
                }
            }
        }
        for elem in 2...7 where (cell.row + elem < 8 && cell.column - elem > -1){
            if (scheme[cell.row + elem][cell.column - elem].occupiedBy != nil && scheme[cell.row + elem][cell.column - elem].occupiedBy! == player){
                if cell.row + 1 < 8 && cell.column - 1 > -1 && scheme[cell.row + 1][cell.column - 1].occupiedBy == another && cell.checkMonoton(direction: Direction.bottomLeft, player: player){
                    directions.append(Direction.bottomLeft)
                    break
                } else {
                    break
                }
            }
        }
        for elem in 2...7 where (cell.row - elem > -1 && cell.column + elem < 8){
            if (scheme[cell.row - elem][cell.column + elem].occupiedBy != nil && scheme[cell.row - elem][cell.column + elem].occupiedBy! == player){
                if cell.row - 1 > -1 && cell.column + 1 < 8 && scheme[cell.row - 1][cell.column + 1].occupiedBy == another && cell.checkMonoton(direction: Direction.topRight, player: player){
                    directions.append(Direction.topRight)
                    break
                } else {
                    break
                }
            }
        }
        return directions
    }
    
    public func updateScore(){
        var first: Int = 0
        var second: Int = 0
        for row in scheme{
            for element in row{
                if element.occupiedBy == nil{
                    continue
                }
                if element.occupiedBy!.name == playerOne.name{
                    first+=1
                } else if (element.occupiedBy!.name == playerTwo.name){
                    second+=1
                }
            }
        }
        playerOne.score = first
        playerTwo.score = second
    }
    
    private func getValue(cell: Cell, main: Bool) -> Double{
        if main {
            if (cell.row == 0 && cell.column == 0) || (cell.column == 7 && cell.row == 7) ||
                (cell.row == 7 && cell.column == 0) || (cell.row == 0 && cell.column == 7){
                return 0.8
            } else if cell.row == 0 || cell.column == 0 || cell.column == 7 || cell.row == 7{
                return 0.4
            }
            return 0
        }
        if (cell.row == 0 && cell.column == 0) || (cell.column == 7 && cell.row == 7) ||
            (cell.row == 7 && cell.column == 0) || (cell.row == 0 && cell.column == 7){
            return 5
        } else if cell.row == 0 || cell.column == 0 || cell.column == 7 || cell.row == 7{
            return 2
        }
        return 1
    }
    
    public func capture(cell: Cell, player: Player){
        let directions = traverseAndFind(cell: cell, player: player)
        for direction in directions{
            var delta = 1
            switch(direction){
            case Direction.left:
                var cur = scheme[cell.row][cell.column - 1]
                while(cur.occupiedBy != player){
                    cur.fillOne(player: player)
                    delta += 1
                    cur = scheme[cell.row][cell.column - delta]
                }
            case Direction.right:
                var cur = scheme[cell.row][cell.column + 1]
                while(cur.occupiedBy != player){
                    cur.fillOne(player: player)
                    delta += 1
                    cur = scheme[cell.row][cell.column + delta]
                }
            case Direction.top:
                var cur = scheme[cell.row - 1][cell.column]
                while(cur.occupiedBy != player){
                    cur.fillOne(player: player)
                    delta += 1
                    cur = scheme[cell.row - delta][cell.column]
                }
            case Direction.bottom:
                var cur = scheme[cell.row + 1][cell.column]
                while(cur.occupiedBy != player){
                    cur.fillOne(player: player)
                    delta += 1
                    cur = scheme[cell.row + delta][cell.column]
                }
            case Direction.bottomLeft:
                var cur = scheme[cell.row + 1][cell.column - 1]
                while(cur.occupiedBy != player){
                    cur.fillOne(player: player)
                    delta += 1
                    cur = scheme[cell.row + delta][cell.column - delta]
                }
            case Direction.bottomRight:
                var cur = scheme[cell.row + 1][cell.column + 1]
                while(cur.occupiedBy != player){
                    cur.fillOne(player: player)
                    delta += 1
                    cur = scheme[cell.row + delta][cell.column + delta]
                }
            case Direction.topLeft:
                var cur = scheme[cell.row  - 1][cell.column - 1]
                while(cur.occupiedBy != player){
                    cur.fillOne(player: player)
                    delta += 1
                    cur = scheme[cell.row - delta][cell.column - delta]
                }
            case Direction.topRight:
                var cur = scheme[cell.row - 1][cell.column + 1]
                while(cur.occupiedBy != player){
                    cur.fillOne(player: player)
                    delta += 1
                    cur = scheme[cell.row - delta][cell.column + delta]
                }
            }
        }
    }
    
    public func goSecond(){
        var vacant: [Cell] = []
        for row in 0...7{
            for column in 0...7 {
                if scheme[row][column].isVacantNow == true{
                    vacant.append(scheme[row][column])
                }
            }
        }
        if vacant.count == 0{
            shouldFinish = true
            return
        }
        if (!hard){
            var maxCell: Cell = vacant[0]
            var max: Double = 0
            for cell in vacant {
                let sum = countProfit(cell: cell, player: playerTwo)
                if sum > max{
                    max = sum
                    maxCell = cell
                }
            }
            maxCell.fillCell(player: playerTwo)
        } else {
            var maxCell: Cell = vacant[0]
            var max: Double = 0
            let vacantCopy = vacant.map{$0}
            for cell in vacantCopy {
                var sum = countProfit(cell: cell, player: playerTwo)
                let schemeCopy = scheme.map { $0.map{$0.copy()} }
                cell.fillCell(player: playerTwo)
                var maxSec: Double = 0
                for _ in vacant {
                    let sumSec = countProfit(cell: cell, player: playerOne)
                    if sumSec > max{
                        maxSec = sumSec
                    }
                }
                sum -= maxSec
                if sum > max{
                    max = sum
                    maxCell = cell
                }
                scheme = schemeCopy as! [[Cell]]
                setVacant(player: playerTwo)
            }
            maxCell.fillCell(player: playerTwo)
        }
    }
    
    private func countProfit(cell: Cell, player: Player) -> Double{
        var current: Double = 0
        let directions = traverseAndFind(cell: cell, player: player)
        for direction in directions{
            var delta = 1
            switch(direction){
            case Direction.left:
                var cur = scheme[cell.row][cell.column - 1]
                while(cur.occupiedBy != player){
                    current += getValue(cell: cur, main: false)
                    delta += 1
                    cur = scheme[cell.row][cell.column - delta]
                }
            case Direction.right:
                var cur = scheme[cell.row][cell.column + 1]
                while(cur.occupiedBy != player){
                    current += getValue(cell: cur, main: false)
                    delta += 1
                    cur = scheme[cell.row][cell.column + delta]
                }
            case Direction.top:
                var cur = scheme[cell.row - 1][cell.column]
                while(cur.occupiedBy != player){
                    current += getValue(cell: cur, main: false)
                    delta += 1
                    cur = scheme[cell.row - delta][cell.column]
                }
            case Direction.bottom:
                var cur = scheme[cell.row + 1][cell.column]
                while(cur.occupiedBy != player){
                    current += getValue(cell: cur, main: false)
                    delta += 1
                    cur = scheme[cell.row + delta][cell.column]
                }
            case Direction.bottomLeft:
                var cur = scheme[cell.row + 1][cell.column - 1]
                while(cur.occupiedBy != player){
                    current += getValue(cell: cur, main: false)
                    delta += 1
                    cur = scheme[cell.row + delta][cell.column - delta]
                }
            case Direction.bottomRight:
                var cur = scheme[cell.row + 1][cell.column + 1]
                while(cur.occupiedBy != player){
                    current += getValue(cell: cur, main: false)
                    delta += 1
                    cur = scheme[cell.row + delta][cell.column + delta]
                }
            case Direction.topLeft:
                var cur = scheme[cell.row  - 1][cell.column - 1]
                while(cur.occupiedBy != player){
                    current += getValue(cell: cur, main: false)
                    delta += 1
                    cur = scheme[cell.row - delta][cell.column - delta]
                }
            case Direction.topRight:
                var cur = scheme[cell.row - 1][cell.column + 1]
                while(cur.occupiedBy != player){
                    current += getValue(cell: cur, main: false)
                    delta += 1
                    cur = scheme[cell.row - delta][cell.column + delta]
                }
            }
            current += getValue(cell: cell, main: true)
        }
        return current
    }
    
    public func checkEndGame(){
        if playerOne.score == 0 || playerTwo.score == 0{
            shouldFinish = true
            saveMaxResult()
            return
        }
        var vacant:[Cell] = []
        var full = true
        for row in 0...7{
            for column in 0...7 {
                if scheme[row][column].isVacantNow == true{
                    vacant.append(scheme[row][column])
                }
                if scheme[row][column].occupiedBy == nil{
                    full = false
                }
            }
        }
        if vacant.count == 0 || full {
            shouldFinish = true
            saveMaxResult()
            return
        }
        
    }
    
    public static func reset(field: Table){
        field.scheme = Table(first: field.playerOne.name, second: field.playerTwo.name, hard: field.hard).getSceme()
        field.shouldFinish = false
        field.initField()
        
    }
    
    private func saveMaxResult(){
        let fetchRequest: NSFetchRequest<Score>
        fetchRequest = Score.fetchRequest()
        do {
            let score = try Table.context.fetch(fetchRequest)
            if score.count == 0 || score.last?.maxValueUser ?? 0 < playerOne.score {
                let newScore = Score(context: Table.context)
                newScore.maxValueIphone = Int32(playerTwo.score)
                newScore.maxValueUser = Int32(playerOne.score)
                try Table.context.save()
            }
        } catch{}
    }
    
    public func getBestScore(){
        let fetchRequest: NSFetchRequest<Score>
        fetchRequest = Score.fetchRequest()
        do {
            let score = try Table.context.fetch(fetchRequest)
            if score.isEmpty{
                return
            }
            bestPlayerOne = Int(score[0].maxValueUser)
            bestPlayerTwo = Int(score[0].maxValueIphone)
        } catch{return}
    }
}
