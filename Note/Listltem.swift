//
//  Listltem.swift
//  Note
//
//  Created by Dream on 2020/11/13.
//

import CoreData

class File: NSManagedObject {
    @NSManaged var children: NSSet?
    @NSManaged var parent: Folder?
    
    //파일 순서
    @NSManaged var order: Int
    
    //모든 파일 순서
    @NSManaged var allOrder: Int
    
    //파일 내용
    @NSManaged var memo: String
    
    //파일 이름
    @NSManaged var name: String
    
    //생성일
    @NSManaged var creationDate: String
    
    //편집일
    @NSManaged var editingDay: String
    
    //고정
    @NSManaged var pin: Bool
    
    //즐겨찾기
    @NSManaged var star: Bool
    
    //파일잠금
    @NSManaged var lock: Bool
    
    //휴지통
    @NSManaged var trash: Bool
}

extension File {
    static func getNodes(root: Folder? ) -> NSFetchRequest<File> {
        let request = File.fetchRequest() as! NSFetchRequest<File>
        
        if root == nil {
            
            request.sortDescriptors = [NSSortDescriptor(key: "allOrder", ascending: true)]
            request.predicate = NSPredicate(format: "trash = %@", NSNumber(value: false))
            
        } else {
            
            request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
            request.predicate = NSPredicate(format: "parent = %@ && trash = %@", root ?? NSNull(), NSNumber(value: false))
            
        }
        return request
    }
}

class Folder: NSManagedObject {
    @NSManaged var children: NSSet?
    
    //폴더 이름
    @NSManaged var name: String
    
    //폴더 순서
    @NSManaged var order: Int
    
    //고정
    @NSManaged var pin: Bool
    
    //즐겨찾기
    @NSManaged var star: Bool
    
    //파일 갯수
    @NSManaged var childrenCount: Int
}

extension Folder {
    static func getNodes(root: Folder? ) -> NSFetchRequest<Folder> {
        let request = Folder.fetchRequest() as! NSFetchRequest<Folder>
        
        request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        
        
        return request
    }
}
