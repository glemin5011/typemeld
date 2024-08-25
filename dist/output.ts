interface Worker {
  work(hours: number): void;
  report(): string;
}
interface AdvancedWorker extends Worker {
  lead(teamSize: number): void;
}
interface Person {
  id: number;
  name: string;
}
interface Engineer extends Person {
  specialty: string;
  isWorking: boolean;
}