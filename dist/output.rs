trait Worker {
  fn work(hours: i32) -> ();
  fn report() -> String;
}
trait AdvancedWorker: Worker {
  fn lead(teamSize: i32) -> ();
}
struct Person {
  id: i32,
  name: String,
}
struct Engineer {
  id: i32,
  name: String,
  specialty: String,
  isWorking: bool,
}