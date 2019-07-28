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
    private let nameKey = "name"

    private var people = [NSManagedObject]()

    // MARK: - Life cicle

    override func viewDidLoad() {
        super.viewDidLoad()

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

        let person = NSManagedObject(entity: entity, insertInto:managedContext)
        person.setValue(name, forKey: nameKey)

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
            guard let fetchedResults = try managedContext.fetch(fetchRequest) as? [NSManagedObject] else {
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

        cell.textLabel!.text = people[indexPath.row].value(forKey: nameKey) as? String
        return cell
    }
    
}
