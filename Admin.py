import paramiko
from kivy.app import App
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.textinput import TextInput
from kivy.uix.button import Button
from kivy.uix.label import Label
from kivy.uix.scrollview import ScrollView
from kivy.utils import platform
from kivy.clock import Clock

class SSHClientApp(App):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.command_history = []  # Тут вроде типо консоли

    def build(self):
        root = BoxLayout(orientation='vertical')

        # тут типо вводишь текст
        hostname_input = TextInput(hint_text='Hostname', multiline=False)
        port_input = TextInput(hint_text='Port', multiline=False)
        username_input = TextInput(hint_text='Username', multiline=False)
        password_input = TextInput(hint_text='Password', multiline=False, password=True)
        console_output = Label(text='', size_hint_y=None, height=400)

        # А это кнопка отправки комманд
        send_command_button = Button(text='Send Command', on_press=lambda x: self.send_command(
            hostname_input.text,
            int(port_input.text),
            username_input.text,
            password_input.text,
            console_output
        ))

        # Тут жмакаешь и отправляется коммада запуска
        execute_command_button = Button(text='Execute Command in Terminal', on_press=lambda x: self.execute_command_terminal(
            hostname_input.text,
            int(port_input.text),
            username_input.text,
            password_input.text
        ))

        # Тут консоль прокручивать можно
        console_scroll = ScrollView()
        console_scroll.add_widget(console_output)

        # Виджеты и всякая хрень
        root.add_widget(hostname_input)
        root.add_widget(port_input)
        root.add_widget(username_input)
        root.add_widget(password_input)
        root.add_widget(send_command_button)
        root.add_widget(execute_command_button)
        root.add_widget(console_scroll)

        return root

    def send_command(self, hostname, port, username, password, console_output):
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

        try:
            # Подключаешься к другому компу
            client.connect(hostname, port=port, username=username, password=password)
            
            # Тут я сделал отдельную кнопку для отправки логов и запуска проверки компьютера комманда выглядит так ./secret/3test.sh
            command = "./secret/3test.sh"
            stdin, stdout, stderr = client.exec_command(command)
            output = stdout.read().decode('utf-8')

            console_output.text += f'\n\nCommand: {command}\nOutput:\n{output}'

            # Тут комманда в историю добавляется
            self.command_history.append(command)

        except paramiko.AuthenticationException:
            console_output.text += '\n\nAuthentication Error'
        except paramiko.SSHException:
            console_output.text += '\n\nSSH Connection Error'
        except paramiko.ChannelException:
            console_output.text += '\n\nChannel Creation Error'
        finally:
            client.close()

    def execute_command_terminal(self, hostname, port, username, password):
        # ну вроде по изночальной идее оно должно открывать консоль, но оно не работало а убирать страшно, вдруг сломается что то
        if platform == 'win':
            command = f"start ssh {username}@{hostname} -p {port} './secret/3test.sh'"
        elif platform == 'linux':
            # тут типо можно и для винды, но не пробовал
            command = f"gnome-terminal --command='ssh {username}@{hostname} -p {port} \"./secret/3test.sh\"'"
        else:
            return

        subprocess.call(command, shell=True)

if __name__ == '__main__':
    SSHClientApp().run()
