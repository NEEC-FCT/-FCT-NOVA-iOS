//
//  showHorario.swift
//  RAMAnimatedTabBarDemo
//
//  Created by NEEC on 31/08/2019.
//  Copyright © 2019 Ramotion. All rights reserved.
//


import UIKit
import Foundation
import SwiftSoup
import JJFloatingActionButton


struct CellData {
    let horaInicio: String?
    let horaFim: String?
    let nome:String?
    let sala: String?
    
    
}


class showHorario: UIViewController , UITableViewDelegate , UITableViewDataSource {
    
    var dataS = [CellData]()
    var dataT = [CellData]()
    var dataQ = [CellData]()
    var dataQI = [CellData]()
    var dataSEX = [CellData]()
    var current = [CellData]()
    var lastDate = ""

    
    
    func clean(){
         dataS = [CellData]()
         dataT = [CellData]()
         dataQ = [CellData]()
         dataQI = [CellData]()
         dataSEX = [CellData]()
         current = [CellData]()
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bar: UISegmentedControl!
    
    @IBAction func changedDay(_ sender: Any) {
        
        switch bar.selectedSegmentIndex
        {
        case 0:
            current = dataS
              break;
        case 1:
            current = dataT
              break;
        case 2:
            current = dataQ
              break;
        case 3:
            current = dataQI
              break;
        case 4:
           current = dataSEX
              break;
        default:
            break;
        }
        
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return current.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
            as! HeadlineTableViewCel
        cell.nomeAula?.text = current[indexPath.row].nome!
        cell.inicioHora?.text =  current[indexPath.row].horaInicio!
        cell.fimHora?.text = current[indexPath.row].horaFim!
        cell.sala?.text = current[indexPath.row].sala!
        return cell
    }
    
    
    var id:String = ""
    var ano:String = ""
    var semestre:Int = 1
    var html:Data? = nil
    
    
    func finishPost (message:String, data:Data?) -> Void {
        
     DispatchQueue.main.async {
        self.removeSpinner()
        print("Volta ao horario")
        ApiService.callGetHorario(year: self.ano , studentNumberId: self.id, semester: self.semestre , finish: self.finishGetHorario)
         self.removeSpinner()
        }
      }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        let defaults = UserDefaults.standard
        semestre = defaults.integer(forKey: "semestreSelected")
        id =  defaults.string(forKey: "IDaluno")!
        ano = defaults.string(forKey: "urlSelect")!
        let escolhidoTotal = defaults.string(forKey: "escolhidoTotal") ?? " "
        print("Recebi " + id + " " + ano)
     
        if( escolhidoTotal == (id + ano) && UserDefaults.standard.object(forKey: "html") != nil){
           
            html = defaults.data(forKey: "html")!
            
            print("Show horario")
            self.showSpinner(onView: self.view)
            self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "aulas")
            tableView.dataSource = self
            tableView.delegate = self
            tableView.tableFooterView = UIView()
            
            //FAB
            let actionButton = JJFloatingActionButton()
            actionButton.buttonImage = UIImage(named: "gears")
            actionButton.addItem(title: "Logout", image: UIImage(named: "open-exit-door")?.withRenderingMode(.alwaysTemplate)) { item in
                
                UserDefaults.standard.removeObject(forKey: "username")
                UserDefaults.standard.removeObject(forKey: "password")
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "RAMAnimatedTabBarController")
                self.present(newViewController, animated: true, completion: nil)
                
            }
            actionButton.addItem(title: "Mudar ano", image: UIImage(named: "calendar")?.withRenderingMode(.alwaysTemplate)) { item in
                _ = self.navigationController?.popViewController(animated: true)
            }
            actionButton.addItem(title: "Mudar semestre", image: UIImage(named: "notebook")?.withRenderingMode(.alwaysTemplate)) { item in
                
                let alert = UIAlertController(title: "Escolha o semestre", message: "", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "1º Semestre", style: .default, handler: { action in
                    let defaults = UserDefaults.standard
                    defaults.set(1, forKey: "semestreSelected")
                    self.showSpinner(onView: self.view)
                    self.clean()
                    ApiService.callGetHorario(year: self.ano, studentNumberId: self.id, semester: 1, finish: self.finishGetHorario)
         
                }))
                
                alert.addAction(UIAlertAction(title: "2º Semestre", style: .default, handler: { action in
                    print("2")
                    let defaults = UserDefaults.standard
                    defaults.set(2, forKey: "semestreSelected")
                    self.showSpinner(onView: self.view)
                    self.clean()
                    ApiService.callGetHorario(year: self.ano, studentNumberId: self.id, semester: 2, finish: self.finishGetHorario)
                }))
                
