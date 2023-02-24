//
//  GlobalActorBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by DONG SHENG on 2022/6/3.
//

// nonisolated <- 相反 -> Global

import SwiftUI

// struct 可以替換成 final class (不會被繼承)
@globalActor struct MyFirstGlobalActor{
    
    static var shared = MyNewDataManager()
}

actor MyNewDataManager{
 
    func getDataFromDatabase() -> [String] {
        return ["one","2222222","3333333","站著穿" , "🦊"]
    }
}

// @MainActor class (需要的話)
class GlobalActorBootcampViewModel: ObservableObject{
    
    // @MainActor 也可以 (同時強制回到主線程上 執行: 常用於接收到background的資料後 傳至主畫面 更新View)
    // 若同時有多個 dataArray 需要使用 @MainActor 則可以加在 class 前面 (全都會變成MainActor)
    @MainActor @Published var dataArray: [String] = []
    let manager = MyFirstGlobalActor.shared
    
    
    // 加入MyFirstGlobalActor 的func 現在也是 actor (需要await) -> 也是可以加在 let、var 上
    // @MainActor 也可以 (同時強制回到主線程上 執行: 常用於接收到background的資料後 傳至主畫面 更新View)
    @MyFirstGlobalActor func getData() {
        
        // 主 View 的 .task 使 這個 func 成為第一個主要運行的
        // 但通常不會希望 這邊的起始任務 造成 MainActor、 主線程 的堵塞
        Task{
            let data = await manager.getDataFromDatabase()
            // 因為dataArray 被宣告 @MainActor 所以這裡也要在主線程上執行
            await MainActor.run(body: {
                self.dataArray = data
            })
            
        }
    }
    
}

struct GlobalActorBootcamp: View {
    
    @StateObject private var viewModel = GlobalActorBootcampViewModel()
    
    var body: some View {
        ScrollView{
            VStack{
                ForEach(viewModel.dataArray, id: \.self) {
                    Text($0)
                        .font(.headline)
                }
            }
        }
        .task {
            await viewModel.getData()
        }
    }
}

struct GlobalActorBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        GlobalActorBootcamp()
    }
}
