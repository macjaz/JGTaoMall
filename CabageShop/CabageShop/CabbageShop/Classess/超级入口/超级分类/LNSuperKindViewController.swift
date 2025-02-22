//
//  LNSuperKindViewController.swift
//  CabbageShop
//
//  Created by 付耀辉 on 2018/12/14.
//  Copyright © 2018年 付耀辉. All rights reserved.
//

import UIKit
import SwiftyJSON

class LNSuperKindViewController: LNBaseViewController {

    @objc public var mainCollectionView:UICollectionView?
    @objc public var selectIndex = 0
    
    let identyfierTable1  = "identyfierTable1"
    let identyfierTable2  = "identyfierTable2"
    
    //    cell之间的距离
    fileprivate let kSpace:CGFloat = 0.5
    //    cell的高度
    fileprivate let kHeight:CGFloat = 110

    var listModels = [LNTopListModel]()

    //    搜索框
    fileprivate var searchTextfield = UITextField()

    override func viewDidLoad() {
        super.viewDidLoad()
        addImageWhenEmpty()
    }
    
    override func configSubViews() {
        
        navigaView.backgroundColor = UIColor.white
        backBtn.setImage(UIImage.init(named: "back_icon"), for: .normal)
        
        searchTextfield.borderStyle = .none
        searchTextfield.leftViewRect(forBounds: CGRect(x: 0, y: 0, width: kSCREEN_WIDTH-60, height: 26))
        searchTextfield.placeholder = "搜索商品名称或宝贝标题"
        searchTextfield.textColor = kGaryColor(num: 69)
        searchTextfield.leftViewMode = .always
        searchTextfield.returnKeyType = .search
        searchTextfield.clearButtonMode = .whileEditing
        searchTextfield.delegate = self
        searchTextfield.layer.cornerRadius = 17
        searchTextfield.clipsToBounds = true
        searchTextfield.font = UIFont.systemFont(ofSize: 14)
        searchTextfield.textColor = UIColor.darkGray
        searchTextfield.backgroundColor = kGaryColor(num: 245)
//        searchTextfield.tintColor = UIColor.white
//        let attrString = NSMutableAttributedString.init(string: "搜索商品名称或宝贝标题")
//        attrString.addAttributes([NSAttributedStringKey.foregroundColor: kGaryColor(num: 251)], range: NSMakeRange(0, "搜索商品名称或宝贝标题".count))
//        searchTextfield.attributedPlaceholder = attrString;
        
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: 35, height: 17))
        let leftImage = UIImageView.init(frame: CGRect(x: 12, y: 0, width: 14, height: 14))
        leftImage.image = UIImage.init(named: "search_icon_default")
        view.addSubview(leftImage)
        searchTextfield.leftView = view
        navigaView.addSubview(searchTextfield)
        
        searchTextfield.snp.makeConstraints { (ls) in
            ls.left.equalTo(backBtn.snp.right).offset(8)
            ls.right.equalTo(rightBtn1).offset(-30)
            ls.centerY.equalTo(backBtn)
            ls.height.equalTo(30)
        }
        
        mainTableView = getTableView(frame: CGRect(x: 0, y: navHeight, width: kSCREEN_WIDTH, height: kSCREEN_HEIGHT-navHeight), style: .plain, vc: self)
        
        mainTableView.register(UINib(nibName: "LNSuperKindListCell", bundle: nil), forCellReuseIdentifier: identyfierTable)
        mainTableView.backgroundColor = kGaryColor(num: 245)
        mainTableView.separatorStyle = .none
        mainCollectionView?.showsVerticalScrollIndicator = false
        self.view.addSubview(mainTableView)
        
        
        //        配置UICollectionView
        let layout = UICollectionViewFlowLayout.init()
        //        滑动方向
        layout.scrollDirection = .vertical
        
        //        最小列间距
        layout.minimumInteritemSpacing = kSpace
        //        最小行间距
        layout.minimumLineSpacing = kSpace
        
        mainCollectionView = UICollectionView.init(
            frame: CGRect(x: 0, y: -kStatusBarH, width: kSCREEN_WIDTH, height: kSCREEN_HEIGHT+kStatusBarH-49), collectionViewLayout: layout)
        //        mainCollectionView?.height = kSCREEN_HEIGHT-CGFloat(navHeight)
        mainCollectionView?.delegate = self
        mainCollectionView?.dataSource = self
        
        mainCollectionView?.register(UINib.init(nibName: "LNSuperKindOptionCell", bundle: nil), forCellWithReuseIdentifier: identyfierTable1)
        
        self.view.addSubview(mainCollectionView!)
        mainCollectionView?.backgroundColor = UIColor.white
        
        mainTableView.snp.makeConstraints { (ls) in
            ls.left.bottom.equalToSuperview()
            ls.width.equalTo(80)
            ls.top.equalTo(navigaView.snp.bottom)
        }
        
        mainCollectionView?.snp.makeConstraints({ (ls) in
            ls.right.bottom.equalToSuperview()
            ls.left.equalTo(mainTableView.snp.right)
            ls.top.equalTo(navigaView.snp.bottom)
        })
    }
    override func viewWillAppear(_ animated: Bool) {
//        DispatchQueue.main.async {
//            UIApplication.shared.statusBarStyle = .default
//        }
    }
    override func viewWillDisappear(_ animated: Bool) {
//        UIApplication.shared.statusBarStyle = .lightContent
    }

    override func addHeaderRefresh() {
        
    }
    
    override func requestData() {
        let request = SKRequest.init()
        weak var weakSelf = self
        request.setParam("desc" as NSObject, forKey: "sortedBy")
        request.setParam("and" as NSObject, forKey: "searchJoin")
        request.setParam("parent_id:0;status:1" as NSObject, forKey: "search")
        request.setParam("sort" as NSObject, forKey: "orderBy")
        request.setParam("1" as NSObject, forKey: "type")

        request.callGET(withUrl: LNUrls().kCategory) { (response) in
            if !(response?.success)! {
                return
            }
            DispatchQueue.main.async {
                let datas =  JSON((response?.data["data"])!)["data"].arrayValue
                
                for index in 0..<datas.count{
                    weakSelf?.listModels.append(LNTopListModel.setupValues(json: datas[index]))
                }
                weakSelf?.mainTableView.reloadData()
                weakSelf?.mainCollectionView?.reloadData()
            }
        }
    }
    
    fileprivate var emptyView = UIView()
    
    //    当数据为空的时候，显示提示
    func addImageWhenEmpty() {
        
        emptyView = UIView.init(frame: CGRect(x: 0, y: 0, width: kSCREEN_WIDTH-80, height: kSCREEN_HEIGHT - 46))
        emptyView.backgroundColor = UIColor.white
        let imageView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 200 * kSCREEN_SCALE, height: 200 * kSCREEN_SCALE))
