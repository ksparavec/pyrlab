#!/usr/bin/env python
import os
import yaml
import shutil
import subprocess

data = yaml.safe_load(open('repositories.yml'))
os.chdir('/tmp')
for repo in data:
    if repo['enable'] == "yes":
        print('Cloning remote repository ' + repo['name'])
        subprocess.run(['git', 'clone', repo['url']], stdout=subprocess.PIPE, universal_newlines=True)
        dir = repo['url'].split("/")[-1]
        os.chdir(dir)
        print('Running ' + repo['command'])
        subprocess.run(repo['command'].split(" "), stdout=subprocess.PIPE, universal_newlines=True)
        print('Removing ' + '/tmp/' + dir)
        shutil.rmtree('/tmp/' + dir)

