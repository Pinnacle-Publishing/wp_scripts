import os
from jinja2 import Template
import argparse
import validators


def get_sitename(domain: str):
    return domain.split('.')[-2]


def get_nginx_sample():
    with open("site.nginx", 'r', encoding='UTF-8') as file:
        return file.read()


def get_pool_sample():
    with open("pool.conf", 'r', encoding='UTF-8') as file:
        return file.read()


def save_report(file_path, html_content):
    with open(file_path, 'w+', encoding='UTF-8') as file:
        file.write(html_content)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Process domain.')
    parser.add_argument('domains', metavar='domains', type=str, nargs='+',
                        help='an integer for the accumulator')
    args = parser.parse_args()

    print(args.domains)

    for do in args.domains:
        if not validators.domain(do):
            raise Exception("Invalid domain")
        site_name = get_sitename(do)
        data = {
            'site_name': site_name,
            'domain': do,
        }
        print("============ make code folder ==================")
        os.system(f'mkdir -p /var/www/{site_name}/public_html')

        nginx_path = f'/etc/nginx/sites-available/{site_name}'
        nginx_enable_path = f'/etc/nginx/sites-enabled/{site_name}'

        print("============ symlink nginx config ==================")
        os.system(f'ln -s {nginx_path} {nginx_enable_path}')

        pool_path = f'/etc/php/7.4/fpm/pool.d/fpm-{site_name}.conf'

        jinja2_nginx = Template(get_nginx_sample())
        jinja2_pool = Template(get_pool_sample())
        nginx_content = jinja2_nginx.render(**data)
        poll_content = jinja2_pool.render(**data)

        save_report(nginx_path, nginx_content)
        save_report(pool_path, poll_content)