                alert.addAction(UIAlertAction(title: "2º Trimestre", style: .default, handler: { action in
                    print("3")
                    let defaults = UserDefaults.standard
                    defaults.set(3, forKey: "semestreSelected")
                    self.showSpinner(onView: self.view)
                    self.clean()
                    ApiService.callGetHorario(year: self.ano, studentNumberId: self.id, semester: self.semestre, finish: self.finishGetHorario)
                }))
                
                self.present(alert, animated: true)
                
            }
            
            view.addSubview(actionButton)
            actionButton.translatesAutoresizingMaskIntoConstraints = false
            
            actionButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
            
            actionButton.buttonColor = UIColor(red:0.45, green:0.78, blue:0.93, alpha:1.0)
            
            finishGetHorario(message: "nada" ,data: html)
        }
        else{
   
        
        print("Show horario")
        self.showSpinner(onView: self.view)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "aulas")
        tableView.dataSource = self
        tableView.delegate = self
        
        //FAB
        let actionButton = JJFloatingActionButton()
        actionButton.buttonImage = UIImage(named: "gears")
        actionButton.addItem(title: "Logout", image: UIImage(named: "open-exit-door")?.withRenderingMode(.alwaysTemplate)) { item in
            
             DispatchQueue.main.async {
                let defaults = UserDefaults.standard
                defaults.set( nil , forKey: "username")
                defaults.set( nil , forKey: "password")
                defaults.synchronize()
            }
   
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "RAMAnimatedTabBarController")
            self.present(newViewController, animated: true, completion: nil)
            
        }
        actionButton.addItem(title: "Mudar ano", image: UIImage(named: "calendar")?.withRenderingMode(.alwaysTemplate)) { item in
             _ = self.navigationController?.popViewController(animated: true)
        }
        
            
            
        actionButton.addItem(title: "Mudar semestre", image: UIImage(named: "notebook")?.withRenderingMode(.alwaysTemplate)) { item in
            
            let alert = UIAlertController(title: "Escolha o semestre", message: "", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "1º Semestre", style: .default, handler: { action in
               // print("1")
                let defaults = UserDefaults.standard
                defaults.set(1, forKey: "semestreSelected")
                  self.showSpinner(onView: self.view)
                self.clean()
                ApiService.callGetHorario(year: self.ano, studentNumberId: self.id, semester: 1, finish: self.finishGetHorario)
            }))
            
            alert.addAction(UIAlertAction(title: "2º Semestre", style: .default, handler: { action in
                //print("2")
                let defaults = UserDefaults.standard
                defaults.set(2, forKey: "semestreSelected")
                  self.showSpinner(onView: self.view)
                self.clean()
                ApiService.callGetHorario(year: self.ano, studentNumberId: self.id, semester: 2, finish: self.finishGetHorario)
            }))
            
            alert.addAction(UIAlertAction(title: "2º Trimestre", style: .default, handler: { action in
                print("3")
                let defaults = UserDefaults.standard
                defaults.set(3, forKey: "semestreSelected")
                  self.showSpinner(onView: self.view)
                self.clean()
                ApiService.callGetHorario(year: self.ano, studentNumberId: self.id, semester: 3, finish: self.finishGetHorario)
            }))
            
            self.present(alert, animated: true)
            
        }
        

            
        actionButton.addItem(title:"Atualizar", image: UIImage(named: "refresh")) { item in
            
            DispatchQueue.main.async {
            self.showSpinner(onView: self.view)
            self.clean()
            ApiService.callGetHorario(year: self.ano, studentNumberId: self.id, semester: self.semestre, finish: self.finishGetHorario)
            }
        }
            
        view.addSubview(actionButton)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        
        actionButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        
        actionButton.buttonColor = UIColor(red:0.45, green:0.78, blue:0.93, alpha:1.0)
        
        
        ApiService.callGetHorario(year: self.ano , studentNumberId: self.id, semester: self.semestre , finish: finishGetHorario)
        //gotoID
    
        }
    }
    
    func finishCookies(message:String, data:Data?) -> Void
    {
    
        //Get horario
        print("Got cookie")
        DispatchQueue.main.async {
        ApiService.callGetHorario(year: self.ano , studentNumberId: self.id, semester: self.semestre, finish: self.finishGetHorario)
        }
    }
    
    
    func finishGetHorario(message:String, data:Data?) -> Void
    {
        do
        {
          
            let defaults = UserDefaults.standard
            defaults.set(data, forKey: "html")
            defaults.set(self.id + self.ano, forKey:"escolhidoTotal")
            
            //print(message)
            print("----Horario---")
            
            let html = String(data: data!, encoding: .isoLatin1)
            //print( html! )
            if( (html?.contains("geral de utente"))!){
                let defaults = UserDefaults.standard
                let username = defaults.string(forKey: "username")
                let password = defaults.string(forKey: "password")
                print("useername" , username! )
                print("pass" , password! )
                let params = ["identificador": username!,
                              "senha":password!
                ]
                self.removeSpinner()
                self.showSpinner(onView: self.view)
                
                ApiService.callPost(url: URL(string: "https://clip.unl.pt/utente/eu")!, params: params, finish: finishPost)

            }
            else{

            
            do {
                let doc: Document = try SwiftSoup.parse(html!)
                let trs: Elements = try doc.body()!.select("tr[valign=center]")
                for tr in trs {
                    
                    let tds = try tr.select("td[class~=turno.* celulaDeCalendario]");
                    
                    for td in tds {
                        let child  = td.child(0).childNodesCopy();
                        
                        // Remove all the garbage
                        let href = try child[2].attr("href").split(separator: "&");
                        let dia = href[9];
                        let turno = href[7];
                        
                        let horas_inicio = tr.child(0);
                        let horas_fim = tr.child(1);
                        
                        var scheduleDayNumber:Int = -1
                        let stringArray = String(dia).components(separatedBy: CharacterSet.decimalDigits.inverted)
                        for item in stringArray {
                            if let number = Int(item) {
                                scheduleDayNumber = number
                                break
                            }
                        }
                        
                        var scheduleClassType = String(turno.suffix(1)).uppercased();
                        scheduleClassType += String(href[8].last!)
                        var scheduleClassName = try td.attr("title");
                      // let scheduleClassNameMin:String = try child[0].outerHtml().slice(from: "<b>", to: "</b>")!
            
    
                        var scheduleClassRoom:String = "";
                        if (child.count > 4) {
                            scheduleClassRoom =  try child[4].outerHtml()
                          }
                      
                        
                        let scheduleClassDuration =  try? td.attr("rowspan");
                        
                        // Calculate scheduleClassHourStart & End
                        var scheduleClassHourStart:String = "";
                        var scheduleClassHourEnd:String = "";
                        
                        
                        let dateDuration = ( Int(scheduleClassDuration!)! / 2);
                            
                            if( Int(scheduleClassDuration!) == 3 ){
                                if (try horas_inicio.text().count >= 1) {
                                    // Start hour
                                    scheduleClassHourStart = try horas_inicio.text();
                                    
                                    let horas = scheduleClassHourStart.components(separatedBy: ":")
                                    let startDate  = Calendar.current.date(bySettingHour: Int(horas[0])!, minute: Int(horas[1])!, second: 0, of: Date())!
                                    
                                    let calendar = Calendar.current
                                    var date = calendar.date(byAdding: .hour, value: 1, to: startDate)
                                    date = calendar.date(byAdding: .minute, value: 30, to: date!)
                          
                                    let hour = calendar.component(.hour, from: date!)
                                    let minutes = calendar.component(.minute, from: date!)
                                    
                                    // End hour
                                    if(  minutes == 0){
                                    scheduleClassHourEnd = String(hour) + ":" + String(minutes) + "0";
                                        }
                                    else{
                                    scheduleClassHourEnd = String(hour) + ":" + String(minutes) ;
                                    }
                                } else {
                                    // Calculate start hour
                                    // Start hour
                                    scheduleClassHourStart = try horas_fim.text();
                                    let horas = scheduleClassHourStart.components(separatedBy: ":")
                                    let dateStart  = Calendar.current.date(bySettingHour: Int(horas[0])!, minute: Int(horas[1])!, second: 0, of: Date())!
                                    let calendar = Calendar.current
                                    var date = calendar.date(byAdding: .minute, value: -30, to: dateStart)
                                    
                                    var hour = calendar.component(.hour, from: date!)
                                    var minutes = calendar.component(.minute, from: date!)
                                    if(  minutes == 0){
                                        scheduleClassHourStart = String(hour) + ":" + String(minutes) + "0";
                                    }
                                    else{
                                        scheduleClassHourStart = String(hour) + ":" + String(minutes) ;
                                    }
                                    
                                    date = calendar.date(byAdding: .hour, value: 1, to: dateStart)
                                      date = calendar.date(byAdding: .minute, value: 30, to: dateStart)
                                    
                                    hour = calendar.component(.hour, from: date!)
                                    minutes = calendar.component(.minute, from: date!)
                                    
                                    // End hour
                                    if(  minutes == 0){
                                        scheduleClassHourEnd = String(hour) + ":" + String(minutes) + "0";
                                    }
                                    else{
                                        scheduleClassHourEnd = String(hour) + ":" + String(minutes) ;
                                    }
                                }
                            }
                            else {
                              
                                if( try horas_inicio.text().count > 1){
                                    // Start hour
                                    scheduleClassHourStart = try horas_inicio.text();
                                    let horas = scheduleClassHourStart.components(separatedBy: ":")
                                    let dateStart  = Calendar.current.date(bySettingHour: Int(horas[0])!, minute: Int(horas[1])!, second: 0, of: Date())!
                                    let calendar = Calendar.current
                                    let date = calendar.date(byAdding: .hour, value: dateDuration, to: dateStart)
                                    
                                    let hour = calendar.component(.hour, from: date!)
                                    let minutes = calendar.component(.minute, from: date!)
                                    
                                    // End hour
                                    if(  minutes == 0){
                                        scheduleClassHourEnd = String(hour) + ":" + String(minutes) + "0";
                                    }
                                    else{
                                        scheduleClassHourEnd = String(hour) + ":" + String(minutes) ;
                                    }
                                }
                                else{
                                    // Start hour
                                    scheduleClassHourStart = try horas_fim.text();
                                    let horas = scheduleClassHourStart.components(separatedBy: ":")
                                    let dateStart  = Calendar.current.date(bySettingHour: Int(horas[0])!, minute: Int(horas[1])!, second: 0, of: Date())!
                                    let calendar = Calendar.current
                                    var date = calendar.date(byAdding: .minute, value: -30, to: dateStart)
                                    
                                    var hour = calendar.component(.hour, from: date!)
                                    var minutes = calendar.component(.minute, from: date!)
                                    if(  minutes == 0){
                                        scheduleClassHourStart = String(hour) + ":" + String(minutes) + "0";
                                    }
                                    else{
                                        scheduleClassHourStart = String(hour) + ":" + String(minutes) ;
                                    }
                                    
                                     date = calendar.date(byAdding: .hour, value: dateDuration, to: dateStart)
                                    
                                     hour = calendar.component(.hour, from: date!)
                                     minutes = calendar.component(.minute, from: date!)
                                    
                                    // End hour
                                    if(  minutes == 0){
                                        scheduleClassHourEnd = String(hour) + ":" + String(minutes) + "0";
                                    }
                                    else{
                                        scheduleClassHourEnd = String(hour) + ":" + String(minutes) ;
                                    }
                                }
                              
                            }
                        
                        //adiciona o tipo
                        scheduleClassName  = scheduleClassName + " " + scheduleClassType
                        
                        if(scheduleDayNumber == 2){
                            self.dataS.append(CellData.init(horaInicio:  scheduleClassHourStart, horaFim: scheduleClassHourEnd , nome: scheduleClassName , sala: scheduleClassRoom ))
                        }
                        else if (scheduleDayNumber == 3){
                            self.dataT.append(CellData.init(horaInicio:  scheduleClassHourStart, horaFim:  scheduleClassHourEnd , nome: scheduleClassName, sala: scheduleClassRoom ))
                        }
                        else if (scheduleDayNumber == 4){
                            self.dataQ.append(CellData.init(horaInicio:  scheduleClassHourStart, horaFim:  scheduleClassHourEnd , nome: scheduleClassName, sala: scheduleClassRoom ))
                        }
                        else if (scheduleDayNumber == 5){
                            self.dataQI.append(CellData.init(horaInicio: scheduleClassHourStart, horaFim:  scheduleClassHourEnd , nome: scheduleClassName, sala: scheduleClassRoom ))
                        }
                        else if (scheduleDayNumber == 6){
                            self.dataSEX.append(CellData.init(horaInicio:  scheduleClassHourStart, horaFim:  scheduleClassHourEnd , nome: scheduleClassName, sala: scheduleClassRoom ))
                            }
                            
                        }
                        
                    }
                }
                
                
                catch {
                print("error")
            }
            
            DispatchQueue.main.async {
                self.removeSpinner()
                self.current = self.dataS
                self.tableView.reloadData()
            }
               
        }
            
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}



extension String {
    
    func slice(from: String, to: String) -> String? {
        
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
}


