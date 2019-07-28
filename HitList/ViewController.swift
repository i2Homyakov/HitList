//
//  ViewController.swift
//  HitList
//
//  Created by Max Zasov on 27/07/2019.
//  Copyright © 2019 Max Zasov. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    // MARK: - Outlets

    @IBOutlet weak var tableView: UITableView!

    // MARK: - Properties

    private let cellId = "Cell"
    private let screenTitle = "\"The List\""

    private var people = [Person]()

    // FIXME: S
    var persistentCoordinator: NSPersistentStoreCoordinator = {
        let coreDataName = "HitList"
        let modelURL = Bundle.main.url(forResource: coreDataName, withExtension: "momd")
        let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL!)
        let persistentCoordinator = NSPersistentStoreCoordinator(managedObjectModel:
            managedObjectModel!)
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                .userDomainMask, true)[0]
        let storeURL = URL(fileURLWithPath: documentsPath.appending("/\(coreDataName).sqlite"))
        print("storeUrl = \(storeURL)")
        do {
            try persistentCoordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                         configurationName: nil,
                                                         at: storeURL,
                                                         options: [NSSQLitePragmasOption:
                                                            ["journal_mode":"MEMORY"]])
            return persistentCoordinator
        } catch {
            abort()
        }
    }()

    var persistentContainer: NSPersistentContainer = {
        let coreDataName = "HitList"
        let container = NSPersistentContainer(name: coreDataName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            print("storeDescription = \(storeDescription)")
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    } ()
    // FIXME: E

    // MARK: - Life cicle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // FIXME: S
        let persistentCoordinator = self.persistentCoordinator
        let persistentContainer = self.persistentContainer
        // FIXME: E

        title = screenTitle
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadNames()
    }
    
    // MARK - Actions

    @IBAction func addName(_ sender: Any) {
        let alert = UIAlertController(title: "New name", message: "Add a new name", preferredStyle: .alert)

        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] (action: UIAlertAction!) -> Void in
            guard let textField = alert.textFields?[0] else {
                fatalError()
            }

            if let name = textField.text, !name.isEmpty {
                self?.saveName(name)
                self?.tableView.reloadData()
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action: UIAlertAction!) -> Void in
        }
        
        alert.addTextField { (textField: UITextField!) -> Void in
        }

        alert.addAction(saveAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    // MARK: - Private

    private func saveName(_ name: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError()
        }

        let managedContext = appDelegate.persistentContainer.viewContext

        guard let entity = NSEntityDescription.entity(forEntityName: "Person", in: managedContext) else {
            fatalError()
        }

        let person = Person(entity: entity, insertInto: managedContext)
        person.name = name

        do {
            try managedContext.save()
        } catch let error {
            print("Could not save \(String(describing: error)), \(String(describing: error.localizedDescription))")
            return
        }

        people.append(person)
    }

    private func loadNames() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError()
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Person")
        
        do {
            guard let fetchedResults = try managedContext.fetch(fetchRequest) as? [Person] else {
                fatalError()
            }
            people = fetchedResults
        } catch let error {
            print("Could not fetch \(error), \(error.localizedDescription)")
        }
    }
    
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId) else {
            fatalError()
        }

        cell.textLabel!.text = people[indexPath.row].name
        return cell
    }
    
}
