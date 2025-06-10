//
//  View_extension.swift
//  MindChess
//
//  Created by Charles de PLUVIÉ on 12/02/2024.
//

import SwiftUI

struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

extension View {
    func chessBoardStyle(sideSize: CGFloat) -> some View {
        self
            .overlay {
                RoundedRectangle(cornerRadius: 25.0)
                    .stroke(Color(UIColor.blackSideColor), lineWidth: 8)
                    .frame(width: sideSize + 10, height: sideSize)
            }
    }
    
    func hAlign(_ alignement: Alignment) -> some View {
        self
            .frame(maxWidth: .infinity, alignment: alignement)
    }
    
    func vAlign(_ alignement : Alignment) -> some View {
        self
            .frame(maxHeight: .infinity, alignment: alignement)
    }
    
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}
