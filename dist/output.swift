protocol Worker {
  func work(hours: Int) -> Void
  func report() -> String
}
protocol AdvancedWorker {
  func lead(teamSize: Int) -> Void
}
struct Person {
  var id: Int
  var name: String
}
struct Engineer {
  var specialty: String
  var isWorking: Bool
}