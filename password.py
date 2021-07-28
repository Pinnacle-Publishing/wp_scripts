import argparse
import os
import secrets
import string
import requests
import validators
from jinja2 import Template


def get_sitename(domain: str):
    return domain.split('.')[-2]


def get_wp_sample():
    with open("wp-config.php", 'r', encoding='UTF-8') as file:
        return file.read()


def save_report(file_path, file_content):
    with open(file_path, 'w+', encoding='UTF-8') as file:
        file.write(file_content)


def generate_password() -> str:
    alphabet = string.ascii_letters + string.digits  # + string.punctuation  If you want symbol in password
    password = ''.join(secrets.choice(alphabet) for i in range(20))  # for a 20-character password
    return password.strip()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Process domain.')
    parser.add_argument('domain', metavar='domain', type=str, nargs='+',
                        help='an integer for the accumulator')
    args = parser.parse_args()

    print(args.domain)

    for do in args.domain:
        if not validators.domain(do):
            raise Exception("Invalid domain")
        site_name = get_sitename(do)
        res = requests.get('https://api.wordpress.org/secret-key/1.1/salt/').text

        data = {
            'site_name': site_name,
            'domain': do,
            'KEY': res.strip()
        }

        try:
            f = open(f"{site_name}.txt")
            passwd = f.read()
            f.close()
        except Exception as e:
            print(e)
            passwd = generate_password()
            with open(f"{site_name}.txt", 'w+') as f:
                f.write(passwd)

        data.update({'password': passwd.strip()})

        wp_path = f"/var/www/{site_name}/public_html/wp-config.php"

        jinja2_wp = Template(get_wp_sample())
        wp_content = jinja2_wp.render(**data)
        save_report(wp_path, wp_content)
