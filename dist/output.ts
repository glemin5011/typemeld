interface Worker {
  work(hours: number): void;
  report(): string;
}
interface AdvancedWorker extends Worker {
  lead(teamSize: number): void;
}
interface Engineer extends Person {
  specialty: string;
  isWorking: boolean;
}
interface Person {
  id: number;
  name: string;
  tags: string[];
}
type KeyValue = { key: string; value: number };

interface SomeThing<T> {
  property: T;
  another: Record<string, any>;
}