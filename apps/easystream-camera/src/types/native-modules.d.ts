declare module 'react-native-zeroconf' {
  export default class Zeroconf {
    on(event: string, callback: (...args: any[]) => void): void;
    removeAllListeners(): void;
    scan(type: string, protocol: string, domain: string): void;
    publishService(
      type: string,
      protocol: string,
      domain: string,
      name: string,
      port: number,
      txt?: Record<string, string>,
    ): Promise<unknown>;
    publishService(options: {
      type: string;
      protocol: string;
      domain: string;
      name: string;
      port: number;
      txt?: Record<string, string>;
    }): Promise<unknown>;
    unpublishService(name: string): Promise<unknown | null>;
    stop(): void;
  }
}

declare module 'react-native-tcp-socket' {
  namespace TcpSocket {
    type Socket = {
      write: (data: string) => void;
      destroy: () => void;
      on: (event: string, listener: (...args: any[]) => void) => void;
    };
  }

  const TcpSocket: {
    createConnection: (
      options: { port: number; host: string },
      callback?: () => void,
    ) => TcpSocket.Socket;
  };

  export default TcpSocket;
}
