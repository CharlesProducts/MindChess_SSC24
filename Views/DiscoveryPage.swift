//
//  DiscoveryPage.swift
//  MindChess
//
//  Created by Charles de PLUVIÉ on 22/02/2024.
//

import SwiftUI

struct DiscoveryPage: View {
    
    @Binding var showDiscoveryPage : Bool
    @State var showFirstCourse : Bool = false
    
    var body: some View {
        VStack {
            Text("Discovery section")
                .font(.system(size: 40).bold())
                .padding(.top, 100)
            
            ScrollView(.horizontal) {
                HStack(spacing: 20) {
                    self.card()
                        .padding(.leading, 40)
                        .onTapGesture {
                            self.showFirstCourse = true
                        }
                    
                    self.blankCard()
                    
                    self.blankCard()
                }
                .padding()
            }
            .scrollIndicators(.hidden)
            .padding(.top, 130)
            
            Text("This section is not yet complete but you may soon learn more about the techniques and recommendations.")
                .font(.callout)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.top, 60)
            
            Button(action: {
                withAnimation(.easeInOut) {
                    self.showDiscoveryPage = false
                }
            }, label: {
                Text("Done")
                    .padding(.vertical, 20)
                    .padding(.horizontal, 150)
                    .foregroundStyle(Color.white)
                    .background {
                        RoundedRectangle(cornerRadius: 15.0)
                            .foregroundStyle(Color.black.opacity(0.7))
                    }
            })
            .vAlign(.bottom)
            .padding(.bottom, 80)
            
        }
        .vAlign(.center)
        .ignoresSafeArea()
        .background(.ultraThinMaterial)
        .fullScreenCover(isPresented: self.$showFirstCourse) {
            Course1()
        }
    }
    
    @ViewBuilder
    private func card() -> some View {
        VStack {
            ZStack {
                Image(uiImage: UIImage(named: "neurons")!)
                    .resizable()
                    .scaledToFit()
                    .vAlign(.top)
                    .shadow(radius: 5)
                
                VStack {
                    
                    VStack (spacing: 20) {
                        
                        Text("Introduction")
                            .font(.largeTitle.bold())
                            .foregroundStyle(Color.white)
                        
                        Text("How to play in your head")
                            .font(.largeTitle.bold())
                            .foregroundStyle(Color.white)
                            .multilineTextAlignment(.center)
                        
                        Image(systemName: "lock.open.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundStyle(Color.white)
                    }
                    .vAlign(.center)
                    
                    Text("This course aims to help you be able to play more easily in your head (without looking at the game). Not only will this way of playing allow you to facilitate your cerebral visualization, but it will also allow you to maintain your memory and your concentration.")
                        .font(.system(size: 15))
                        .multilineTextAlignment(.leading)
                        .padding()
                }
            }
            
            Spacer()
        }
        .background(Color.white)
        .frame(width: 300, height: 470)
        .clipShape(RoundedRectangle(cornerRadius: 25.0))
        .shadow(radius: 10)
    }

    @ViewBuilder
    private func blankCard() -> some View {
        VStack {
            Text("Come back later for new lessons...")
                .font(.title3.bold())
                .foregroundStyle(Color.white)
                .vAlign(.center)
                .hAlign(.center)
        }
        .background(Color.black.opacity(0.7))
        .frame(width: 300, height: 470)
        .clipShape(RoundedRectangle(cornerRadius: 25.0))
        .shadow(radius: 10)
    }
}

#Preview {
    DiscoveryPage(showDiscoveryPage: .constant(true))
}
