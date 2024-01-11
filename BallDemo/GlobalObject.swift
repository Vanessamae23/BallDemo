//
//  GlobalObject.swift
//  BallDemo
//
//  Created by MacBook Pro on 11/01/24.
//

import Foundation

class GlobalObject: ObservableObject {
    @Published var name : String = ""
    @Published var balls: [Ball] = []
}
