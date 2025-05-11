import requests
from requests_oauthlib import OAuth1
import re
from urllib.parse import parse_qs  # , quote_plus
import tempfile
import subprocess
import os.path
from parsel.selector import Selector
import sys


pandoc_path = (
    '@pandoc@' +
    '/bin/pandoc'
)


def get_post(url):
    body = requests.get(url).text
    selector = Selector(text=body)
    return {
        "title": selector.xpath("//h1[@class='entry-title']/text()")
                         .get(),
        "author":
            "".join(
                selector.xpath("//div[@class='rwtforum-post-by']//text()")
                        .getall()),
        "body":
            "".join(
                selector.xpath("//div[@class='rwtforum-post-body']/node()")
                        .getall()),
        "next":
            selector.xpath("//td[@class='rwtforum-post-navigate-right']"
                           "/a/@href")
                    .get()
    }


def get_thread(url):
    post = get_post(url)
    print("fetching", post['title'])
    result = ("<h1>{title}</h1>"
              "<strong>{author}</strong><br><br>"
              "{body}".format(**post))
    if post["next"] is not None:
        _, rest = get_thread(post["next"])
        result += rest
    return (post['title'], result)


for url in sys.argv[1:]:
    if url.startswith('https://www.realworldtech.com/forum/'):
        title, posts = get_thread(url)
        content = '''
            <html>
                <head><title>{}</title></head>
                <body>{}</body>
            </html>'''.format(title, posts)
        pandoc_filename = (
            '@outputDir@/' +
            re.sub(r'[^\w\s-]', '_', title) + '.pandoc.epub'
        )
        html_file, html_path = tempfile.mkstemp(suffix='.html', text=True)
        with open(html_file, 'w') as f:
            f.write(content)
        subprocess.run([
            pandoc_path,
            '-t', 'epub', '-o', pandoc_filename,
            html_path,
        ])


base_url = 'https://www.instapaper.com/api'
auth = OAuth1(
    client_key='@consumerKey@',
    client_secret='@consumerSecret@'
)
cred = parse_qs(requests.post(
    url=base_url+'/1/oauth/access_token',
    auth=auth,
    data={
        'x_auth_username': '@username@',
        'x_auth_password': '@password@',
        'x_auth_mode': 'client_auth'
    }
).text)
access_token = cred.get('oauth_token')[0]
access_secret = cred.get('oauth_token_secret')[0]

auth = OAuth1(
    client_key='@consumerKey@',
    client_secret='@consumerSecret@',
    resource_owner_key=access_token,
    resource_owner_secret=access_secret
)

for v in requests.post(url=base_url+'/1/bookmarks/list', auth=auth).json():
    if v['type'] != 'bookmark':
        continue
    pandoc_filename = (
        '@outputDir@/' +
        str(v['bookmark_id']) + '.' +
        re.sub(r'[^\w\s-]', '_', v['title']) + '.pandoc.epub'
    )
    ip_filename = (
        '@outputDir@/' +
        str(v['bookmark_id']) + '.' +
        re.sub(r'[^\w\s-]', '_', v['title']) + '.instapaper.epub'
    )
    print("fetching", v['title'], v['bookmark_id'])
    if not os.path.exists(pandoc_filename) and @enablePandoc@:
        pproc = subprocess.run([
            pandoc_path,
            '-t', 'epub', '-o', pandoc_filename,
            v['url'],
        ])
        pstatus = pproc.returncode == 0
    else:
        pstatus = True
    if not os.path.exists(ip_filename) and @enableInstapaper@:
        article = requests.post(
            url=base_url+'/1/bookmarks/get_text',
            auth=auth,
            data={'bookmark_id': v['bookmark_id']}
        ).text
        content = """
            <!DOCTYPE html>
            <html>
                <head>
                    <meta charset="utf-8" />
                    <title>{}</title>
                </head>
                <body>{}</body>
            </html>
        """.format(v['title'], article)
        html_file, html_path = tempfile.mkstemp(suffix='.html', text=True)
        with open(html_file, 'w') as f:
            f.write(content)
        iproc = subprocess.run([
            pandoc_path,
            '-f', 'html',
            '-t', 'epub', '-o', ip_filename,
            html_path,
        ])
        istatus = iproc.returncode == 0
    else:
        istatus = True
    if @autoArchive@ and istatus and pstatus:
        requests.post(
            url=base_url+'/1/bookmarks/archive',
            auth=auth,
            data={'bookmark_id': v['bookmark_id']}
        )
