interface LogEntry {
  message: string;
  timestamp: { seconds: number; nanos: number };
}