//
//  BubbleTailShape.swift
//  SwiggyAssignment
//
//  Created by Ayush Goyal on 12/01/26.
//
import SwiftUI

struct BubbleTailShape: Shape {
    var isFromUser: Bool
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        if isFromUser {
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - 4, y: rect.minY))
            path.addQuadCurve(to: CGPoint(x: rect.maxX - 4, y: rect.minY + (rect.height/rect.width)*4), control: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        } else {
            path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX + 4, y: rect.minY))
            path.addQuadCurve(to: CGPoint(x: rect.minX + 4, y: rect.minY + (rect.height/rect.width)*4), control: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        }
        
        return path
    }
}
