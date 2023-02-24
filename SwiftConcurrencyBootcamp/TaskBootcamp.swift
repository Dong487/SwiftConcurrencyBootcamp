//
//  TaskBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by DONG SHENG on 2022/5/5.
//

// 1) 優先順序 不見得會按照rawValue
// 2) .task 的概念 (onAppear + Task)
// 3) 若有 執行時間較長的 func、迴圈 可以在裡面設置檢查點 正在run時 檢查.task是否已經被取消
//    如果執行過程中取消 會 throw error


import SwiftUI

class TaskBoocampViewModel: ObservableObject{
    
    @Published var image: UIImage? = nil
    @Published var image2: UIImage? = nil
    
    func fetchImage() async {
        
        try? await Task.sleep(nanoseconds: 5_000_000_000) // 5s
        do {
            guard let url = URL(string: "https://picsum.photos/1000") else { return }
            let (data ,_ ) = try await URLSession.shared.data(from: url, delegate: nil)
            
            await MainActor.run(body: {
                self.image = UIImage(data: data)
                print("回到主線程 獲取圖片成功")
            })
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchImage2() async {
        do {
            guard let url = URL(string: "https://picsum.photos/1000") else { return }
            let (data ,_ ) = try await URLSession.shared.data(from: url, delegate: nil)
            
            await MainActor.run(body: {
                self.image2 = UIImage(data: data)
            })
            
        } catch {
            print(error.localizedDescription)
        }
    }
}
struct TaskBootcampHomeView: View{
    
    var body: some View{
        NavigationView{
            ZStack{
                NavigationLink("SBBBBBBB 🐳🐳🐳") {
                    TaskBootcamp()
                }
            }
        }
    }
}

struct TaskBootcamp: View {
    
    @StateObject private var viewModel = TaskBoocampViewModel()
    // 假設 在 viewmodel 內 只需要 var 就好   不需要@Published
    @State private var fetchImageTask: Task<(), Never>? = nil
    
    var body: some View {
        VStack(spacing: 40){
            if let image = viewModel.image{
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
            
            if let image = viewModel.image2{
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        .task {
            await viewModel.fetchImage()
        }
        // 畫面消失時
//        .onDisappear{
//            fetchImageTask?.cancel() // Task 取消
//        }
//        .onAppear {
//            // 不同 Task(沒給優先順序) -> 分別同時執行。
//            // 若在同一個 Task 內 fetch 則會等待前面獲取data完 才會執行後面的程式碼
//            fetchImageTask = Task{
//                print(Thread.current)   // 目前的線程
//                print(Task.currentPriority) // Task 優先順序
//                await viewModel.fetchImage()
//            }
//
////            Task{
////                print(Thread.current)   // 目前的線程
////                print(Task.currentPriority) // Task 優先順序
////                await viewModel.fetchImage2()
////            }
//
////            Task(priority: .high) {
//////                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2s
////                await Task.yield() // 可以禮讓 已經完成的先發布 ?
////                print("優先順序 High : \(Thread.current) - \(Task.currentPriority) ") // 25
////            }
////            Task(priority: .userInitiated) {
////                print("優先順序 UserInitiated : \(Thread.current) - \(Task.currentPriority) ") // 25
////            }
////            Task(priority: .medium) {
////                print("優先順序 Medium : \(Thread.current) - \(Task.currentPriority) ") // 21
////            }
////
////            Task(priority: .low) {
////                print("優先順序 LOW : \(Thread.current) - \(Task.currentPriority) ") // 17
////            }
////
////            Task(priority: .utility) {
////                print("優先順序 Utility : \(Thread.current) - \(Task.currentPriority) ") // 17
////            }
////
////            Task(priority: .background) {
////                print("優先順序 Background : \(Thread.current) - \(Task.currentPriority) ") // 9
////            }
//
//
////            Task(priority: .userInitiated) {
////                print("優先順序 UserInitiated : \(Thread.current) - \(Task.currentPriority) ") // 25
////
////                // detached 可以使 Task脫離繼承的優先順序(userInitiated)
////                // 不建議使用
////                Task.detached{
////                    print("detached : \(Thread.current) - \(Task.currentPriority) ")
////                }
////            }
//        }
    }
}

struct TaskBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        TaskBootcamp()
    }
}
