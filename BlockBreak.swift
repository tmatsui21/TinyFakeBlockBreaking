//
//  BlockBreak.swift
//  justTest
//
//  Created by Takashi Matsui on R 6/11/17.
//

import SwiftUI

struct BreakModel {
    let numOfBlock: Int
    
    var initPosition = CGPoint.zero
    var frameSize = CGSize.zero
    var deltaX = 0
    var deltaY = 0
    
    var ballSize: CGFloat = 0
    var position = CGPoint.zero
    
    var paddleSize = CGSize.zero
    var paddlePosition = CGPoint.zero
    
    var block: [BlockModel] = []
    
    init(numOfBlock: Int = 1){
        self.numOfBlock = numOfBlock
        block = [BlockModel](repeating: BlockModel(), count: numOfBlock)
    }
    
}

struct BlockModel : Hashable{
    var blockSize = CGSize.zero
    var blockPosition = CGPoint.zero
}

struct BlockBreak: View {
    @State private var blockBreak: BreakModel = BreakModel()
    @State private var timer: Timer?
    @State private var labelText = ""
    @State private var isCleared = 0
    @State private var isInitialized = false
    @State private var numOfBlock = 3
    @State private var deltaFlag = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(){
                VStack{
                    Text("Tiny Fake Block Breaking")
                    HStack{
                        Button("init", systemImage: "arrow.counterclockwise") {
                            blockBreak = BreakModel(numOfBlock: numOfBlock)
                            blockBreak.initPosition.x = geometry.frame(in: .local).midX
                            blockBreak.initPosition.y = geometry.frame(in: .local).midY
                            blockBreak.frameSize.width = geometry.frame(in: .local).width*0.9
                            blockBreak.frameSize.height = geometry.frame(in: .local).height*0.8
                            initGame()
                        }
                        Button("start", systemImage: "play.fill") {
                            if (isInitialized){
                                labelText = "Drag paddle"
                                timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                                    if (blockBreak.position.y + blockBreak.ballSize > blockBreak.initPosition.y + blockBreak.frameSize.height/2){
                                        labelText = "Game Over"
                                        isInitialized = false
                                        blockBreak.ballSize = 0
                                        timer?.invalidate()
                                    }
                                    for i in 0 ..< blockBreak.block.count {
                                        if (intersect(position: blockBreak.block[i].blockPosition, size: blockBreak.block[i].blockSize, ballPosition: blockBreak.position, ballSize: blockBreak.ballSize)){
                                            blockBreak.deltaY = blockBreak.deltaY * -1
                                            blockBreak.block[i].blockSize = CGSize.zero
//                                            print("ball clash with block")
                                            isCleared -= 1
                                            if (isCleared == 0) {
                                                labelText = "Game Clear!!"
                                                isInitialized = false
                                                blockBreak.ballSize = 0
                                                timer?.invalidate()
                                            }
                                        }
                                    }
                                    
                                    if (intersect(position: blockBreak.paddlePosition, size: blockBreak.paddleSize, ballPosition: blockBreak.position, ballSize: blockBreak.ballSize)){
                                        blockBreak.deltaY = blockBreak.deltaY * -1
                                        if (deltaFlag == 1){
                                            if (blockBreak.deltaX < 0) {
                                                blockBreak.deltaX = blockBreak.deltaX * -1
                                            }
                                        }
                                        else if (deltaFlag == -1){
                                            if (blockBreak.deltaX > 0) {
                                                blockBreak.deltaX = blockBreak.deltaX * -1
                                            }
                                        }
//                                        print("ball clash with paddle")
                                    }
                                    else {
                                        if (blockBreak.position.y - blockBreak.ballSize < blockBreak.initPosition.y - blockBreak.frameSize.height/2){
                                            blockBreak.deltaY = blockBreak.deltaY * -1
                                        }
                                        if (blockBreak.position.x + blockBreak.ballSize > blockBreak.initPosition.x + blockBreak.frameSize.width/2 || blockBreak.position.x  - blockBreak.ballSize < blockBreak.initPosition.x - blockBreak.frameSize.width/2){
                                            blockBreak.deltaX = blockBreak.deltaX * -1
                                        }
                                    }
                                    blockBreak.position.x +=  CGFloat(blockBreak.deltaX)
                                    blockBreak.position.y +=  CGFloat(blockBreak.deltaY)
                                }
                            }
                        }
                        Button("stop", systemImage: "stop.fill") {
                            timer?.invalidate()
                            labelText = "Press Start"
                        }
                    }
                    Spacer()
                }
                
