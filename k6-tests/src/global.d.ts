// Global type declarations for k6

declare const console: {
  log(...args: any[]): void;
  error(...args: any[]): void;
  warn(...args: any[]): void;
  info(...args: any[]): void;
};

declare const __ENV: {
  [key: string]: string;
};

