//
//  StructClassActorBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by DONG SHENG on 2022/6/1.
//


/*
 
相關連結:
 https://blog.onewayfirst.com/ios/posts/2019-03-19-class-vs-struct
 https://stackoverflow.com/questions/24217586/structure-vs-class-in-swift-language
 https://medium.com/@vinayakkini/swift-basics-struct-vs-class-31b44ade28ae
 https://stackoverflow.com/questions/24217586/structure-vs-class-in-swift-language/59219141#59219141
 https://stackoverflow.com/questions/27441456/swift-stack-and-heap-understanding
 https://stackoverflow.com/questions/24232799/why-choose-struct-over-class/24232845
 https://www.backblaze.com/blog/whats-the-diff-programs-processes-and-threads/
 https://medium.com/doyeona/automatic-reference-counting-in-swift-arc-weak-strong-unowned-925f802c1b99
 
*/


/*
 備註: 線程 = 執行緒

 VALUE TYPES:
 - Struct, Enum, String, Int, Tuple 等等.
 - Stored in the Stack : 存在 Stack當中
 - Faster : 速度、性能 比 REFERENCE 快  (因為多線程中 每個線程都擁有自己的 Stack -> 保障線程安全)
 - Thread safe : 不會有同時存取的問題
 - When you assign or pass value type a new copy of data is created : 不會使用 "正本"
 
 
 REFERENCE TYPES:
 - Class , Actor , Function
 - Stored in the Heap
 - Slower, but synchronizes : 速度、性能比較慢，但同步 (所有線程中 共享、同步)
 - NOT Thread safe : 可能有同時存取的問題
 - When you assign or pass reference type a new reference to original instance will be created (pointer) : 使用 "正本" 做變動
 
 - - - - - - - - - - - - - - 我 是 分 隔 線 - - - - - - - - - - - - - -
 
 Stack:
 - Stores Value types
 - Variables allocated on the stack are stored directly to the memory,and access to this memory is very fast : 分配的 Variables 直接存在記憶體中，存取速度快
 - Each thread has it's own stack : 每個線程(執行緒中) 都擁有自己的 Stack
 
 
 HEAP:
 - Stores Reference types
 - Shared across thread : 所有線程共享 一個Heap -> 用來同步
 
 - - - - - - - - - - - - - - 我 是 分 隔 線 - - - - - - - - - - - - - -
 
 STRUCT:
 - Based on VALUE
 - Can be mutated
 - Stored in the Stack
 
 
 CLASS:
 - Based on REFERENCE (INSTANCES Ex: URLSession."shared" )
 - Stored in Heap
 - Inherit from other classed : 可以繼承其他 class
 
 ACTOR:
 - Same as Class, but thread safe : 能保證 線程安全 (擁有async await 讀取 heap)
 
 - - - - - - - - - - - - - - 我 是 分 隔 線 - - - - - - - - - - - - - -
 
 使用情境上:
 
 Structs: Data Models, Views
 Class: ViewModels
 Actors: Shared 'Manager' and 'Data Store'
 
*/

import SwiftUI

actor StructClassActorBootcampDataManager{
    
    func getDataFromDatabase(){
        
    }
}

class StructClassActorBootcampViewModel: ObservableObject{
    
    @Published var title: String = ""
    
    init(){
        print("ViewModel INIT")
    }
}

struct StructClassActorBootcamp: View {
    
    @StateObject private var viewModel = StructClassActorBootcampViewModel()
    let isActive: Bool
    
    init(isActive: Bool){
        self.isActive = isActive
        print("View INIT")
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .frame(maxWidth: .infinity ,maxHeight: .infinity)
            .ignoresSafeArea()
            .background(isActive ? Color.brown : Color.indigo)
            .onAppear{
//               runTest()
            }
    }
}

struct StructClassActorBootcampHomeView: View{
    
    @State private var isActive: Bool = false
    
    var body: some View{
        
        StructClassActorBootcamp(isActive: isActive)
            .onTapGesture {
                isActive.toggle()
            }
        
    }
}

struct StructClassActorBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        StructClassActorBootcamp(isActive: false)
    }
}

// ------------------------------------------

//
//
//struct MyStruct{
//    var title: String
//}
//
//class MyClass{
//    var title: String
//
//    init(title: String){
//        self.title = title
//    }
//}

extension StructClassActorBootcamp {
    
    private func runTest(){
        print("Test GOGOGO")
        
        structTest1()
        classTest1()
        actorTest1()
        
//        structTest2()
//        classTest2()
    }
    