                ZStack {
                    if (isInitialized){
                        ForEach (blockBreak.block, id: \.self){ block in
                            Rectangle()
                                .fill(.brown)
                                .frame(width: block.blockSize.width, height: block.blockSize.height)
                                .position(x: block.blockPosition.x, y: block.blockPosition.y)
                        }
                    }
                    Rectangle()
                        .fill(.green)
                        .frame(width: blockBreak.paddleSize.width, height: blockBreak.paddleSize.height)
                        .position(x: blockBreak.paddlePosition.x, y: blockBreak.paddlePosition.y)
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    if (gesture.location.x - blockBreak.paddlePosition.x > 0) {
                                        deltaFlag = 1
//                                        labelText = "右"
                                    } else if (gesture.location.x - blockBreak.paddlePosition.x < 0){
                                        deltaFlag = -1
//                                        labelText = "左"
                                    } else {
                                        deltaFlag = 0
                                    }
                                    if ((gesture.location.x - blockBreak.paddleSize.width/2) > 0
                                        && gesture.location.x < (blockBreak.frameSize.width)){
                                        blockBreak.paddlePosition.x = gesture.location.x
//                                        print("gesture.location.x\(gesture.location.x)")
                                    }
                                }
                        )
                    Rectangle()
                        .stroke(.orange, lineWidth: 3)
                        .fill(.clear)
                        .frame(width: blockBreak.frameSize.width, height: blockBreak.frameSize.height)
                        .position(x: blockBreak.initPosition.x, y: blockBreak.initPosition.y)
                    Circle()
                        .fill(.cyan)
                        .frame(width: blockBreak.ballSize, height: blockBreak.ballSize)
                        .position(x: blockBreak.position.x, y: blockBreak.position.y)
                }
                VStack{
                    Spacer()
                    Grid{
                        GridRow{
                            Text("Number of Blocks:  \(numOfBlock)")
                            Stepper("Number of Blocks:\(numOfBlock)", value: $numOfBlock, in: 1...5)
                                .labelsHidden()
                        }
                    }
                    Text(labelText)
                }
            }
        }
    }
    
    private func initGame(){
        blockBreak.position.x = blockBreak.initPosition.x
        blockBreak.position.y = blockBreak.initPosition.y
        blockBreak.ballSize = 15
        
        blockBreak.deltaX = Int(blockBreak.ballSize * -1)
        blockBreak.deltaY = Int(blockBreak.ballSize)
        
        blockBreak.paddlePosition.x = blockBreak.initPosition.x
        blockBreak.paddlePosition.y = blockBreak.initPosition.y + blockBreak.frameSize.height/2 - blockBreak.ballSize
        blockBreak.paddleSize.width = blockBreak.frameSize.width/4
        blockBreak.paddleSize.height = blockBreak.ballSize
        
        for num in 0 ..< blockBreak.block.count{
            blockBreak.block[num].blockSize.width = blockBreak.frameSize.width / CGFloat(blockBreak.numOfBlock * 2)
            blockBreak.block[num].blockSize.height = blockBreak.ballSize*1.5
            blockBreak.block[num].blockPosition.x = ((blockBreak.frameSize.width / CGFloat(blockBreak.numOfBlock * 2)) * CGFloat(num))*2 + blockBreak.frameSize.width / CGFloat(blockBreak.numOfBlock * 2) + blockBreak.ballSize
            blockBreak.block[num].blockPosition.y = blockBreak.initPosition.y - blockBreak.frameSize.height/3
        }
        
        isCleared = blockBreak.block.count
        isInitialized = true
        timer?.invalidate()
        labelText = "Press Start"
    }
    
    private func intersect(position: CGPoint, size: CGSize, ballPosition: CGPoint, ballSize: CGFloat) -> Bool{
        let result: Bool
        if (ballPosition.x + ballSize < position.x + size.width
            && ballPosition.x - ballSize > position.x - size.width
            && ballPosition.y < position.y + size.height
            && ballPosition.y > position.y - size.height
        )
        {
            result = true
        } else {
            result = false
        }
        
        return(result)
    }
}

#Preview {
    BlockBreak()
}
