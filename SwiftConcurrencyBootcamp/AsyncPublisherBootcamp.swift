//
//  AsyncPublisherBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by DONG SHENG on 2022/6/4.
//

import SwiftUI
import Combine

class AsyncPublisherDataManager{
    
    @Published var myData: [String] = []
    
    // 只用 Task.sleep -> 要把這個 func 變 async
    func addData() async {
        myData.append("蚵仔煎")
        try? await Task.sleep(nanoseconds: 2_000_000_000) // sleep 本身 async -> + await 、 throw -> + try?
        myData.append("牛肉燴飯")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("義大利麵")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("滷味")
    }
}

class AsyncPublisherBootcampViewModel: ObservableObject{
    
    // 更動 會影響到畫面UI 回主線程上執行
    @MainActor @Published var dataArray: [String] = []
    let manager = AsyncPublisherDataManager()
    var cancellables = Set<AnyCancellable>()
    
    init(){
      addSubscribers()
    }
    
    private func addSubscribers(){
    
        // 用combine $綁定 同時使用Task 執行Concrrent code
        // 迴圈和 value(較特別用法)
        // 123123
        Task{
            for await value in manager.$myData.values{
                await MainActor.run(body: {
                    self.dataArray = value
                })
                // 不加 break 跳出迴圈的話 將會一直監聽 dataArray 不知道何時會結束
                // (這個後面func 後面的code 就不會執行到)
                // 如果要監聽 2 個事件 -> 再加上另一個 TaskGroup
                break
            }
        }
//        Task{
//            for await value in manager.$myData.values{
//                await MainActor.run(body: {
//                    self.dataArray = value
//                })
//                // 不加 break 跳出迴圈的話 將會一直監聽 dataArray 不知道何時會結束
//                // (這個後面func 後面的code 就不會執行到)
//                // 如果要監聽 2 個事件 -> 再加上另一個 TaskGroup
//                break
//            }
//        }
        
        
        // combine 用法
//        manager.$myData
//            .receive(on: DispatchQueue.main, options: nil)
//            .sink { dataArray in
//                self.dataArray = dataArray
//            }
//            .store(in: &cancellables)
    }
    
    func start() async {
        // manager 在 actor 內 所以是 async
        await manager.addData()
    }
}

struct AsyncPublisherBootcamp: View {
    
    @StateObject private var viewModel = AsyncPublisherBootcampViewModel()
    
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
            await viewModel.start()
        }
    }
}

struct AsyncPublisherBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        AsyncPublisherBootcamp()
    }
}