    private func structTest1(){
        print("structTest1")
        
        let objectA = MyStruct(title: "Starting title(Struct)")
        print("ObjectA :" , objectA.title)
        
        print("PASS the VALUES of objectA to objectB")
        var objectB = objectA // 這邊objectB 與 A 是分開的 -> 再 Create 一個新的
        print("ObjectB :" , objectB.title)
        
        objectB.title = "Second title"
        print("ObjectB title  Changed 分隔線")
        
        print("ObjectA :" , objectA.title)
        print("ObjectB :" , objectB.title)
        
        print("""
        
        - - - - - - - - - - - - - - - -
        
        """)
    }
    
    private func classTest1(){
        print("classTest1")
        
        let objectA = MyClass(title: "Starting title!(Class)")
        print("ObjectA :" , objectA.title)
        
        print("PASS the REFERENCE of objectA to objectB")
        let objectB = objectA // 這邊指向內存位置 -> 將 B內存位置 指向 A的內存位置
        print("ObjectB :" , objectB.title)
        
        objectB.title = "Second title(Class)"
        print("ObjectB title  Changed 分隔線")
        
        print("ObjectA :" , objectA.title)
        print("ObjectB :" , objectB.title)
        
        print("""
        
        - - - - - - - - - - - - - - - -

        """)
    }
    
    private func actorTest1(){
        // Task 也可以換成 在 func 後方加上 async (actor 需要await 來協調)
        Task{
            print("actorTest1")
            
            let objectA = MyActor(title: "Starting title!(Actor)")
            await print("ObjectA :" , objectA.title)
            
            print("PASS the REFERENCE of objectA to objectB")
            let objectB = objectA // 這邊指向內存位置 -> 將 B內存位置 指向 A的內存位置
            await print("ObjectB :" , objectB.title)
            
//            objectB.title = "Second title(Class)"  // actor 不能在外部更改 所以呼叫func 在actor內部變動
            await objectB.updateTitle(newTitle: "Second title(Actor)!")
            print("ObjectB title  Changed 分隔線")
            
            await print("ObjectA :" , objectA.title)
            await print("ObjectB :" , objectB.title)
            
            print("""
                  
            - - - - - - - - - - - - - - - - - -
                  
            """)
        }
    }
}

// ------------------------------------------

// 等於下方的 MutatingStruct (2者較有性能上的優勢 > customStruct)
// 差別在於 閱讀性、安全性(可以限定 宣告為private var 只藉由Struct內的 init() 做update)
struct MyStruct{
    var title: String
}

// Immutable struct (指結構上 )
struct CustomStruct{
    let title: String
    
    // 建立一個新的 CustomStruct 給值
    func updateTitle(newTitle: String) -> CustomStruct{
        CustomStruct(title: newTitle)
    }
}

struct MutatingStruct{
    private(set) var title: String // 123123 (set)使外部也能更改private
    
    init(title: String){
        self.title = title
    }
    
    mutating func updateTitle(newTitle: String){
        title = newTitle
    }
}

extension StructClassActorBootcamp{
    
    private func structTest2(){
        print("structTest2")
        
        var struct1 = MyStruct(title: "Title1")
        print("Struct1: ", struct1.title)
        struct1.title = "Title2"
        print("Struct1: ", struct1.title)
        
        var struct2 = CustomStruct(title: "Title1")
        print("Struct2: ", struct2.title)
//        struct2.title = "Title2"
        struct2 = CustomStruct(title: "Title2")
        print("Struct2: ", struct2.title)
        
        var struct3 = CustomStruct(title: "Title1")
        print("Struct3: ", struct3.title)
        struct3 = struct3.updateTitle(newTitle: "Title2") // 123123
        print("Struct3: ", struct3.title)
        
        var struct4 = MutatingStruct(title: "Title1")
        print("Struct4: ", struct4.title)
        struct4.updateTitle(newTitle: "Title2")
        print("Struct4: ", struct4.title)
        
        print("""
        
        - - - - - - - - - - - - - - - - - -

        """)
    }
}

// ------------------------------------------

class MyClass{
    var title: String
    
    init(title: String){
        self.title = title
    }
    
    func updateTitle(newTitle: String){
        title = newTitle
    }
}

actor MyActor{
    var title: String
    
    init(title: String){
        self.title = title
    }
    
    func updateTitle(newTitle: String){
        title = newTitle
    }
}

extension StructClassActorBootcamp{
    
    private func classTest2(){
        print("classTest2")
        
        let class1 = MyClass(title: "Title1") // 只對class內指定的值 做變動 不會更改class 結構
        print("Class1: ", class1.title)
        class1.title = "Title2"
        print("Class1: ", class1.title)
        
        let class2 = MyClass(title: "Title1") // 只對class內指定的值 做變動 不會更改class 結構
        print("Class2: ", class2.title)
        class2.title = "Title2"
        print("Class2: ", class2.title)
    }
}
