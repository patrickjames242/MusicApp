//
//  ViewController.swift
//  MusicApp
//
//  Created by Patrick Hanna on 2/14/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import CoreData






//MARK: - NAVIGATION CONTROLLER

class SongListViewController: StandardAppNavigationController{

    func scrollToCellOf(song: Song){
        mainController.scrollToCellOfSong(song)
    }
    
    
    private var mainController = _SongListViewController()
    
    override var mainViewController: UIViewController{
        return mainController
    }
    
    
    
}









//MARK: - SONG LIST VIEW

fileprivate class _SongListViewController: SafeAreaObservantTableViewController, NSFetchedResultsControllerDelegate, UISearchBarDelegate, UISearchControllerDelegate{
    
    let cellID = "The Best cell everrrrr!!!!!"
    let headerID = "the Best HEADER EVERRRR!!!!! 😁😁"
    
    
    
    
    
    
    
    //MARK: - VIEW DID LOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dealWithFetchedResultsController()
        setUpSearchBar()
        setUpTableView()
        
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = "Songs"
        navigationItem.hidesSearchBarWhenScrolling = false
    
        
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(respondToLongPressGesture(gesture:)))
        view.addGestureRecognizer(longPressGesture)
        
    }
    
 
    
    
    
    
    
    private func setUpTableView(){
        
        tableView.tintColor = .black
        tableView.tableFooterView = UIView()
        tableView.register(MyTableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: headerID)
        tableView.sectionIndexColor = THEME_COLOR(asker: self)
        
        tableView.rowHeight = 58
        tableView.separatorInset.left = CellConstants.separatorLeftInset
        tableView.keyboardDismissMode = .onDrag

        
        
        
    }
    
    
    override func interfaceColorDidChange(to color: UIColor) {
        tableView.sectionIndexColor = color
        searchController.searchBar.tintColor = color
    }
    
    
    private func setUpSearchBar(){
        
        
        
        navigationItem.searchController = self.searchController
        searchController.dimsBackgroundDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = THEME_COLOR(asker: self)
        searchController.searchBar.delegate = self
        searchController.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        
        
        
        
        let searchBar = searchController.searchBar
        
        let coverView = UIView()
        coverView.translatesAutoresizingMaskIntoConstraints = false
        coverView.backgroundColor = .white
        searchBar.addSubview(coverView)
        coverView.leftAnchor.constraint(equalTo: searchBar.leftAnchor).isActive = true
        coverView.rightAnchor.constraint(equalTo: searchBar.rightAnchor).isActive = true
        coverView.bottomAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 1).isActive = true
        coverView.heightAnchor.constraint(equalToConstant: 2).isActive = true
        
        
        searchController.searchBar.addSubview(coverView)
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - MODEL
    
    
    enum SongListType{ case all, search}
    
    var officialSongsTuple = (songs: [[Song]](), sectionNames: [String](), type: SongListType.all){
        willSet{
            
            if newValue.songs.isEmpty{
                
                
                if newValue.type == .all{
                    tableView?.backgroundView = ScrollableContentBackgroundView(title: "Your Library Is Empty 😭", message: "Add songs from Youtube to fill your library!", animated: (officialSongsTuple.type != newValue.type))
                } else if newValue.type == .search{
                    tableView?.backgroundView = ScrollableContentBackgroundView(title: nil, message: "No songs matched your search text 😞.", buttonText: nil, animated: (officialSongsTuple.type != newValue.type))
                }
                
                
                
                //                tableView?.isScrollEnabled = false
                //                navigationItem.searchController = nil
            } else {
                //                navigationItem.searchController = searchController
                tableView?.backgroundView = nil
                //                tableView?.isScrollEnabled = true
            }
            
            
        }
        
    }
    
    var searchSongsTuple = ([[Song]](), [String]()){
        didSet{
            if officialSongsTuple.type == .all{return}
            officialSongsTuple = (searchSongsTuple.0, searchSongsTuple.1, .search)
        }
    }
    
    
    var dbSongsTuple = ([[Song]](), [String]()){
        didSet{
            
            if officialSongsTuple.type == .all{
                officialSongsTuple.songs = dbSongsTuple.0
                officialSongsTuple.sectionNames = dbSongsTuple.1
            
            }
        }
    }
    
    
    
    let searchController = UISearchController(searchResultsController: nil)

    

    
    
    private let searcher = Searcher()
    
    
    
    
    
    
    

    
    
    
    
    
    
  
    
    
    
    @objc func respondToLongPressGesture(gesture: UILongPressGestureRecognizer){
        if searcher.searchIsActive{return}
        if gesture.state == .began{
            
            let location = gesture.location(in: view)
            if let index = tableView.indexPathForRow(at: location){
                let song = officialSongsTuple.songs[index.section][index.row]
                AppManager.shared.displayActionMenuFor(song: song)

                
            }
        }
        
        
        
    }
    
    


    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //MARK: - SEARCH BAR STUFF
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty{
            
            officialSongsTuple.sectionNames = dbSongsTuple.1
            officialSongsTuple.songs = dbSongsTuple.0
            tableView.reloadData()
            return
            
        }
        
        searcher.getResultsFor(searchText) { (songArray) in
            if searchText != searchBar.text {return}
            
            let returnTuple = songArray.alphabetizeSongs()
            
            self.searchSongsTuple = (returnTuple.songs, returnTuple.letters)
            self.tableView.reloadData()
            
        }
        
    }
    
    var userIsSearching = false
    
    func didPresentSearchController(_ searchController: UISearchController) {
        
        userIsSearching = true
        
        self.officialSongsTuple.type = .search
        
        searcher.beginSearchSessionWith(dbSongsTuple.0)
        
    }
    
    
    func didDismissSearchController(_ searchController: UISearchController) {
        
        userIsSearching = false
        
        searcher.cancelCurrentSearchSession()
        
        
        officialSongsTuple = (dbSongsTuple.0, dbSongsTuple.1, .all)
        searchSongsTuple = ([[]], [])
        
        self.tableView.reloadData()
        
        
        
    }
    
    
    
    
    
    
    
    
    
    //MARK: -
    
    

    
    private func getIndexPathOf(song: DBSong) -> IndexPath?{
        var songIndexPath: IndexPath?
        var s = 0
        for songSection in officialSongsTuple.songs{
            
            var r = 0
            for song1 in songSection{
                if song1.isTheWrapperFor(DBObject: song){
                    songIndexPath = IndexPath(row: r, section: s)
                }
                r += 1
            }
            s += 1
        }
        return songIndexPath
    }
    
    func scrollToCellOfSong(_ song: Song){
        guard let songIndexPath = self.getIndexPathOf(song: song.object) else {return}
        
        
        tableView.selectRow(at: songIndexPath, animated: true, scrollPosition: .middle)
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (timer) in
            if let cell = self.tableView.cellForRow(at: songIndexPath) as? CircleInteractionTableViewCell{
                cell.highlight()
                timer.invalidate()
            }
        }
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { (timer2) in
            timer.invalidate()
            timer2.invalidate()
        }
        
    }
    

  
    
    
        
        
    //MARK: - FETCHED RESULTS CONTROLLER STUFF
    
    
  
    var fetchedResultsController = NSFetchedResultsController<DBSong>()
    
    private func dealWithFetchedResultsController(){
        
        
        let fetchRequest: NSFetchRequest<DBSong> = DBSong.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchedResultsController = NSFetchedResultsController<DBSong>(fetchRequest: fetchRequest, managedObjectContext: Database.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self

        do{
            try fetchedResultsController.performFetch()
            let fetchedObjects = fetchedResultsController.fetchedObjects!
            
            
            
            let songObjects = Song.wrap(array: fetchedObjects)
            let alphabetizedSongs = songObjects.alphabetizeSongs()
            
            self.dbSongsTuple = (alphabetizedSongs.songs, alphabetizedSongs.letters)
            
            tableView.reloadData()
            
        } catch {
           print(error)
        }
        
    }
    
    
    
    
    

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        let object = anObject as! DBSong

        let oldSongs = dbSongsTuple.0
        
        let formattedOldIndexPath = getIndexPathOf(song: object)
        
        let fetchedObjects = fetchedResultsController.fetchedObjects!
        let songObjects = Song.wrap(array: fetchedObjects)
        let newSongs = songObjects.alphabetizeSongs()
        self.dbSongsTuple = (newSongs.songs, newSongs.letters)
        
        if officialSongsTuple.type == .search{return}
        
        
        let formattedNewIndexPath = getIndexPathOf(song: object)
        
        
        
        switch type{
        case .insert:
            if newSongs.songs[formattedNewIndexPath!.section].count == 1{
                tableView.insertSections(IndexSet(integer: formattedNewIndexPath!.section), with: .left)
                break
            }
            tableView.insertRows(at: [formattedNewIndexPath!], with: .left)
        case .delete:
            if oldSongs[formattedOldIndexPath!.section].count == 1{
                tableView.deleteSections(IndexSet(integer: formattedOldIndexPath!.section), with: .right)
                break
            }
            tableView.deleteRows(at: [formattedOldIndexPath!], with: .right)
        case .move:
            tableView.moveRow(at: formattedOldIndexPath!, to: formattedNewIndexPath!)
        case .update:
            tableView.reloadRows(at: [formattedOldIndexPath!], with: .fade)
        }
    }
    
   
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    //MARK: - TABLE VIEW FUNCTIONS
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return officialSongsTuple.songs.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return officialSongsTuple.songs[section].count
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return officialSongsTuple.sectionNames
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentSong = officialSongsTuple.songs[indexPath.section][indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! MyTableViewCell
        cell.setWith(song: currentSong)
        return cell
    }
    
    
    

    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerID)
        let sectionBackgroundView =
            generateSectionHeaderView(sectionTitle: officialSongsTuple.sectionNames[section])
        
        view!.backgroundView = sectionBackgroundView
        sectionBackgroundView.frame = view!.bounds
        return view
    }
    
    
    
    private func generateSectionHeaderView(sectionTitle: String) -> UIView{
        let x = UIView()
        x.backgroundColor = .white
        
        let label = UILabel()
        label.text = sectionTitle
        label.font = UIFont.boldSystemFont(ofSize: 17)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        x.addSubview(label)
        label.leftAnchor.constraint(equalTo: x.leftAnchor, constant: CellConstants.imageLeftInset).isActive = true
        label.centerYAnchor.constraint(equalTo: x.centerYAnchor).isActive = true
        
        return x
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AppManager.shared.setAndPlaySong(officialSongsTuple.songs[indexPath.section][indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}

















//MARK: - CELL CONSTANTS



final fileprivate class CellConstants{
    static var imageHeight: CGFloat = 48
    static var cellHeight: CGFloat = 58
    static var imageLeftInset: CGFloat = 17
    static var stackViewLeftInset: CGFloat = 15
   
    static var imageWidth: CGFloat{
        
        return imageHeight * (16 / 9)
    }
    
    static var separatorLeftInset: CGFloat{
        
        return imageLeftInset + stackViewLeftInset + imageWidth
        
    }
    static var stackViewRightInset: CGFloat = -20
    static var cellRightInset: CGFloat = 15
}























//MARK: - TABLE VIEW CELL

class MyTableViewCell: CircleInteractionTableViewCell, SongObserver{
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(albumImageView)
        addSubview(textStackView)
        addSubview(nowPlayingAnimator)
      

        setConstraints()
    }
    
    
    
  
    
    
    //MARK: - CONSTRAINTS TABLE VIEW CELL
    
    private func setConstraints(){
        
        albumImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: CellConstants.imageLeftInset).isActive = true
        albumImageView.widthAnchor.constraint(equalToConstant: CellConstants.imageWidth).isActive = true
        albumImageView.heightAnchor.constraint(equalToConstant: CellConstants.imageHeight).isActive = true
        albumImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        textStackView.leftAnchor.constraint(equalTo: albumImageView.rightAnchor, constant: CellConstants.stackViewLeftInset).isActive = true
        textStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        textStackView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: CellConstants.stackViewRightInset).isActive = true
    
    }
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //MARK: - SONG PLAYING STATUS DID CHANGE STUFF, TABLE VIEW CELL
    
    private weak var currentSong: Song?
    func setWith(song: Song){
        
        currentSong?.removeObserver(self)
        
        self.albumImageView.image = song.image
        self.topLabel.text = song.name
        self.bottomLabel.text = song.artistName
        self.currentSong = song
        song.addObserver(self)
        
        changeCellNowPlayingStateTo(state: song.nowPlayingStatus)
    
    }
    
    
    
    private func changeCellNowPlayingStateTo(state: SongPlayingStatus){
    
        
        switch state {
        case .inactive:
            nowPlayingAnimator.stopAnimating()
            topLabel.textColor = .black
            topLabel.font = UIFont.systemFont(ofSize: 17)
            bottomLabel.textColor = .gray
            
            
        case .paused:
            nowPlayingAnimator.stopAnimating()
            topLabel.textColor = THEME_COLOR(asker: self)
            bottomLabel.textColor = THEME_COLOR(asker: self)
            topLabel.font = UIFont.boldSystemFont(ofSize: 17)
        
        case .playing:
            nowPlayingAnimator.startAnimating()
            topLabel.textColor = THEME_COLOR(asker: self)
            bottomLabel.textColor = THEME_COLOR(asker: self)
            topLabel.font = UIFont.boldSystemFont(ofSize: 17)
            
        }
        
        
    }
    
    func songPlayingStatusDidChangeTo(_ status: SongPlayingStatus) {
        changeCellNowPlayingStateTo(state: status)
    }
    
    
    
    
    override func interfaceColorDidChange(to color: UIColor) {
        nowPlayingAnimator.color = color
        
        if nowPlayingAnimator.isAnimating{
            nowPlayingAnimator.stopAnimating()
            nowPlayingAnimator.startAnimating()
        }

        if let currentSong = currentSong{
            if currentSong.nowPlayingStatus == .paused || currentSong.nowPlayingStatus == .playing{
                topLabel.textColor = color
                bottomLabel.textColor = color
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //MARK: - OBJECTS, TABLE VIEW CELL
    
    private lazy var nowPlayingAnimator: NVActivityIndicatorView = {
        let viewFrame = CGRect(x: 0,
                               y: 0,
                               width: 20,
                               height: 20)
        let x = NVActivityIndicatorView(frame: viewFrame, type: .audioEqualizer, color: THEME_COLOR(asker: self), padding: nil)
        x.bottomSide = 50
        x.rightSide = 100
        return x
        
    }()
    
    
    
    let albumImageView: UIImageView = {
       let x = UIImageView()
        x.translatesAutoresizingMaskIntoConstraints = false
        x.layer.cornerRadius = 5
        x.layer.masksToBounds = true
        x.contentMode = .scaleAspectFill
        return x
        
    }()
    
    lazy var textStackView: UIStackView = {
        let x = UIStackView(arrangedSubviews: [topLabel, bottomLabel])
        x.axis = .vertical
        x.distribution = UIStackViewDistribution.fillEqually
        x.translatesAutoresizingMaskIntoConstraints = false
        return x
    }()
    
    lazy var topLabel: UILabel = {
       let x = UILabel()
        x.text = "lalalala"
        x.font = UIFont.systemFont(ofSize: 17)
        x.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        return x
    }()
    
    
    lazy var bottomLabel: UILabel = {
        let x = UILabel()
        x.text = "lalalal"
        x.font = UIFont.systemFont(ofSize: 12)
        x.textColor = .gray
        return x
    }()
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

