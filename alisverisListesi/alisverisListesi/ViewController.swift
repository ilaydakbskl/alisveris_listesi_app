//
//  ViewController.swift
//  alisverisListesi
//
//  Created by ilymily on 20.08.2025.
//

import UIKit
import CoreData
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    var isimDizisi = [String]() //Ürün isimlerini tutan dizi
    var idDizisi = [UUID]()
    var secilenIsim = "" // kullanıcı hangi ürüne tıkladıysa onu detay sayfasına götüren değişken
    var secilenId: UUID?
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(artibuton)) //sağ üste artı butonu ekleniyor
        verileriAl() //core datada kayıtlı ürünler alınıyor
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(verileriAl), name: NSNotification.Name("veriGirildi"), object: nil)
    }

    @objc func verileriAl(){
        isimDizisi.removeAll(keepingCapacity: false)
        idDizisi.removeAll(keepingCapacity: false) //Her defasında veri eklenmemesi için veriler temizleiyor

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext //coredataya erişmek için context alınıyor
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Alisveris") //alışveriş tablosundaki verileri çekmek için fetch oluşturulur
        fetchRequest.returnsObjectsAsFaults = false
        
        do{
            let sonuclar = try context.fetch(fetchRequest) //coredataya gidip verileri getirir
            if sonuclar.count > 0 {
                for sonuc in sonuclar as! [NSManagedObject]{
                    if let isim = sonuc.value(forKey: "isim") as? String {
                        isimDizisi.append(isim)
                    }
                    if let id = sonuc.value(forKey: "id") as? UUID {
                        idDizisi.append(id)
                    }
                }
                tableView.reloadData()
            }
        }catch{
            print("hata")
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (isimDizisi.count) //ürün sayısı kadar satır olacak
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = isimDizisi[indexPath.row]
        return cell //her hücrede ürün isimleri yazdırılıyor
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Core Data context al
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            // Silinecek id
            let id = idDizisi[indexPath.row]
            
            // Fetch request hazırla
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Alisveris")
            fetchRequest.predicate = NSPredicate(format: "id = %@", id.uuidString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let sonuclar = try context.fetch(fetchRequest)
                if sonuclar.count > 0 {
                    for sonuc in sonuclar as! [NSManagedObject] {
                        context.delete(sonuc) // Core Data’dan sil
                    }
                    try context.save() // değişiklikleri kaydet
                }
            } catch {
                print("Silme hatası")
            }
            
            // Array’den ve tabloda da sil
            isimDizisi.remove(at: indexPath.row)
            idDizisi.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gecis" {
            let destinationVC = segue.destination as! ekleViewController // ekle ekranını kodda kullanabilmek için tanımlanır
            destinationVC.secilenUrunIsmi = secilenIsim
            destinationVC.secilenUrunId = secilenId
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        secilenIsim = isimDizisi[indexPath.row]
        secilenId = idDizisi[indexPath.row]
        performSegue(withIdentifier: "gecis", sender: nil)
    }
    @objc func artibuton(){
        secilenIsim = ""
        performSegue(withIdentifier: "gecis", sender: nil)
        
    }
    

}

