//
//  BlockBreak.swift
//  justTest
//
//  Created by Takashi Matsui on R 6/11/17.
//

import SwiftUI

struct BlockModel {
    var initPosition = CGPoint.zero
    var frameSize = CGSize.zero
    var deltaX = 0
    var deltaY = 0
    
    var ballSize: CGFloat = 0
    var position = CGPoint.zero
    
    var paddleSize = CGSize.zero
    var paddlePosition = CGPoint.zero
    
    var blockSize = CGSize.zero
    var blockPosition = CGPoint.zero
}

struct BlockBreak: View {
    @State private var blockBreak = BlockModel()
    @State private var timer: Timer?
    @State private var labelText = "Swipe paddle"
    @State private var isClashed: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(){
                VStack{
                    Text("Tiny Fake Block Breaking")
                    HStack{
                        Button("init") {
                            blockBreak.initPosition.x = geometry.frame(in: .local).midX
                            blockBreak.initPosition.y = geometry.frame(in: .local).midY
                            blockBreak.frameSize.width = geometry.frame(in: .local).width*0.95
                            blockBreak.frameSize.height = geometry.frame(in: .local).height*0.8
                            initGame()
                        }
                        Button("start") {
                            if (blockBreak.ballSize > 5){
                                timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
                                    if (blockBreak.position.y + blockBreak.ballSize > blockBreak.initPosition.y + blockBreak.frameSize.height/2){
                                        blockBreak.ballSize = 0
                                        print("game over")
                                        labelText = "Game Over"
                                        timer?.invalidate()
                                    }
                                    
                                    if (intersect(position: blockBreak.blockPosition, size: blockBreak.blockSize, ballPosition: blockBreak.position, ballSize: blockBreak.ballSize)){
                                        blockBreak.deltaY = blockBreak.deltaY * -1
                                        clearBlock()
                                        print("ball clash with block")
                                    }
                                    else if (intersect(position: blockBreak.paddlePosition, size: blockBreak.paddleSize, ballPosition: blockBreak.position, ballSize: blockBreak.ballSize)){
                                        blockBreak.deltaY = blockBreak.deltaY * -1
                                        print("ball clash with paddle")
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
                                DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
                                    print("time out")
                                    labelText = "Time Out"
                                    timer?.invalidate()
                                }
                            }
                            else {
                                print ("too small ball")
                            }
                        }
                        Button("stop") {
                            timer?.invalidate()
                        }
                    }
                    Spacer()
                }
                
                ZStack {
                    if !isClashed {
                        Rectangle()
                            .fill(.brown)
                            .frame(width: blockBreak.blockSize.width, height: blockBreak.blockSize.height)
                            .position(x: blockBreak.blockPosition.x, y: blockBreak.blockPosition.y)
                    }
                    Rectangle()
                        .fill(.green)
                        .frame(width: blockBreak.paddleSize.width, height: blockBreak.paddleSize.height)
                        .position(x: blockBreak.paddlePosition.x, y: blockBreak.paddlePosition.y)
                        .gesture(
                            DragGesture()
                                .onEnded { gesture in
                                    if gesture.translation.width > 0 {
                                        if (blockBreak.paddlePosition.x + blockBreak.paddleSize.width/2 < blockBreak.initPosition.x + blockBreak.frameSize.width/2){
                                            blockBreak.paddlePosition.x += blockBreak.ballSize * 2
                                        }
                                        labelText = "右"
                                    } else {
                                        if (blockBreak.paddlePosition.x - blockBreak.paddleSize.width/2 > blockBreak.initPosition.x - blockBreak.frameSize.width/2){
                                            blockBreak.paddlePosition.x -= blockBreak.ballSize * 2
                                        }
                                        labelText = "左"
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
                    Text(labelText).padding()
                }
            }
        }
    }
    
    
    private func initGame(){
        isClashed = false
        blockBreak.position.x = blockBreak.initPosition.x
        blockBreak.position.y = blockBreak.initPosition.y
        blockBreak.ballSize = 20
        
        blockBreak.deltaX = Int(blockBreak.ballSize * -1)
        blockBreak.deltaY = Int(blockBreak.ballSize)
        
        blockBreak.paddlePosition.x = blockBreak.initPosition.x
        blockBreak.paddlePosition.y = blockBreak.initPosition.y + blockBreak.frameSize.height/2 - blockBreak.ballSize
        blockBreak.paddleSize.width = blockBreak.frameSize.width/4
        blockBreak.paddleSize.height = blockBreak.ballSize
        
        blockBreak.blockPosition.x = blockBreak.initPosition.x
        blockBreak.blockPosition.y = blockBreak.initPosition.y - blockBreak.frameSize.height/3
        blockBreak.blockSize.width = 80
        blockBreak.blockSize.height = blockBreak.ballSize
    }
    
    private func clearBlock(){
        isClashed = true
        blockBreak.blockSize = CGSize.zero
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
