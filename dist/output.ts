interface Worker {
  work(hours: number): void;
  report(): string;
}
interface AdvancedWorker {
  lead(teamSize: number): void;
}
interface Engineer {
  specialty: string;
  isWorking: boolean;
}
interface Person {
  id: number;
  name: string;
  tags: String[];
}