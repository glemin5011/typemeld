interface Worker {
  work(hours: number): void;
  report(): string;
}
interface AdvancedWorker {
  lead(teamSize: number): void;
}
interface Person {
  id: number;
  name: string;
}
interface Engineer {
  specialty: string;
  isWorking: boolean;
}