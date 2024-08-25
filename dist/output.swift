protocol Worker {
  func work(hours: Int) -> Void
  func report() -> String
}
protocol AdvancedWorker: Worker {
  func lead(teamSize: Int) -> Void
}
struct Engineer {
  var id: Int
  var name: String
  var tags: String[]
  var specialty: String
  var isWorking: Bool
}
func hire(person: Person, position: String) -> Bool
struct Person {
  var id: Int
  var name: String
  var tags: String[]
}
func addTags(person: Person, newTags: String[]) -> Person