//
//  moveView.swift
//  DreamNote
//
//  Created by dream on 2022/04/08.
//

import SwiftUI
//DataBase
import CoreData

struct moveView {
    
    @FetchRequest(
        entity: File.entity(),
        sortDescriptors: [NSSortDescriptor(key: "allOrder", ascending: true)],
        predicate: NSPredicate(format: "trash == %@", NSNumber(value: true))
    )var listItems: FetchedResults<File>
    
    @Environment(\.managedObjectContext) var managedObjectContext: NSManagedObjectContext
    
    var fetchRequest: FetchRequest<Folder>
    var fetchedResults: FetchedResults<Folder> {
        fetchRequest.wrappedValue
    }
    
    @Binding var showModal: Bool
    
    //폴더 새로만들기 alert속성
    func Addalert(parent: Folder?) {
        
        let alert = UIAlertController(title: "해당 폴더로 이동", message: "정말 \"\(parent?.name ?? "모든 파일")\" 폴더로 이동 시키겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        let saveAction = UIAlertAction(title:"확인", style: .default, handler: { (action) -> Void in
            withAnimation {
                
                for node in listItems {
                    
                    node.trash = false
                    node.parent = parent
                    if parent != nil {
                        parent!.childrenCount = parent!.childrenCount + 1
                    }
                    
                }
                saveItems()
//                disabled(true)
            }
        })
        alert.addAction(saveAction)
        showAlert(alert: alert)
    }
    
    //저장
    func saveItems() {
        do {
            try managedObjectContext.save()
        } catch {
            print(error)
        }
    }
    
}

//화면
extension moveView: View {
    
    var body: some View {
        
        NavigationView {
            
            List() {
                
                Section(header: Text("폴더에 상관없이 모든 파일을 볼 수 있습니다.")
                        , content: {
                    
                    Button(action: {Addalert(parent: nil)}) {
                        Text("모든 파일")
                            .bold()
                            .foregroundColor(.primary)
                    }
                })
                
                Section(header: Text("폴더: \(fetchedResults.count)개"), content: {
                    
                    //폴더
                    ForEach(fetchedResults, id: \.self) { node in
                        HStack {
                            Image(systemName: node.star ? "star.fill" : "folder")
                                .foregroundColor(node.star ? .yellow : nil)
                            
                            Text("\(node.name)")
                                .environment(\.managedObjectContext, self.managedObjectContext)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text("\(node.childrenCount)")
                                .foregroundColor(.gray)
                            
                            node.pin ? Image(systemName: "pin.fill") : nil
                        }.background(Button(action: {Addalert(parent: node)}){})
                    }
                })
            }
            
            .navigationBarTitle(Text("이동할 폴더 선택"), displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {self.showModal = false}) {
                Text("취소").bold()
            })
        }
        .onDisappear {saveItems()}
    }
}
