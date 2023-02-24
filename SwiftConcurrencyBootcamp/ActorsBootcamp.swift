//
//  ActorsBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by DONG SHENG on 2022/6/2.
//

// actor 本身 會將內部的變量都變為 async -> 在外部呼叫的時候都要加上 wait等待 進入讀取
/*
  Ex:
    Task{
        await manager.data
    }
 */

import SwiftUI

// 1) What is the problem that actor are solving? : actor用來處理什麼
// 2) How was this problem solved prior to actors? : 在actor 出現之前 所使用的舊方法
// 3) Actors can solve the problem

// (模擬器上) Edit Scheme -> Diagnostics -> Thraed Sanitizer
//

class MyDataManager{
    
    static let instance = MyDataManager()
    private init() { }
    
    var data: [String] = []
    private let lock = DispatchQueue(label: "com.MyApp.MYDataManager") // 要同時訪問的時候 乖乖排隊
    
    // return 改成 completionHandler: @escaping (_ title: String?) -> ()
    func getRandomData(completionHandler: @escaping (_ title: String?) -> () ) {
        
        lock.async {
            self.data.append(UUID().uuidString) // 添加 隨機uuidString 到 dataArray
            print(Thread.current)
            
//            return data.randomElement() // 回傳一項 dataArray中的 隨機元素
            completionHandler(self.data.randomElement())
        }
    }
}

actor MyActorManager{
    
    static let instance = MyActorManager()
    private init() { }
    
    var data: [String] = []
    
    // 可以在前面加上 nonisolated 來標注例外
    nonisolated let myRandomText =  "人之初性本善"
    
    func getRandomData() -> String? {
        
        self.data.append(UUID().uuidString) // 添加 隨機uuidString 到 dataArray
        print(Thread.current)
        
        return data.randomElement()
    }
    
    // 模擬在actor內部 但不需要擔心會 線程衝突的 func
    // 可以在前面加上 nonisolated 來標注例外
    // 在外部呼叫就不須要加上 await
    nonisolated func getSavedData() -> String {
        return "🍤🍤🍤🍤🍤🍤🍤"
    }
}

struct HomeView: View{
    
    let manager = MyActorManager.instance
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.1, tolerance: nil, on: .main, in: .common, options: nil).autoconnect()
    
    
    var body: some View{
        ZStack{
            Color.brown.opacity(0.85).ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }
        .onAppear(perform: {
            // 在 actor 內的 func 加上 nonisolated
            // 所以本身不是 async 也就不需要加上 await
            let newString = manager.getSavedData()
//            Task{
//               let newString = await manager.getSavedData()
//            }
        })
        .onReceive(timer) { _ in
//            // 使用背景線程 run
//            DispatchQueue.global(qos: .background).async {
//                manager.getRandomData { title in
//                    if let data = title{
//                        // 要對View 更動畫面顯示 所以回到主線程
//                        DispatchQueue.main.async {
//                            self.text = data
//                        }
//                    }
//                }
//            }
            Task{
                if let data = await manager.getRandomData(){
                    // 要對View 更動畫面顯示 所以回到主線程 (記得也要加 await)
                    await MainActor.run(body: {
                        self.text = data
                    })
                }
            }
        }
    }
}

struct BrowseView: View{
    
    let manager = MyActorManager.instance
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.01, tolerance: nil, on: .main, in: .common, options: nil).autoconnect()
    
    var body: some View{
        ZStack{
            Color.pink.opacity(0.85).ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }
        .onReceive(timer) { _ in
            // 使用 default 線程 run
//            DispatchQueue.global(qos: .default).async {
//                manager.getRandomData { title in
//                    if let data = title{
//                        // 要對View 更動畫面顯示 所以回到主線程
//                        DispatchQueue.main.async {
//                            self.text = data
//                        }
//                    }
//                }
//            }
            Task{
                if let data = await manager.getRandomData(){
                    // 要對View 更動畫面顯示 所以回到主線程 (記得也要加 await)
                    await MainActor.run(body: {
                        self.text = data
                    })
                }
            }
        }
    }
}


struct ActorsBootcamp: View {
    var body: some View {
        TabView{
            HomeView()
                .tabItem {
                    Label("HOME 🐸 ", systemImage: "house.fill")
                }
            
            BrowseView()
                .tabItem {
                    Label("Browse ", systemImage: "magnifyingglass")
                }
        }
    }
}

struct ActorsBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        ActorsBootcamp()
    }
}
