trait Worker {
  fn work(hours: i32) -> ();
  fn report() -> String;
}
trait AdvancedWorker {
  fn lead(teamSize: i32) -> ();
}
struct Person {
  id: i32,
  name: String,
}
struct Engineer {
  specialty: String,
  isWorking: bool,
}