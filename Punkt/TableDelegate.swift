//
//  TableDelegate.swift
//  Punkt
//
//  Created by Vojtech Rinik on 18/06/14.
//  Copyright (c) 2014 rinik. All rights reserved.
//

import Foundation
import Cocoa

extension NSGraphicsContext {
    var cgcontext: CGContextRef! {
    if let graphicsPort = NSGraphicsContext.currentContext()?.graphicsPort {
        let opaqueContext = COpaquePointer(graphicsPort)
        return Unmanaged<CGContextRef>.fromOpaque(opaqueContext).takeUnretainedValue()
        }
        return nil
    }
}


class CardView: NSView {
    var color = "6BA3EB"
    let field = Label(frame: NSZeroRect)
    var issue: Issue? {
    didSet {
        if (issue != nil) {
            field.stringValue = "#\(issue!.id) - #\(issue!.title)"
        }
    }
    }
    
    var selected: Bool = false {
    didSet {
        self.needsDisplay = true
    }
    }
    
    override init(frame: NSRect) {
        super.init(frame: frame)
        
        
        field.stringValue = "hello"
        field.textColor = NSColor.whiteColor()
        field.font = NSFont.systemFontOfSize(10.5)
        let shadow = NSShadow()
        shadow.shadowOffset = NSMakeSize(1, 1)
        shadow.shadowBlurRadius = 0
        shadow.shadowColor = NSColor(calibratedWhite: 0, alpha: 0.9)
        addSubview(field)
        
        addConstraint("|-10-[v]-10-|", view: field)
        addConstraint("V:|-10-[v]-10-|", view: field)
        
    }
    
    override func drawRect(dirtyRect: NSRect)  {
        let rect = NSInsetRect(self.bounds, 5, 5)
        let context = NSGraphicsContext.currentContext().cgcontext
        let color2 = selected ? "4d7fbf" : color
        NKSetBorderRadius(context, rect, 3)
        NKDrawGradientWithHexColors(context, rect, color2, color2)
    }
    
    override func mouseDown(theEvent: NSEvent!) {
        color = "5993DE"
        needsDisplay = true
        
        if theEvent.clickCount == 2 {
            // hijack
        } else {
            super.mouseDown(theEvent)
        }
    }
    
    override func mouseUp(theEvent: NSEvent!) {
        color = "6BA3EB"
        needsDisplay = true
        
        
        if theEvent.clickCount == 2 {
            NSWorkspace.sharedWorkspace().openURL(NSURL(string: issue!.url))
        }
    }
}


class CardCollectionItem: NSCollectionViewItem {
    override var representedObject: AnyObject? {
    didSet {
        // TODO: Find out why is this called multiple times
        (self.view as CardView).issue = representedObject as Issue?
    }
    }
    
    override var selected: Bool {
    didSet {
        (self.view as CardView).selected = selected
    }
    }
    
    override func loadView()  {
        let view = CardView(frame: NSZeroRect)
        self.view = view
    }
}

class RowHeaderView: NSView {
    let label = Label(frame: NSZeroRect)
    let row: Row
    
    init(frame: NSRect, row: Row) {
        self.row = row
        
        super.init(frame: frame)
        
        label.stringValue = row.labelName
        label.font = NSFont.boldSystemFontOfSize(11)
        addSubview(label)
        self.addConstraint("|-5-[v]-5-|", view: label)
        self.addConstraint("V:|-5-[v]", view: label)
    }
}


enum OwnerFilter {
    case User
    case Unassigned
    case Others
    
    func description() -> String {
        switch self {
        case User:
            return "User"
        case Unassigned:
            return "Unassigned"
        case Others:
            return "Others"
        }
    }
}

