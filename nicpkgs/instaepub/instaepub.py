import requests
from requests_oauthlib import OAuth1
import re
from urllib.parse import parse_qs  # , quote_plus
import tempfile
import subprocess
import os.path

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
    filename = (
        '@outputDir@/' +
        re.sub(r'[^\w\s-]', '', v['title']) +
        '.' + str(v['bookmark_id']) + '.epub'
    )
    if os.path.exists(filename):
        continue
    print("fetching", v['title'], v['bookmark_id'])
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
    pandoc_path = (
        '@pandoc@' +
        '/bin/pandoc'
    )
    html_file, html_path = tempfile.mkstemp(suffix='.html', text=True)
    with open(html_file, 'w') as f:
        f.write(content)
    subprocess.run([
        pandoc_path,
        '-f', 'html', '-t', 'epub', '-o', filename,
        html_path
    ])
