import asyncio
import threading
import time
from typing import Set

class TelnetServer:
    def __init__(self, host='0.0.0.0', port=2323, ping_interval=5):
        self.host = host
        self.port = port
        self.ping_interval = ping_interval
        self.clients: Set[asyncio.StreamWriter] = set()
        self.server = None
        self.running = False
        
    async def handle_client(self, reader: asyncio.StreamReader, writer: asyncio.StreamWriter):
        """Обработка подключения нового клиента"""
        # client_addr = writer.get_extra_info('peername')
        # print(f"Новый клиент подключен: {client_addr}")
        print(f"Новый клиент подключен!")
        
        # Добавляем клиента в множество
        self.clients.add(writer)
        
        try:
            ...
            # # Отправляем приветственное сообщение
            # welcome = "Добро пожаловать на Telnet сервер!\r\n"
            # welcome += "Вы будете получать ping каждые несколько секунд.\r\n"
            # welcome += "Для выхода введите 'quit' или закройте соединение.\r\n\r\n"
            # writer.write(welcome.encode())
            # await writer.drain()
            
            # # Читаем данные от клиента (необязательно, но можно обрабатывать команды)
            # while True:
            #     try:
            #         data = await asyncio.wait_for(reader.read(1024), timeout=1.0)
            #         if not data:
            #             break
                    
            #         # Преобразуем полученные данные в строку
            #         message = data.decode().strip()
            #         print(f"Получено от {client_addr}: {message}")
                    
            #         # Обработка команды quit
            #         if message.lower() == 'quit':
            #             writer.write("До свидания!\r\n".encode())
            #             await writer.drain()
            #             break
                        
            #     except asyncio.TimeoutError:
            #         # Таймаут чтения - просто продолжаем
            #         continue
            #     except Exception as e:
            #         print(f"Ошибка при чтении от {client_addr}: {e}")
            #         break
                    
        except Exception as e:
            # print(f"Ошибка при обработке клиента {client_addr}: {e}")
            print(f"Ошибка при обработке клиента: {e}")
        finally:
            # Удаляем клиента при отключении
            # print(f"Клиент отключен: {client_addr}")
            print(f"Клиент отключен!")
            self.clients.discard(writer)
            writer.close()
            await writer.wait_closed()
    
    async def ping_clients(self):
        """Периодическая рассылка ping всем клиентам"""
        while self.running:
            try:
                await asyncio.sleep(self.ping_interval)
                
                if not self.clients:
                    print("Нет подключенных клиентов для отправки ping")
                    continue
                
                print(f"Отправка ping {len(self.clients)} клиентам")
                
                # Создаем копию множества, чтобы избежать изменений во время итерации
                dead_clients = set()
                
                for writer in self.clients.copy():
                    try:
                        ping_message = f"ping {time.strftime('%H:%M:%S')}\r\n"
                        writer.write(ping_message.encode())
                        await writer.drain()
                    except Exception as e:
                        print(f"Ошибка при отправке ping клиенту: {e}")
                        dead_clients.add(writer)
                
                # Удаляем мертвые соединения
                for dead_client in dead_clients:
                    self.clients.discard(dead_client)
                    
            except Exception as e:
                print(f"Ошибка в цикле ping: {e}")
    
    async def start_server(self):
        """Запуск сервера"""
        self.running = True
        
        # Запускаем сервер
        self.server = await asyncio.start_server(
            self.handle_client, self.host, self.port
        )
        
        print(f"Telnet сервер запущен на {self.host}:{self.port}")
        print(f"Интервал ping: {self.ping_interval} секунд")
        
        # Запускаем задачу рассылки ping
        ping_task = asyncio.create_task(self.ping_clients())
        
        try:
            # Ожидаем подключений
            async with self.server:
                await self.server.serve_forever()
        except KeyboardInterrupt:
            print("\nПолучен сигнал остановки...")
        finally:
            self.running = False
            ping_task.cancel()
            await self.stop_server()
    
    async def stop_server(self):
        """Остановка сервера"""
        print("Остановка сервера...")
        
        # Закрываем все клиентские соединения
        for writer in self.clients:
            try:
                writer.write("Сервер завершает работу. До свидания!\r\n".encode())
                await writer.drain()
                writer.close()
                await writer.wait_closed()
            except:
                pass
        
        self.clients.clear()
        
        if self.server:
            self.server.close()
            await self.server.wait_closed()
        
        print("Сервер остановлен")

def run_server():
    """Функция для запуска сервера"""
    host = input("Введите хост для прослушивания (по умолчанию 0.0.0.0): ") or "0.0.0.0"
    port = input("Введите порт (по умолчанию 2323): ") or "2323"
    interval = input("Введите интервал ping в секундах (по умолчанию 5): ") or "5"
    
    try:
        port = int(port)
        interval = int(interval)
    except ValueError:
        print("Ошибка: порт и интервал должны быть числами")
        return
    
    server = TelnetServer(host, port, interval)
    
    try:
        asyncio.run(server.start_server())
    except KeyboardInterrupt:
        print("\nСервер остановлен пользователем")
    except Exception as e:
        print(f"Ошибка при запуске сервера: {e}")

if __name__ == "__main__":
    print("=== Telnet Ping Server ===")
    print("Сервер будет отправлять 'ping' всем подключенным клиентам")
    print("Для подключения используйте: telnet <ip_сервера> <порт>")
    print("Для выхода введите 'quit' или нажмите Ctrl+C\n")
    
    run_server()