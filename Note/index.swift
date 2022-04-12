//
//  ContentView.swift
//  Note
//
//  Created by Dream on 2020/10/23.
//
//
import SwiftUI
import CoreData

struct index {
    
    @FetchRequest(
        entity: Folder.entity(),
        sortDescriptors: [NSSortDescriptor(key: "order", ascending: true)]
    )var fetchedResults: FetchedResults<Folder>
    
    @Environment(\.managedObjectContext) var managedObjectContext: NSManagedObjectContext
    
    //편집 모드 여부
    @State var isEditing = false
    //편집 모드에서 선택한 항목
    @State var selection = Set<Folder>()
    //플로팅 버튼
    @State var showPopUp = false
    
    //이름변경 alert속성
    private func Changealert(listItem: Folder?) {
        
        let alert = UIAlertController(title: "폴더 이름변경", message: "변경할 폴더의 이름을 입력해주세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        let saveAction = UIAlertAction(title:"완료", style: .default, handler: { (action) -> Void in
            withAnimation {
                listItem!.name = (alert.textFields?[0].text)!
                saveItems()
            }
            
        })
        alert.addAction(saveAction)
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "변경할 이름"
            textField.text = listItem?.name
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField,
                                                   queue: OperationQueue.main) { (notification) in
                //null 체크
                saveAction.isEnabled = textField.text!.count > 0
            }
        })
        
        showAlert(alert: alert)
    }
    
    //폴더 새로만들기 alert속성
    func addAlert() {
        
        let alert = UIAlertController(title: "폴더 새로만들기", message: "폴더의 이름을 입력해주세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        let saveAction = UIAlertAction(title:"완료", style: .default, handler: { (action) -> Void in
            withAnimation {
                let node = Folder(context: managedObjectContext)
                
                node.name = (alert.textFields?[0].text)!
                node.order = (fetchedResults.last?.order ?? -1) + 1
                
                saveItems()
            }
        })
        alert.addAction(saveAction)
        alert.addTextField(configurationHandler: { (textField) in
            saveAction.isEnabled = false
            textField.placeholder = "폴더 이름"
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) { (notification) in
                //null 체크
                saveAction.isEnabled = textField.text!.count > 0
            }
        })
        showAlert(alert: alert)
    }
    
    //삭제 alert속성
    func deleteItem() {
        
        let alert = UIAlertController(title: "폴더 삭제", message: "하위 파일까지 모두 영구 삭제되며\n 되돌릴수 없습니다.\n 정말 삭제하시겠습니까?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { (action) -> Void in selection = Set<Folder>()}))
        let saveAction = UIAlertAction(title:"확인", style: .destructive, handler: { (action) -> Void in
            withAnimation {
                
                for node in selection {
                    managedObjectContext.delete(node)
                }

                selection = Set<Folder>()
                order_reset()
                saveItems()
            }
        })
        alert.addAction(saveAction)
        
        showAlert(alert: alert)
    }
    
    //고정
    func pin(listItem: Folder?) {
        withAnimation {
            listItem?.pin.toggle()
            
            order_reset()
            saveItems()
        }
    }
    
    //순서변경
    func moveItem(indexSet: IndexSet, destination: Int) {
        withAnimation {
            let source = indexSet.first!
            
            if source < destination {
                
                var startIndex = source + 1
                let endIndex = destination - 1
                var startOrder = fetchedResults[source].order
                while startIndex <= endIndex {
                    fetchedResults[startIndex].order = startOrder
                    startOrder = startOrder + 1
                    startIndex = startIndex + 1
                }
                fetchedResults[source].order = startOrder
            } else if destination < source {
                var startIndex = destination
                let endIndex = source - 1
                var startOrder = fetchedResults[destination].order + 1
                let newOrder = fetchedResults[destination].order
                while startIndex <= endIndex {
                    fetchedResults[startIndex].order = startOrder
                    startOrder = startOrder + 1
                    startIndex = startIndex + 1
                }
                fetchedResults[source].order = newOrder
            }
            saveItems()
            order_reset()
        }
    }
    
    //저장
    func saveItems() {
        do {
            try managedObjectContext.save()
        } catch {
            print(error)
        }
    }
    
    //선택 고정
    func pinNumbers() {
        
        for node in selection {
            node.pin.toggle()
        }
        
        order_reset()
        saveItems()
        selection = Set<Folder>()
    }
    
    //선택 즐겨찾기
    func starNumbers() {
        
        for node in selection {
            node.star.toggle()
        }
        
        saveItems()
        selection = Set<Folder>()
    }
    
    
    //순서 리셋
    func order_reset() {
        var count = 0
        order_reset_folder(pin: true)
        order_reset_folder(pin: false)
        
        saveItems()
        
        func order_reset_folder(pin: Bool) {
            for node in fetchedResults {
                if node.pin == pin {
                    node.order = count
                    count = count + 1
                }
            }
        }
    }
    
    //모두선택
    func AllChoose() {
        if fetchedResults.count != selection.count{
            selection = Set<Folder>(fetchedResults)
        }else{
            selection = Set<Folder>()
        }
    }
}

//화면
extension index: View {
    
