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
    
    @Environment(\.managedObjectContext) var managedObjectContext: NSManagedObjectContext
    
    var root: Folder?
    var fetchRequest: FetchRequest<Folder>
    var fetchedResults: FetchedResults<Folder> {
        fetchRequest.wrappedValue
    }
    
    //편집 모드 여부
    @State var isEditing = false
    //편집 모드에서 선택한 항목
    @State var selection = Set<Folder>()
    //플로팅 버튼
    @State var showPopUp = false
    
    //초기화
    init(root: Folder? = nil) {
        let appearance = UINavigationBarAppearance()
        //상단 바 불투명
        appearance.configureWithOpaqueBackground()
        //타이틀 색상 및 크기
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white, .font : UIFont.systemFont(ofSize: 25)]
        //배경 색상
        appearance.backgroundColor = UIColor(named: "AccentColor")
        
        let proxy = UINavigationBar.appearance()
        //뒤로가기 화살표 색상
        proxy.tintColor = .white
        //타이틀과 Safe area 합치기
        proxy.standardAppearance = appearance
        //스크롤 했을때 설정 유지
        proxy.scrollEdgeAppearance = appearance
        //스크롤 했을때 하단 바 색상
        UIToolbar.appearance().barTintColor = UIColor(named: "Color")
        
        //폴더 클릭시 경로 저장
        self.root = root
        fetchRequest = FetchRequest(fetchRequest: Folder.getNodes(root: root))
    }
    
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
    func Addalert() {
        
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
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue:            OperationQueue.main) { (notification) in
                //null 체크
                saveAction.isEnabled = textField.text!.count > 0
            }
        })
        showAlert(alert: alert)
    }
    
    //드래그 삭제
    func deleteItem(indexSet: IndexSet) {
        withAnimation{
            indexSet.map {fetchedResults[$0]}.forEach(managedObjectContext.delete)
            order_reset()
            saveItems()
        }
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
    
    //선택 삭제
    private func deleteNumbers() {
        
        for node in selection {
            managedObjectContext.delete(node)
        }
        
        saveItems()
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
                    
                    //모두선택 버튼
                    if(self.isEditing == true){
                        Button(action: {AllChoose()}) {
                            HStack {
                                Image(systemName: fetchedResults.count == selection.count &&
                                      fetchedResults.count != 0 ? "checkmark.circle.fill" : "circle")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(fetchedResults.count == selection.count && fetchedResults.count != 0 ? .green : .gray)
                                    .font(.system(size: 20, weight: .bold, design: .default))
                                    .onTapGesture {AllChoose()}
                                Button(action: {AllChoose()}) {
                                    Text("모두 선택")
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                            }
                        }
                    }
                    
                    //폴더
                    ForEach(fetchedResults, id: \.self) { node in
                        HStack {
                            Image(systemName: node.star ? "star.fill" : "folder")
                                .foregroundColor(node.star ? .yellow : nil)
                            
                            Text("\(node.name)")// \(node.parent?.folderName ?? node.memoName)")
                                .environment(\.managedObjectContext, self.managedObjectContext)
                                .foregroundColor(.primary)
                                .contextMenu /*@START_MENU_TOKEN@*/{
                                    
                                    Button{Changealert(listItem: node)}
                                label:{Label("폴더 이름변경", systemImage: "folder.fill")}
                                    
                                    Button{pin(listItem: node)}
                                label:{Label("폴더 고정", systemImage: "pin.fill")}
                                    
                                    Button{folderStar(listItem: node)}
                                label:{Label(node.star ? "즐겨찾기 취소" : "즐겨찾기 추가",
                                             systemImage: node.star ? "star.slash.fill" : "star.fill")}
                                    
                                }/*@END_MENU_TOKEN@*/
                            self.isEditing ? nil : NavigationLink(destination: MemoList(root: node)) {}.frame(width: 0)
                            
                            Spacer()
                            
                            Text("\(node.children!.count)")
                                .foregroundColor(.gray)
                            
                            node.pin ? Image(systemName: "pin.fill") : nil
                        }
                    }
                    .onMove(perform: moveItem)
                    .onDelete(perform: deleteItem)
                })
            }
            .environment(\.editMode, .constant(self.isEditing ? EditMode.active : EditMode.inactive))
            .animation(Animation.spring(), value: self.isEditing)
            
            //플로팅 버튼
            if isEditing {
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
            }
        }
        
        .navigationBarTitle("DreamNote", displayMode: .inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                //검색 버튼
                NavigationLink(destination: Search()) {
                    topBarIcon(iconName: "magnifyingglass")
                }
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
                    Button(action: {deleteNumbers()}) {
                        trashicon(colorRed: true)
                    }
                }else {
                    NavigationLink(destination: Trash()) {
                        trashicon(colorRed: false)
                    }
                }
                
                Spacer()
                
                if(self.isEditing == true) {
                    Text("\(selection.count)개 선택")
                        .frame(width: 100, alignment: .center)
                }
                
                Spacer()
                
                Button(action: {Addalert()}) {
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
