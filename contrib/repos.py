#!/usr/bin/env python
import os
import yaml
import shutil
import subprocess

data = yaml.safe_load(open('/usr/local/etc/repositories.yml'))

for repo in data:
    if repo['enable'] == "yes":
        try:
            os.chdir('/tmp')
            print('Cloning remote repository ' + repo['name'])
            try:
                subprocess.run(['git', 'clone', repo['url']], stdout=subprocess.PIPE, universal_newlines=True)
            except:
                raise Exception('Cloning remote repository ' + repo['name'] + ' failed')
            dir = repo['url'].split("/")[-1]
            os.chdir(dir)
            print('Running ' + repo['command'])
            try:
                subprocess.run(repo['command'].split(" "), stdout=subprocess.PIPE, universal_newlines=True)
            except:
                raise Exception('Running ' + repo['command'] + ' failed')
            finally:
                print('Removing ' + '/tmp/' + dir)
                shutil.rmtree('/tmp/' + dir)
            print('Installation of ' + repo['name'] + ' successful')
        except:
            print('Installation of ' + repo['name'] + ' failed')
