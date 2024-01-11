//
//  ContentView.swift
//  BallDemo
//
//  Created by MacBook Pro on 10/01/24.
//

import SwiftUI

let screenWidth = UIScreen.main.bounds.width
let screenHeight = UIScreen.main.bounds.height


struct ContentView: View {
    @StateObject var ball1 = BallAnimation()
    @StateObject var ball2 = BallAnimation()
    @State var score: Int = 0
    @ObservedObject var globalObject: GlobalObject
    
    var body: some View {
        ZStack {
            ForEach(globalObject.balls) { ball in
                Circle()
                    .fill(RadialGradient(colors: [Color.blue, Color.black.opacity(0.5)], center: .topLeading, startRadius: 70, endRadius: 120))
                    .frame(width: 80, height: 80)
                .position(x: ball.xPosition, y: ball.yPosition)                    }
            Circle()
                .fill(RadialGradient(colors: [Color.red, Color.black.opacity(0.5)], center: .topLeading, startRadius: 70, endRadius: 120))
                .frame(width: 80, height:80)
                .position(x: ball1.xPosition, y: ball1.yPosition)
                .onAppear {
                    ball1.createDisplayLink()
                }
            Text("\(self.globalObject.name)'s score is \(score)")
                .position(x: screenWidth / 2, y: 80).font(.largeTitle)
        }
        .background(Image("Sky").resizable())
        .ignoresSafeArea()
        
        .onChange(of: ball1.xPosition) { newValue in
            checkCollision()
        
        }
    }
    
    // New method to check collision
    func checkCollision() {
        for ball in globalObject.balls {
            let distance = sqrt(pow((ball1.xPosition - ball.xPosition), 2) + pow((ball1.yPosition - ball.yPosition), 2))
            let combinedRadii = 80.0 // Assuming the radius of both balls is 80
            
            if distance < combinedRadii {
                // Collision occurred, handle it as needed
                ball1.reverseX.toggle()
                ball1.reverseY.toggle()
                ball1.steps = Double.random(in: 1...5)
            }
        }
    }
}

class Ball: Identifiable, ObservableObject {
    let id: UUID = UUID()
    var xPosition: CGFloat
    var yPosition: CGFloat
    
    init(xPosition: CGFloat, yPosition: CGFloat) {
        self.xPosition = xPosition
        self.yPosition = yPosition
    }
}

class BallAnimation: ObservableObject, Identifiable {
    
    @Published var xPosition: Double = 40
    @Published var yPosition: Double = 80
    
    var id: UUID = UUID()
    var steps: Double = 5
    var reverseX = false
    var reverseY = false
    
    private var displayLink: CADisplayLink!
    
    func createDisplayLink() {
        if displayLink == nil {
            displayLink = CADisplayLink(target: self, selector: #selector(step))
            displayLink.add(to: .current, forMode: RunLoop.Mode.default)
        }
    }
    
    @objc func step(link: CADisplayLink) {
        if xPosition >= screenWidth - 40 || xPosition < 40 {
            reverseX.toggle()
        }
        
        if yPosition >= screenHeight - 40 || yPosition < 40 {
            reverseY.toggle()
        }
        
        xPosition = reverseX ? xPosition - steps : xPosition + steps
        
        yPosition = reverseY ? yPosition - steps : yPosition + steps
    }
}

struct AnotherView: View {
    @ObservedObject var globalObject = GlobalObject()
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Text("Hi, \(self.globalObject.name)").font(.largeTitle).fontWeight(.bold).foregroundColor(Color.blue)
                    FormBox(globalObject: globalObject)
                }
            }
            .background(Image("Sky"))
            .ignoresSafeArea()
        }
    }
}


struct FormBox: View {
    @ObservedObject var globalObject: GlobalObject
    
    var body: some View {
        VStack(alignment: .center) {
            
            TextField("Name", text: $globalObject.name)
                .frame(height: 30.0)
                .padding(10.0)
                .background(Color(red: 0.1, green: 0.3, blue: 0.8, opacity: 0.2))
                .cornerRadius(15.0)
            
            NavigationLink(destination: ContentView(globalObject: globalObject)) {
                Text("Play Game")
                    .multilineTextAlignment(.center)
                    .padding(10.0)
            }
        }
        .padding(50)
        
    }
}

struct DrawView: View {
    @ObservedObject var globalObject = GlobalObject()
    
    var body: some View {
        NavigationView {
            VStack {
                GeometryReader { geo in
                    ZStack {
                        ForEach(globalObject.balls) { ball in
                            Circle()
                                .fill(RadialGradient(colors: [Color.blue, Color.black.opacity(0.5)], center: .topLeading, startRadius: 70, endRadius: 120))
                                .frame(width: 80, height: 80)
                                .position(x: ball.xPosition, y: ball.yPosition)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Image("Sky"))
                    .onTapGesture { location in
                        let tapLocation = location
                        let ball = Ball(xPosition: tapLocation.x, yPosition: tapLocation.y)
                        globalObject.balls.append(ball)
                    }
                    
                }
                NavigationLink(destination: ContentView(globalObject: globalObject)) {
                    Text("Start")
                        .multilineTextAlignment(.center)
                        .padding(10.0)
                }
            }
            
        }
        
    }
    
}


#Preview {
    
    NavigationView {
        DrawView()
    }
}
