//
//  ekleViewController.swift
//  alisverisListesi
//
//  Created by ilymily on 20.08.2025.
//

import UIKit
import CoreData

class ekleViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate // resim seçmeye ve o resmi sayfaya getirmek için kullanılır
{

    @IBOutlet weak var resim: UIImageView!
    @IBOutlet weak var isim: UITextField!
    @IBOutlet weak var fiyat: UITextField!
    @IBOutlet weak var aciklama: UITextField!
    @IBOutlet weak var kaydet: UIButton!
    
    var secilenUrunIsmi = ""
    var secilenUrunId : UUID?
    
    
    override func viewDidLoad() {
        self.resim.image = UIImage(systemName: "photo")
        super.viewDidLoad()
        if secilenUrunIsmi != ""{
            kaydet.isHidden = true // kaydet butonu gizlenir çünkü detay sayfası
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Alisveris")
            fetchRequest.predicate = NSPredicate(format: "id == %@", secilenUrunId! as CVarArg)
            fetchRequest.returnsObjectsAsFaults = false
            do{
                let sonuclar = try context.fetch(fetchRequest)
                if sonuclar.count > 0{
                    for sonuc in sonuclar {
                        if let isim = sonuc.value(forKey: "isim") as? String{
                            self.isim.text = isim
                        }
                        if let fiyat = sonuc.value(forKey: "fiyat") as? Float{
                            self.fiyat.text = String(fiyat)
                        }
                        if let aciklama = sonuc.value(forKey: "aciklama") as? String{
                            self.aciklama.text = aciklama
                        }
                        if let resimData = sonuc.value(forKey: "gorsel") as? Data{
                            let image = UIImage(data: resimData)
                            resim.image = image
                        }
                        
                    }
                }
            } catch {
                print("hata")
            }
            
        } else {
            kaydet.isHidden = false
            isim.text = ""
            fiyat.text = ""
            aciklama.text = ""  
        }
        let gestureRecognizator = UITapGestureRecognizer(target: self, action: #selector(klavyeyiKapat)) //simulatorde klavye açılınca boşluğa tıklarız ve klavye kapanır
        view.addGestureRecognizer(gestureRecognizator)
        resim.isUserInteractionEnabled = true
        let resimSecici = UITapGestureRecognizer(target: self, action: #selector(resimSec))
        resim.addGestureRecognizer(resimSecici)
        
    }
    @objc func resimSec(){
        let picker = UIImagePickerController() //
        picker.delegate = self //seçilen resmi uygulamaya itecek
        picker.sourceType = .photoLibrary //galeriden seçim yapılacak
        picker.allowsEditing = true //seçilen resimde düzenlemeler yapılabilir
        present(picker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        resim.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage //seçilip düzenlenen resim değişkene atanır
        self.dismiss(animated: true, completion: nil) //Picker ekranını kapatıyor ve kullanıcı eski ekrana dönüyor.
    }
    @objc func klavyeyiKapat(){
        view.endEditing(true)
    }

    @IBAction func kaydetButon(_ sender: Any) {
        let appDeleget = UIApplication.shared.delegate as! AppDelegate // değişken olarak tanımlamak için gerekli daha sonra içindekilere erişilebilir
        let context = appDeleget.persistentContainer.viewContext
        let alisveris = NSEntityDescription.insertNewObject(forEntityName: "Alisveris", into: context) as! Alisveris // alışveris tablosuna veri eklemek için bir satır oluşturulur ve bilgiler doldurulur.
        alisveris.setValue(isim.text!, forKey: "isim")
        alisveris.setValue(aciklama.text!, forKey: "aciklama")
        if let fiyat = Float(fiyat.text!){
            alisveris.setValue(fiyat, forKey: "fiyat")
        }
        alisveris.setValue(UUID(), forKey: "id")
        let data = resim.image?.jpegData(compressionQuality: 0.5) //resmi veriye dönüştürüp sıkıştırıyoruz
        alisveris.setValue(data, forKey: "gorsel")
        
        do{
            try context.save()
            let basariMesaji = UIAlertController(title: "Tebrikler", message: "Kayıt başarılı.", preferredStyle: .alert)
            let okButon = UIAlertAction(title: "OK", style: .default) { _ in
                self.isim.text = ""
                self.fiyat.text = ""
                self.aciklama.text = ""
                self.resim.image = UIImage(systemName: "photo") // boş foto için varsayılan simge
            }
            self.present(basariMesaji, animated: true, completion: nil)
            basariMesaji.addAction(okButon)
        } catch {
            let basariMesaji = UIAlertController(title: "Hata", message: "Kayıt başarısız!", preferredStyle: .alert)
            let okButon = UIAlertAction(title: "OK", style: .default, handler: nil)
            self.present(basariMesaji, animated: true, completion: nil)
            basariMesaji.addAction(okButon)
        }
        NotificationCenter.default.post(name: NSNotification.Name("veriGirildi"), object: nil) //veri kaydedilince anasayfaya veri girildi mesajı gidiyor
        self.navigationController?.popViewController(animated: true) //yeni veri kaydedildikten sonra veri sayfasından ekle sayfasına dönmeyi sağlar
    }
    
}