// Table Delegate
class TableDelegate: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    @IBOutlet var tableView : NSTableView!
    @IBOutlet var labelPickerPopover : NSPopover!
    @IBOutlet var labelPicker : LabelPicker!
    @IBOutlet var headerMenu : NSMenu!
    @IBOutlet var ownerMenu: NSMenu!
    @IBOutlet var ownerButton: NSPopUpButton!
    
    var columns: [Column] = []
    var rows: [Row] = []
    var issues: [Issue] = []
    var issuesByIds = Dictionary<Int, Issue>()
    let cardSize = NSSize(width: 180, height: 52)
    let collectionDelegate = CollectionDelegate()
    
    var dragSourceColumn: Column? = nil
    var dragSourceRow: Row? = nil
    var dragSourceCollection: NSCollectionView? = nil
    
    let username = "vojto"
    let password = "millennium"
    let repo = "ugwigr/thinknum_base"
//    let repo = "vojto/rinik"
    let engine: UAGithubEngine
    var ownerFilter = OwnerFilter.User
    
    override init() {
        self.engine = UAGithubEngine(username: username, password: password, withReachability: false)
    }
    
    override func awakeFromNib() {
        MagicalRecord.setupCoreDataStack()
        self.columns = Column.MR_findAll() as [Column]
        
        self.refreshUI()
        
        tableView!.headerView.menu = headerMenu
        tableView!.target = self
        tableView!.doubleAction = "doubleClick"
        
        // Observe changes in database
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "changedObjects", name: NSManagedObjectContextObjectsDidChangeNotification, object: nil)
        
        // Load issues
        loadIssues()
    }
    
    // Loading Github Issues
    
    @IBAction func refresh(sender : AnyObject) {
        loadIssues()
    }
    
    func loadIssues() {
        var assignee = "*"
        
        if ownerFilter == .User {
            assignee = username
        } else if ownerFilter == .Unassigned {
            assignee = "none"
        }
        
        println("Loading issues assigned to: \(assignee)")
        
        engine.openIssuesForRepository(repo, withParameters: ["per_page": "100", "assignee": assignee], success: { result in

            let data = result as [Dictionary<String, AnyObject>]

            let issues = data.map {
                (var item) -> Issue in
                let title = item["title"] as NSString as String
                let labels = item["labels"] as NSArray as [AnyObject] as [Dictionary<String, AnyObject>]
                let url = item["html_url"] as NSString as String
                let id = item["number"] as NSNumber as Int

                let labelNames = labels.map {
                    (var label) -> String in
                    return label["name"] as NSString as String
                }
                
                return Issue(title: title, labels: labelNames, url: url, id: id)
            }
            for issue in issues {
                self.issuesByIds[issue.id] = issue
            }
            self.issues = issues
            self.refreshUI()
            }, failure: { error in
            println("Failed: \(error)")
            });
    }
    
    // Reacting to changes
    
    func changedObjects() {
        refreshUI()
    }
    
    // Renaming columns
    
    func doubleClick() {
        // Clicking on headers
        if tableView.clickedRow == -1 && tableView.clickedColumn >= 1 {
            self.renameColumn(tableView.clickedColumn)
        }
        
        println("Double click \(tableView.clickedRow)x\(tableView.clickedColumn)")
        
        // Clicking on row headers
        if tableView.clickedRow >= 0 && tableView.clickedColumn == 0 {
            self.renameRow(tableView.clickedRow)
        }
    }
    
    func renameColumn(index: Int) {
        let column = columns[index-1]
        
        let colRect = tableView.rectOfColumn(index)
        var rect = tableView.headerView.frame;
        rect.origin.x = colRect.origin.x;
        rect.size.width = colRect.size.width;
        
        labelPicker.item = column
        labelPickerPopover.showRelativeToRect(rect, ofView: tableView.headerView, preferredEdge: 3)
    }
    
    func renameRow(index: Int) {
        let row = rows[index]
        
        let rowRect = tableView.rectOfRow(index)
        let colRect = tableView.rectOfColumn(0)
        
        var rect = rowRect
        rect.size.width = colRect.size.width
        rect.size.height = 20
        
        labelPicker.item = row
        labelPickerPopover.showRelativeToRect(rect, ofView: tableView, preferredEdge: 4)
    }
    
    // Adding columns
    
    @IBAction func addColumn(sender : AnyObject) {
        let col = Column.MR_createEntity() as Column
        col.labelName = "column 1"
    
        NSManagedObjectContext.MR_contextForCurrentThread().MR_saveToPersistentStoreAndWait()
        
        self.refreshUI()
    }
    
    // Adding rows
    
    @IBAction func addRow(sender : AnyObject) {
        let row = Row.MR_createEntity() as Row
        row.labelName = "New row"
        
        save()
        
        self.refreshUI() // Is this necessary if we're bound to 
                         // change event?
    }
    
    
    // Updating table UI from database
    
    func refreshUI() {
        self.columns = Column.MR_findAllSortedBy("weight", ascending: true) as [Column]
        self.rows = Row.MR_findAll() as [Row]
        
        for var i = 0; i < columns.count; i++ {
            let column = columns[i]
            var tableColumn: NSTableColumn
            
//            tableColumn = tableView.tableColumns[i+1] as NSTableColumn
            
            if i+1 >= tableView.tableColumns.count {
                tableColumn = NSTableColumn()
                tableColumn.identifier = "\(i)"
                tableColumn.width = 200.0
                tableView.addTableColumn(tableColumn)
            } else {
                tableColumn = tableView.tableColumns[i+1] as NSTableColumn
            }
            
            let cell = tableColumn.headerCell as NSTextFieldCell
            cell.stringValue = columns[i].labelName
            
            tableView.headerView.needsDisplay = true
        }
        
        tableView.reloadData()
    }
    
    // Table delegate
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        // this will return the number of rows that we have
        //        println("getting number of rows for \(tableView)");
        return rows.count;
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn column: NSTableColumn, row rowIndex: Int) -> NSView? {
        // TODO: Use this to cache views: tableView.makeViewWithIdentifier("view", owner: self)
        
//        println("Building view for column: \(column.identifier) row: \(rowIndex)")
        
        let view = BackgroundView(frame: NSZeroRect)
        
        let index = (tableView.tableColumns as NSArray).indexOfObject(column)
        
        
        if index == 0 {
            if rows.isEmpty {
                return nil
            }
            // First column is special
            let row = self.rows[rowIndex]
            return RowHeaderView(frame: NSZeroRect, row: row)
        }
        
        let columnObject = columns[index-1]
        let rowObject = rows[rowIndex]
        
        let collection = NSCollectionView()
        collection.selectable = true
//        collection.allowsMultipleSelection = true
        collection.delegate = collectionDelegate
        collection.itemPrototype = CardCollectionItem()
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.maxItemSize = cardSize
        collection.minItemSize = cardSize
        collection.registerForDraggedTypes(["issues"])
        
        var ids: [Int]? = nil
        
        collection.on("drag") {
            _ = $0
            self.dragSourceColumn = columnObject
            self.dragSourceRow = rowObject
            self.dragSourceCollection = collection
        }
        collection.on("drop") {
            let ids = $0 as [Int]
            let issues = ids.map { self.issuesByIds[$0]! }
            
            for issue in issues {
                self.moveIssue(issue, sourceColumn: self.dragSourceColumn!, sourceRow: self.dragSourceRow!, targetColumn: columnObject, targetRow: rowObject)
            }
            
            // Manually move item between the two collection views
            self.updateItems(inCollection: self.dragSourceCollection!, fromColumn: self.dragSourceColumn!, fromRow: self.dragSourceRow!)
            self.updateItems(inCollection: collection, fromColumn: columnObject, fromRow: rowObject)
        }
        
        
        updateItems(inCollection: collection, fromColumn: columnObject, fromRow: rowObject)

        view.addSubview(collection)
        
        view.addConstraint("|-0-[v]-0-|", view: collection)
        view.addConstraint("V:|-0-[v]-0-|", view: collection)
        
        return view
    }
    
    func moveIssue(issue: Issue, sourceColumn: Column, sourceRow: Row, targetColumn: Column, targetRow: Row) {
        let removeLabels = [sourceColumn.labelName, sourceRow.labelName]
        let addLabels = [targetColumn.labelName, targetRow.labelName]
        
        for label in removeLabels {
            issue.removeLabel(label)
        }
        for label in addLabels {
            issue.addLabel(label)
        }
        
        // Update issue in GitHub
        println("Updating issue: \(issue.id)")
        engine.replaceAllLabelsForIssue(issue.id, inRepository: repo, withLabels: (issue.labels as NSArray), success: { result in
                println("Editing issue succeeded! \(result)")
            }, failure: { result in
                println("Editing issue failed: \(result)")
            })
    }
    
    func updateItems(inCollection collection: NSCollectionView, fromColumn: Column, fromRow: Row) {
        let issues = self.findIssues(fromColumn, row: fromRow)
        collection.content = issues
    }
    
    func tableView(tableView: NSTableView!, heightOfRow rowIndex: Int) -> CGFloat {
        // Pre kazdy stlpec spocitat, kolko je takych issues, ze patria tomu stlpcu a terajsiemu riadku
        let row = rows[rowIndex]
        var counts: [Float] = []
        for var i = 0; i < columns.count; i++ {
            let column = columns[i]
            // How many columns can we fit into this column?
            let tableColumn = tableView.tableColumnWithIdentifier("\(i)")
            let numberCols = Float(floor(tableColumn.width / cardSize.width))
            
            let issues = self.findIssues(column, row: row)
            let height = Float(issues.count * 50)
            let totalHeight = height / numberCols
            counts.append(totalHeight)
        }
        var max: Float = counts[0]
        for count in counts {
            if count > max { max = count }
        }
        var result = max + 50
        if (result > 1000) {
            result = 200
        }
        if result == 0.0/0.0 {
            result = 50
        }
        return CGFloat(result)
    }
    
    // Dragging columns
    
    func tableView(tableView: NSTableView!, didDragTableColumn tableColumn: NSTableColumn!) {
        var i = 0
        for tableColumn: NSTableColumn in tableView.tableColumns as [NSTableColumn] {
            let index = tableColumn.identifier.toInt()
            println("picking \(index) from \(self.columns)")
            if !index { continue }
            let column = self.columns[index!]
            column.weight = i
            i += 1
        }
        
        save()
    }
    
    // Resizing columns
    
    func tableViewColumnDidResize(notification: NSNotification!) {
        self.reload()
    }
    
    // Reloading
    
    func reload() {
        self.tableView.reloadData()
    }
    
    // Accessing issues
    
    func findIssues(column: Column, row: Row) -> [Issue] {
        let allColumnLabels = (Column.MR_findAll() as [Column]).map { $0.labelName! }
        let allRowLabels = (Row.MR_findAll() as [Row]).map { $0.labelName! }
        
        var filtered: [Issue] = self.issues
        
        func filterByLabel(issues: [Issue], label: String) -> [Issue] {
            return issues.filter {
                ($0.labels as NSArray).containsObject(label)
            }
        }
        
        func filterByNoneOfLabels(issues: [Issue], labels: [String]) -> [Issue] {
            return issues.filter {
                let issueLabels = ($0.labels as NSArray)
//                println("Cant have any of these: \(allColumnLabels)")
//                println("Has these: \(labels)")
                return $.every(labels) { !issueLabels.containsObject($0) }
            }
        }
        
        // Filter out by column label
        if column.labelName != "*" {
            filtered = filterByLabel(filtered, column.labelName)
        } else {
            // Filter out issues that don't have any of existing column names on them
            filtered = filterByNoneOfLabels(filtered, allColumnLabels)
        }
        
        // Filter out by row label
        if row.labelName != "*" {
            filtered = filterByLabel(filtered, row.labelName)
        } else {
            filtered = filterByNoneOfLabels(filtered, allRowLabels)
        }
        
        return filtered
    }
    
    // Saving
    
    func save() {
        NSManagedObjectContext.MR_contextForCurrentThread().MR_saveToPersistentStoreAndWait()
    }
    
    // Filtering issues by owner
    
    
    @IBAction func filterOwner(sender: AnyObject) {
        var mode: OwnerFilter
        switch self.ownerButton.selectedItem.tag {
        case 0:
            mode = OwnerFilter.User
        case 1:
            mode = OwnerFilter.Unassigned
        case 2:
            mode = OwnerFilter.Others
        default:
            mode = OwnerFilter.Others
        }
        
        ownerFilter = mode
        println("Filtering issue by owner: \(mode.description())")
        
        loadIssues()

    }

}