//        imageView.image = UIImage.init(named: "collect_empty_icon")
        imageView.center = CGPoint(x: emptyView.centerX, y: emptyView.centerY - 200 * kSCREEN_SCALE)
        imageView.contentMode = .scaleAspectFit
        emptyView.addSubview(imageView)
        
        let label = UILabel.init(frame: CGRect(x: 0, y: 0, width: kSCREEN_WIDTH, height: 18))
        label.textAlignment = .center
        label.textColor = kGaryColor(num: 199)
        label.center = CGPoint(x: emptyView.centerX, y: emptyView.centerY-35)
        label.font = kFont30
        label.numberOfLines = 2
        label.text = "该分类暂无数据"
        emptyView.addSubview(label)
    }
    
}


extension LNSuperKindViewController : UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return listModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identyfierTable, for: indexPath) as! LNSuperKindListCell
        var isSelect = false
        if indexPath.row == selectIndex {
            isSelect = true
        }
        cell.selectionStyle = .none
        cell.setValue(title: listModels[indexPath.row].name, isSelect: isSelect)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectIndex=indexPath.row
        tableView.reloadData()
        mainCollectionView?.reloadData()        
    }
    
}
extension LNSuperKindViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if listModels[selectIndex].children.count == 0 {
            self.mainCollectionView?.addSubview(emptyView)
        }else{
            emptyView.removeFromSuperview()
        }
        return listModels[selectIndex].children.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if listModels.count>0 {
            return 1
        }else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:LNSuperKindOptionCell = collectionView.dequeueReusableCell(withReuseIdentifier: identyfierTable1, for: indexPath) as! LNSuperKindOptionCell
        cell.setValues(model: listModels[selectIndex].children[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let ressult = LQSearchResultViewController()
        ressult.keyword = listModels[selectIndex].children[indexPath.row].name
        ressult.type  = "1"
        self.navigationController?.pushViewController(ressult, animated: true)

    }
    
    
    //    每个cell的尺寸
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (kSCREEN_WIDTH-kSpace*4)/4, height: kHeight)
    }
    
    //    每个section的缩进
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        var bottom :CGFloat = 0
        if section > 0 {
            bottom = 5
        }
        return UIEdgeInsets(top: bottom, left: 0, bottom: 0, right: 0)
    }
    
}

extension LNSuperKindViewController:UITextFieldDelegate{
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (searchTextfield.text?.count)! == 0 {
            setToast(str: "请输入关键词")
            
            return false
        }
        
        let ressult = LQSearchResultViewController()
        ressult.keyword = searchTextfield.text!
        ressult.type  = "1"
        self.navigationController?.pushViewController(ressult, animated: true)
        textField.text = nil
        textField.resignFirstResponder()
        return true
    }
    
}
