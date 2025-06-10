//
//  SwiftUIView.swift
//  
//
//  Created by Charles de PLUVIÉ on 25/02/2024.
//

import SwiftUI

struct Course1: View {
    
    @Environment(\.dismiss) var dismiss
    private let course = course1Model()
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack {
                Image(uiImage: UIImage(named: "neurons")!)
                    .resizable()
                    .frame(height: 300)
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 10.0))
                    .shadow(radius: 5)
                    .hAlign(.center)
                    .padding(.top, 40)
                    .overlay {
                        VStack (spacing: 20) {
                            Text("How to play in your head ?")
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                        }
                        .foregroundStyle(Color.white)
                        .vAlign(.center)
                    }
                
                Text("Introduction")
                    .font(.system(size: 50))
                    .fontWeight(.heavy)
                    .padding(.top, 30)
                
                Text(self.course.introduction)
                    .font(.callout)
                    .italic()
                
                // Part 1
                VStack(spacing: 20) {
                    Text(self.course.step1Title)
                        .font(.title.bold())
                        .hAlign(.leading)
                    
                    Text(self.course.step1)
                        .font(.footnote)
                        .hAlign(.leading)
                }
                .padding(.top, 40)
                
                // Part 2
                VStack(spacing: 20) {
                    Text(self.course.step2Title)
                        .font(.title.bold())
                        .hAlign(.leading)
                    
                    VStack(spacing: 10) {
                        Text(self.course.step2SubtitlePart1)
                            .font(.title3.bold())
                            .hAlign(.leading)
                        
                        Text(self.course.step2Part1)
                            .font(.footnote)
                            .hAlign(.leading)
                        
                        Text(self.course.step2SubtitlePart2)
                            .font(.title3.bold())
                            .hAlign(.leading)
                        
                        Text(self.course.step2Part2)
                            .font(.footnote)
                            .hAlign(.leading)
                        
                        Text(self.course.step2Part2_1)
                            .font(.footnote.bold())
                            .multilineTextAlignment(.center)
                            .hAlign(.center)
                            .padding(.top, 10)
                        
                        Text(self.course.step2SubtitlePart3)
                            .font(.title3.bold())
                            .hAlign(.leading)
                        
                        Text(self.course.step2Part3)
                            .font(.footnote)
                            .hAlign(.leading)
                        
                        Text(self.course.step2SubtitlePart4)
                            .font(.title3.bold())
                            .hAlign(.leading)
                        
                        Text(self.course.step2Part4)
                            .font(.footnote)
                            .hAlign(.leading)
                    }
                }
                .padding(.top, 40)
                
                // Part 3
                VStack(spacing: 20) {
                    Text(self.course.step3Title)
                        .font(.title.bold())
                        .hAlign(.leading)
                    
                    Text(self.course.step3)
                        .font(.footnote)
                        .hAlign(.leading)
                }
                .padding(.top, 40)
                
                // Part 4
                VStack(spacing: 20) {
                    Text(self.course.step4Title)
                        .font(.title.bold())
                        .hAlign(.leading)
                    
                    Text(self.course.step4)
                        .font(.footnote)
                        .hAlign(.leading)
                }
                .padding(.top, 40)
                
                // Final Part
                VStack(spacing: 20) {
                    Text(self.course.conclusion)

                    Text(self.course.end)
                }
                .bold()
                .multilineTextAlignment(.center)
                .hAlign(.center)
                .padding(.top, 40)
                
                Button(action: {
                    dismiss()
                }, label: {
                    Text("Finish reading")
                        .font(.title.bold())
                        .foregroundStyle(Color.white)
                        .hAlign(.center)
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 25.0)
                                .foregroundStyle(Color.black)
                        }
                })
                .padding(.vertical, 40)
            }
            .padding(.horizontal, 60)
            .hAlign(.center)
        }
    }
}


public struct course1Model {
    
    public let introduction : String = "This self.course is an introduction aimed at teaching you the basics to be able to play chess blind."
    
    public let step1Title : String = " 1 - Master the rules of the game"
    public let step1 : String = "To be able to play chess blind you must already know how to play chess. So make sure you know the rules of the game, including the particular movements of certain pieces like castling. If you're a complete beginner, there are plenty of courses on the internet to learn the rules and even some strategies if you're curious. \nBefore you start learning your new talent, make sure to play many classic games so that your games are fluid and so you don't have additional doubts later."
    
    public let step2Title : String = "2 - Visualization and Memory Exercises"
    public let step2SubtitlePart1 : String = "Visualization exercise"
    public let step2SubtitlePart2 : String = "Basic positions"
    public let step2SubtitlePart3 : String = "Nomenclature"
    public let step2SubtitlePart4 : String = "Chess piece movements"
    public let step2Part1 : String = "Start by visualizing an empty chessboard and gradually add pieces in your mind."
    public let step2Part2 : String = "Now try to visualize and memorize the starting positions of the different pieces. Know how to answer the following different questions :"
    public let step2Part2_1 : String = "Which room is next to this room? \nWhat color is this piece on? \nHow many squares between the two camps? \n..."
    public let step2Part3 : String = "Learn the nomenclature of the squares on the board (eg: a1, h8, etc.). This will be the basis of blind games because you will be able to put a name to your actions/movements. Once you have understood the logic of this nomenclature, try to question the starting position of the different pieces as well as the possible arriving positions."
    public let step2Part4 : String = "Now is the time to start imagining different types of travel. To do this, visualize the possible movements for each type of piece from each square of the chessboard. \nTo practice, you can for example try to play only one color in order to set up your dream defense."
    
    public let step3Title : String = "Play against yourself"
    public let step3 : String = "You normally start to get impatient to play for real. Well it’s now ! If you wish, you can first set up a chess board in front of you and play a game against yourself without touching the pieces. Announce each move out loud on each side and try to make as many moves as possible. This method is not popular with everyone but you may find it useful."
    
    public let step4Title : String = "Single Blind Matches"
    public let step4 : String = "Now it’s clear there is no more board. Well yes, but in your head ha ha. \nThe first part will be to try to play a game (complete if possible) in your head and write down the moves on a paper. \nAnd secondly, you will be able to recheck your game with a chess board or chess software in order to examine visualization errors."
    
    public let conclusion : String = "Arriving here, I already say congratulations because you have just had a great stage."
    public let end : String = "So continue to train to be faster and faster and be ready while waiting for new lessons !"
}

#Preview {
    Course1()
}
