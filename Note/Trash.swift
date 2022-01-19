//
//  Trash.swift
//  Note
//
//  Created by dream on 2021/06/04.
//

import SwiftUI
import CoreData

struct Trash {

    @FetchRequest(
        entity: TreeNode.entity(),
        sortDescriptors: [NSSortDescriptor(key: "order", ascending: true)]
    )var listItems: FetchedResults<TreeNode>

    @Environment(\.managedObjectContext) var managedObjectContext:
        NSManagedObjectContext

    var root: Folder?
    var fetchRequest: FetchRequest<TreeNode>
    var fetchedResults: FetchedResults<TreeNode> {
        fetchRequest.wrappedValue
    }

    init(root: Folder? = nil) {
        self.root = root
        fetchRequest = FetchRequest(fetchRequest: TreeNode.getNodes(root: root))
    }

    @State var selection = Set<TreeNode>()
    @State var isEditing = false

    //휴지통 비우기 alert속성
    private func Empty() {

        let alert = UIAlertController(title: "휴지통 비우기", message: "다시 복구할수 없습니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel) { _ in })
        alert.addAction(UIAlertAction(title: "비우기", style: .destructive) { _ in

            for node in listItems {
                if node.trash == true{
                    managedObjectContext.delete(node)
                }
            }
            saveItems()
        })
        showAlert(alert: alert)
    }

    //모두되살리기 alert속성
    private func reviveAll() {

        let alert = UIAlertController(title: "모두 되살리기", message: "메모를 모두 되살립니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel) { _ in })
        alert.addAction(UIAlertAction(title: "살리기", style: .default) { _ in

            for node in listItems {
                if node.trash == true{
                    node.trash = false
                }
            }
            saveItems()
        })

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

    //선택 삭제
    private func deleteNumbers() {
        for node in selection {
            managedObjectContext.delete(node)
        }
            
        saveItems()
    }

    //드래그 삭제
    func deleteItem(indexSet: IndexSet) {
        indexSet.map { listItems[$0] }.forEach(managedObjectContext.delete)
        saveItems()
    }
}


//화면
extension Trash: View {
    
    var body: some View {

        List(selection: $selection) {

            Section(header: HStack{ Text("파일: \(fetchedResults.count)개")

            }, content: {
                    
                //고정 파일
                ForEach(listItems, id: \.self) { node in
                    if node.trash == true && node.pin == true{
                        HStack {
 
                            Image(systemName: node.star ? "star.fill" : "doc.text")
                                .foregroundColor(node.star ? .yellow : nil)
                            VStack(alignment: .leading) {
                                Text("\(node.memoName)")
                                    .bold()
                                    .environment(\.managedObjectContext, self.managedObjectContext)
                                    .foregroundColor(Color.primary)
                                    .contextMenu /*@START_MENU_TOKEN@*/{
                                        Button(action: {}) {
                                            Text("삭제")
                                            Image(systemName: "trash.fill")
                                                .foregroundColor(.red)
                                        }
                                        Button(action: {}) {
                                            Text("되살리기")
                                            Image(systemName: "arrow.clockwise.circle")
                                                .foregroundColor(.yellow)
                                        }
                                    }/*@END_MENU_TOKEN@*/
                                Text("\(node.editingDay)").foregroundColor(.gray)
                            }
                                                
                            self.isEditing ? nil : NavigationLink(destination: memoview(root: node, Title: node.memoName, memo: node.memo)) {}.frame(width: 0)
                                            
                            Spacer()

                            Image(systemName: "pin.fill")
                                .foregroundColor(.primary/*@END_MENU_TOKEN@*/)

                        }
                    }
                }
                .onDelete(perform: deleteItem)
                    
                //고정 해제 파일
                ForEach(listItems, id: \.self) { node in
                    if node.trash == true && node.pin == false {
                        HStack {
                            Image(systemName: node.star ? "star.fill" : "doc.text")
                                .foregroundColor(node.star ? .yellow : nil)

                            VStack(alignment: .leading) {

                            Text("\(node.memoName)")
                                .bold()
                                .environment(\.managedObjectContext, self.managedObjectContext)
                                .foregroundColor(Color.primary)
                                .contextMenu /*@START_MENU_TOKEN@*/{
                                    Button(action: {}) {
                                        Text("삭제")
                                        Image(systemName: "trash.fill")
                                            .foregroundColor(.red)
                                    }
                                    Button(action: {}) {
                                        Text("되살리기")
                                        Image(systemName: "arrow.clockwise.circle")
                                            .foregroundColor(.yellow)
                                    }
                                }/*@END_MENU_TOKEN@*/
                                Text("\(node.editingDay)").foregroundColor(.gray)
                            }
                            self.isEditing ? nil : NavigationLink(destination: memoview(root: node, Title: node.memoName, memo: node.memo)) {}.frame(width: 0)
                        }
                    }
                }
                .onDelete(perform: deleteItem)
            })
        }
        .environment(\.editMode, .constant(self.isEditing ? EditMode.active : EditMode.inactive)).animation(Animation.spring(), value: self.isEditing)
        .listStyle(InsetGroupedListStyle())
        
        .navigationBarTitle("휴지통")
        .toolbar {
           ToolbarItemGroup(placement: .bottomBar) {
               Button(action: {isEditing ? deleteNumbers() : Empty()}) {
                   trashicon(colorRed: true)
               }

               Spacer()

               Button(action: {reviveAll()}) {
                   Image(systemName: "arrow.clockwise.circle")
                       .resizable()
                       .frame(width: 30.0, height: 30.0)
                       .foregroundColor(.yellow)
               }
           }
        }
        .navigationBarItems(
            //편집 눌렀을때
            trailing:
                HStack{
                    //검색 버튼
                    NavigationLink(destination: Search()) {
                        topBarIcon(iconName: "magnifyingglass")
                    }

                    Button(action: {self.isEditing.toggle()}) {
                        topBarIcon(iconName: isEditing ? "ellipsis.circle.fill" : "ellipsis.circle")
                    }
            
                }
        )
    }
}
