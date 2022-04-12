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
        entity: File.entity(),
        sortDescriptors: [NSSortDescriptor(key: "editingDay", ascending: false)],
        predicate: NSPredicate(format: "trash == %@", NSNumber(value: true))
    )var listItems: FetchedResults<File>

    @Environment(\.managedObjectContext) var managedObjectContext:NSManagedObjectContext
    
    @State var selection = Set<File>()
    @State var isEditing = false
    @State var isPresented = false
    
    //휴지통 비우기 alert속성
    private func Empty() {

        let alert = UIAlertController(title: "휴지통 비우기", message: "다시 복구할수 없습니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel) { _ in })
        alert.addAction(UIAlertAction(title: "비우기", style: .destructive) { _ in

            for node in listItems {
                managedObjectContext.delete(node)
            }
            saveItems()
        })
        showAlert(alert: alert)
    }

    //모두되살리기 alert속성
    private func reviveAll() {

        let alert = UIAlertController(title: "모두 되살리기", message: "파일을 모두 되살립니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel) { _ in })
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in

            for node in listItems {
                node.trash = false
                
                node.parent?.childrenCount = (node.parent?.childrenCount ?? 0) + 1
                
            }
            saveItems()
        })

        showAlert(alert: alert)
    }
    
    //삭제 alert속성
    func deleteItem(item: File?) {
        
        let alert = UIAlertController(title: "파일 삭제", message: "파일이 영구 삭제되며\n 되돌릴수 없습니다.\n 정말 삭제하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel) { _ in })
        alert.addAction(UIAlertAction(title:"확인", style: .destructive) { _ in
            withAnimation {
                
                if item != nil {
                    selection.insert(item!)
                }
                
                for node in selection {
                    managedObjectContext.delete(node)
                }

                selection = Set<File>()
                saveItems()
            }
        })
        
        showAlert(alert: alert)
    }
    
    //되살리기 alert속성
    private func revive(item: File?) {

        let alert = UIAlertController(title: "파일 되살리기", message: "선택한 파일을 되살립니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel) { _ in })
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            
            if item != nil {
                selection.insert(item!)
            }
            
            for node in selection {
                node.trash = false
                
                node.parent?.childrenCount = (node.parent?.childrenCount ?? 0) + 1
                
            }
            
            selection = Set<File>()
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
}


//화면
extension Trash: View {
    
    var body: some View {
        
        List(selection: $selection) {
            
            Section(header: HStack{ Text("파일: \(listItems.count)개")
                
            }, content: {
                
                //파일
                ForEach(listItems, id: \.self) { node in
                    HStack {
                        Image(systemName: node.star ? "star.fill" : "doc.text")
                            .foregroundColor(node.star ? .yellow : nil)
                        
                        VStack(alignment: .leading) {
                            Text("\(node.name)")
                                .environment(\.managedObjectContext, managedObjectContext)
                                .foregroundColor(.primary)
                                .contextMenu /*@START_MENU_TOKEN@*/{
                                    Button{deleteItem(item: node)}
                                    label:{Label("영구삭제", systemImage: "trash.fill")}
                                    Button{revive(item: node)}
                                    label:{Label("되살리기", systemImage: "arrow.clockwise.circle")}
                                    
                                }/*@END_MENU_TOKEN@*/
                            Text("\(node.editingDay)").foregroundColor(.gray)
                        }
                        
                        if isEditing == false && node.lock == false {
                            NavigationLink(destination: memoview(root: node, Title: node.name, memo: node.memo)) {}.frame(width: 0)
                        }
                        
                        Spacer()
                        
                        node.pin ? Image(systemName: "pin.fill") : nil
                    }
                    .swipeActions(edge: .leading) {
                        Button(action: {revive(item: node)}) {
                            Image(systemName: "arrow.clockwise.circle")
                        }
                    }.tint(.yellow)
                
                    .swipeActions(edge: .trailing) {
                        Button(action: {deleteItem(item: node)}) {
                            Image(systemName: "trash.fill")
                        }.tint(.red)
                    }
                    
                }
            })
        }
        .environment(\.editMode, .constant(self.isEditing ? EditMode.active : EditMode.inactive))
        .animation(Animation.spring(), value: self.isEditing)
        
        .navigationBarTitle("휴지통")
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button(action: {isEditing ? deleteItem(item: nil) : Empty()}) {
                    trashicon(colorRed: true)
                }
                
                Spacer()
                // isPresented.toggle()
                Button(action: {isEditing ? revive(item: nil) : reviveAll()}) {
                    Image(systemName: "arrow.clockwise.circle")
                        .resizable()
                        .frame(width: 30.0, height: 30.0)
                        .foregroundColor(.yellow)
                }
//                .sheet(isPresented: $isPresented, onDismiss: {
//                    print("Modal dismissed. State: \(self.isPresented)")
//                }, content: {
//                    moveView(fetchRequest: FetchRequest(fetchRequest: Folder.getNodes(root: nil)), showModal: self.$isPresented)
////                    FlightBoardInformation(flight: self.flight)
//                })
            }
        }
        .navigationBarItems(
            trailing:
                
                Button(action: {self.isEditing.toggle()}) {
                    topBarIcon(iconName: isEditing ? "ellipsis.circle.fill" : "ellipsis.circle")
                    
                }
        )
    }
}