    var body: some View {
        ZStack {
            
            List(selection: $selection) {

                Section(header: Text("폴더에 상관없이 모든 파일을 볼 수 있습니다.")
                        , content: {

                    Text("모든 파일")
                        .bold()
                        .foregroundColor(.primary)
                        .background(NavigationLink(destination: MemoList()){})
                })

                Section(header: Text("폴더: \(fetchedResults.count)개"), content: {
                    
                    if isEditing {
                        //모두선택 버튼
                        Button(action: {}) {
                            Button(action: {AllChoose()}) {
                                Image(systemName: fetchedResults.count == selection.count &&
                                      fetchedResults.count != 0 ? "checkmark.circle.fill" : "circle")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(fetchedResults.count == selection.count && fetchedResults.count != 0 ? .green : .gray)
                                    .font(.system(size: 20, weight: .bold, design: .default))
                                
                                Text("모두 선택")
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                        }
                    }

                    //폴더
                    ForEach(fetchedResults, id: \.self) { node in
                        HStack {
                            Image(systemName: node.star ? "star.fill" : "folder")
                                .foregroundColor(node.star ? .yellow : nil)

                            Text("\(node.name)")
                                .environment(\.managedObjectContext, self.managedObjectContext)
                                .foregroundColor(.primary)
                                .background(self.isEditing ? nil : NavigationLink(destination: MemoList(root: node)){})
                                .contextMenu /*@START_MENU_TOKEN@*/{
                                    
                                    Button{Changealert(listItem: node)}
                                    label:{Label("폴더 이름변경", systemImage: "folder.fill")}
                                    
                                    Button{pin(listItem: node)}
                                    label:{Label("폴더 고정", systemImage: "pin.fill")}
                                    
                                    Button{folderStar(listItem: node)}
                                    label:{Label(node.star ? "즐겨찾기 취소" : "즐겨찾기 추가",
                                                 systemImage: node.star ? "star.slash.fill" : "star.fill")}
                                    
                                }/*@END_MENU_TOKEN@*/
                            
                                .swipeActions(edge: .leading) {
                                    Button(action: {pin(listItem: node)}) {
                                        Image(systemName: node.pin ? "pin.slash.fill" : "pin.fill")
                                    }
                                }.tint(.blue)
                            
                                .swipeActions(edge: .trailing) {
                                    Button(action: {selection.insert(node); deleteItem()}) {
                                        Image(systemName: "trash.fill")
                                    }.tint(.red)
                                    Button(action: {folderStar(listItem: node)}) {
                                        Image(systemName: node.star ? "star.slash.fill" : "star.fill")
                                    }.tint(.yellow)
                                }

                            Spacer()

                            Text("\(node.childrenCount)")
                                .foregroundColor(.gray)

                            node.pin ? Image(systemName: "pin.fill") : nil
                        }
                    }
                    .onMove(perform: moveItem)
                })
            }
            .environment(\.editMode, .constant(self.isEditing ? EditMode.active : EditMode.inactive))
            .animation(Animation.spring(), value: self.isEditing)
            
            //플로팅 버튼
            ZStack {
                if showPopUp {
                    HStack(spacing: 20) {
                        
                        Button(action: {pinNumbers()}) {
                            floting(iconName: "pin.circle.fill")
                        }
                        Button(action: {starNumbers()}) {
                            floting(iconName: "star.circle.fill")
                        }
                    }
                    .transition(.scale)
                    .offset(y: -50)
                }
                ZStack {
                    Circle()
                        .foregroundColor(.white)
                        .frame(width: 45.0, height: 45.0)
                        .shadow(radius: 4)
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40.0, height: 40.0)
                        .foregroundColor(Color("AccentColor"))
                        .rotationEffect(Angle(degrees: showPopUp ? 135 : 0))
                }
                .onTapGesture {
                    withAnimation {
                        showPopUp.toggle()
                    }
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
             .transition(AnyTransition.opacity.animation(.easeInOut))
             .opacity(isEditing ? 1.0 : 0.0)
             .animation(Animation.spring(), value: self.isEditing)
        }
        
        .navigationBarTitle("DreamNote", displayMode: .inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                //편집 버튼
                Button(action: {
                    isEditing.toggle();selection = Set<Folder>();showPopUp = false
                }) {
                    topBarIcon(iconName: isEditing ? "ellipsis.circle.fill" : "ellipsis.circle")
                }
            }
            
            ToolbarItemGroup(placement: .bottomBar) {
                
                //휴지통
                if self.isEditing == true {
                    Button(action: {deleteItem()}) {
                        trashicon(colorRed: true)
                    }
                }else {
                    NavigationLink(destination: Trash()) {
                        trashicon(colorRed: false)
                    }
                }
                
                Spacer()
                
                Text("\(selection.count)개 선택")
                    .frame(width: 100, alignment: .center)
                    .opacity(isEditing ? 1.0 : 0.0)
                    .animation(Animation.spring(), value: self.isEditing)
                
                Spacer()
                
                Button(action: {addAlert()}) {
                    Image(systemName: "folder.badge.plus")
                        .resizable()
                        .frame(width: 40.0, height: 30.0)
                        .foregroundColor(.gray)
                }
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onDisappear {saveItems()}
    }
}
