//
//  SendableBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by DONG SHENG on 2022/6/3.
//

// 情境: 一個 class(not safe) 傳到 acotr
import SwiftUI

actor CurrentUserManager{
    
    func updateDatabase(userInfo: MyClassUserInfo){
        
    }
}
// Sendable: 使 code 能 安全使用 concurrent
struct MyUserInfo: Sendable{
    let name: String
}

// class 要使用 MyUserInfo 必須為 final class
// 通常只能使用 let (var 有可能在別處被更改)
// 若要使用 var 要加上 @unchecked ->告訴編譯器 自行檢查 (但不建議使用)
// 改成 private 加上 lock
final class MyClassUserInfo: @unchecked Sendable{
    private var name: String
    let lock = DispatchQueue(label: "com.MyApp.MyClassUserInfo")
    
    init(name: String){
        self.name = name
    }
    
    func updateName(name: String){
        
        lock.async {
            self.name = name
        }
    }
}

class SendableBootcampViewModel: ObservableObject{
    
    let manager = CurrentUserManager()
    
    func updateCurrentUserInfo() async {
        
        let info = MyClassUserInfo(name: "QQQQQQ")
        
        await manager.updateDatabase(userInfo: info)
    }
}

struct SendableBootcamp: View {
    
    @StateObject private var viewModel = SendableBootcampViewModel()
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .task {
                
            }
    }
}

struct SendableBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        SendableBootcamp()
    }
}
