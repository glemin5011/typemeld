protocol Worker {
  func work(hours: Int) -> Void
  func report() -> String
}
protocol AdvancedWorker: Worker {
  func lead(teamSize: Int) -> Void
}
struct Person {
  var id: Int
  var name: String
}
struct Engineer {
  var id: Int
  var name: String
  var specialty: String
  var isWorking: Bool
}