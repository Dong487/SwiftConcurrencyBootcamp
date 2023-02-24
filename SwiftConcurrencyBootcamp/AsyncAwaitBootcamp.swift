//
//  AsyncAwaitBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by DONG SHENG on 2022/5/2.
//

import SwiftUI

class AsyncAwaitBootcampViewModel: ObservableObject{
    
    @Published var dataArray: [String] = []
    
    func addTitle1(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dataArray.append("我來到一個島 線程位置:\(Thread.current)")
        }
    }
    
    func addTitle2(){
        DispatchQueue.global().asyncAfter(deadline:  .now() + 2) {
            let title = "Title2 線程位置: \(Thread.current)"
            
            DispatchQueue.main.async {
                self.dataArray.append(title)
            }
        }
    }
    
    func addAuthor1() async {
        let author1 = "Author1 : \(Thread.current)"
        self.dataArray.append(author1)
        
        // 在還沒加sleep 之前 addAuthor1 也還是在主線程上 執行
        // Task sleep 也是也可能 throw ERROR 所以用 try
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1s 加上_ 是為了方面閱讀 也可以不用加_
        
        let author2 = "Author2 : \(Thread.current)"
//        self.dataArray.append(author2)
        
        // 原本
        // 要回到主線程 添加至 dataArray 不然會有紫色錯誤:(Publishing changes 不允許在 Background threads 上)
        await MainActor.run(body: {
            self.dataArray.append(author2)
            
            let author3 = "Author3 : \(Thread.current)"
            self.dataArray.append(author3)
        })
        
        await addSomething()
    }
    
    func addSomething() async {
        
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2s 加上_ 是為了方面閱讀 也可以不用加_
        
        let something1 = "Something1 : \(Thread.current)"
        await MainActor.run(body: {
            self.dataArray.append(something1)
            
            let something2 = "Something2 : \(Thread.current)"
            self.dataArray.append(something2)
        })
    }
}

struct AsyncAwaitBootcamp: View {
    
    @StateObject private var viewModel = AsyncAwaitBootcampViewModel()
    
    var body: some View {
        List{
            ForEach(viewModel.dataArray ,id: \.self) { data in
                Text(data)
            }
        }
        .onAppear{
            Task{
                await viewModel.addAuthor1()
                
                let finalText = "Final : \(Thread.current)"
                viewModel.dataArray.append(finalText)
            }
//            viewModel.addTitle1()
//            viewModel.addTitle2()
        }
    }
}

struct AsyncAwaitBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        AsyncAwaitBootcamp()
    }
}
