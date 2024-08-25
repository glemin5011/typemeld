trait Worker {
  fn work(hours: i32) -> ();
  fn report() -> String;
}
trait AdvancedWorker: Worker {
  fn lead(teamSize: i32) -> ();
}
struct Engineer {
  id: i32,
  name: String,
  tags: Vec<String>,
  specialty: String,
  isWorking: bool,
}
fn hire(person: Person, position: String) -> bool;
struct Person {
  id: i32,
  name: String,
  tags: Vec<String>,
}
fn addTags(person: Person, newTags: Vec<String>) -> Person;