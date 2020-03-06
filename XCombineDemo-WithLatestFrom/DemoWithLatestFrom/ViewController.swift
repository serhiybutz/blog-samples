import UIKit
import Combine
import XCombine

class ViewController: UIViewController {
    // MARK: - Properties

    let searchBar = UISearchBar()
    let searchResultsTable = UITableView()
    let refreshControl = UIRefreshControl()

    var cancellables = Set<AnyCancellable>()

    // Filter text.
    var filter: String? {
        didSet {
//            guard oldValue != filter else { return; }
            doQuery(by: filter ?? "")
        }
    }

    // Model.
    let dataStore = CountryDataStore.load()

    lazy var decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    var searchResults: [Country] = [] {
        didSet {
            searchResultsTable.reloadData()
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let lg = view.safeAreaLayoutGuide

        view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.leadingAnchor.constraint(equalTo: lg.leadingAnchor).isActive = true
        searchBar.topAnchor.constraint(equalTo: lg.topAnchor).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: lg.trailingAnchor).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 30).isActive = true

        view.addSubview(searchResultsTable)
        searchResultsTable.translatesAutoresizingMaskIntoConstraints = false
        searchResultsTable.leadingAnchor.constraint(equalTo: lg.leadingAnchor).isActive = true
        searchResultsTable.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        searchResultsTable.trailingAnchor.constraint(equalTo: lg.trailingAnchor).isActive = true
        searchResultsTable.bottomAnchor.constraint(equalTo: lg.bottomAnchor).isActive = true

        searchResultsTable.dataSource = self

        searchResultsTable.register(MyCell.self, forCellReuseIdentifier: "MyCell")

        searchResultsTable.refreshControl = refreshControl

        setupAdvPipeline()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.text! = filter ?? ""
    }
}

// MARK: - Helpers
private extension ViewController {
    func setupAdvPipeline() {
        let searchStream = searchBar.searchTextField.textPublisher
            .prepend(searchBar.text!)
            .eraseToAnyPublisher()

        let sparsedSearchStream = searchStream
            .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()

        let beginRefreshingStream = refreshControl
            .beginRefreshingPublisher
            .x.withLatestFrom(searchStream)  // <--
            .map { (_, filter) in filter }
            .delay(for: 0.3, scheduler: DispatchQueue.main)  // simulate network delay
            .eraseToAnyPublisher()

        beginRefreshingStream
            .sink(
                receiveValue: { filter in
                    // Dismiss the refresh control.
                    self.refreshControl.endRefreshing()
            })
            .store(in: &cancellables)

        let joinedStream = sparsedSearchStream
            .merge(with: beginRefreshingStream)
            .eraseToAnyPublisher()

        joinedStream
            .sink(
                receiveValue: { searchText in
                    self.filter = searchText
            })
            .store(in: &cancellables)
    }

    func doQuery(by filter: String) {
        var results: [Country] = []
        if filter.count > 0 {
            for country in dataStore.allCountries {
                if country.name.contains(filter) {
                    results.append(country)
                }
            }
        } else {
            results = dataStore.allCountries
        }
        searchResults = results
            .shuffled()  // shuffle to demonstrate searches get regenerated
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath)
        cell.textLabel!.text = searchResults[indexPath.row].name
        cell.detailTextLabel!.text = decimalFormatter.string(from: searchResults[indexPath.row].population as NSNumber)
        return cell
    }
}
