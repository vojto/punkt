//
//  CollectionDelegate.swift
//  Punkt
//
//  Created by Vojto2 on 11.7.2014.
//  Copyright (c) 2014 rinik. All rights reserved.
//

import Foundation

class CollectionDelegate: NSObject, NSCollectionViewDelegate {
    func collectionView(collectionView: NSCollectionView!, canDragItemsAtIndexes indexes: NSIndexSet!, withEvent event: NSEvent!) -> Bool {
        return true
    }
    
    func collectionView(collectionView: NSCollectionView!, writeItemsAtIndexes indexes: NSIndexSet!, toPasteboard pasteboard: NSPasteboard!) -> Bool {
        var ids: [Int] = []
        indexes.enumerateIndexesUsingBlock() {
            let (index, _) = $0
            let object = collectionView.content[index] as Issue
            ids.append(object.id)
        }
        
        let data = NSKeyedArchiver.archivedDataWithRootObject(ids)
        pasteboard.addTypes(["issues"], owner: nil)
        pasteboard.setData(data, forType: "issues")
        
        collectionView.trigger("drag", data: ids)
        
        return true
    }
    
    func collectionView(collectionView: NSCollectionView!, acceptDrop draggingInfo: NSDraggingInfo!, index: Int, dropOperation: NSCollectionViewDropOperation) -> Bool {
        let pasteboard = draggingInfo.draggingPasteboard()
        let data = pasteboard.dataForType("issues")
        let ids = NSKeyedUnarchiver.unarchiveObjectWithData(data) as [Int]
        println("dropping ids: \(ids)")
        collectionView.trigger("drop", data: ids)
        return true
    }
    
    func collectionView(collectionView: NSCollectionView!, validateDrop draggingInfo: NSDraggingInfo!, proposedIndex proposedDropIndex: UnsafePointer<Int>, dropOperation proposedDropOperation: UnsafePointer<NSCollectionViewDropOperation>) -> NSDragOperation {
        return NSDragOperation.Move;
    }
    
    func collectionView(collectionView: NSCollectionView!, namesOfPromisedFilesDroppedAtDestination dropURL: NSURL!, forDraggedItemsAtIndexes indexes: NSIndexSet!) -> [AnyObject]! {
        println("huh?")
        return []
    }
}