# maxwellgbrown.github.io

This setup was shamelessly copied from [this blog post](https://opensource.com/article/19/5/run-your-blog-github-pages-python).

## quickstart

0. Create/start the virtual environment
```
$ mkvirtualenv githubio
$ pip install -r requirements.txt
```

1.  Run Pelican to generate the static HTML files in output:
```
$ pelican content -o output -s publishconf.py
```

2. Use ghp-import to add the contents of the output directory to the master branch:
```
$ ghp-import -m "Generate Pelican site" --no-jekyll -b master output
```

3. Push the local master branch to the remote repo:
```
$ git push origin master
```

4. Commit and push the new content to the content branch:
```
$ git add content
$ git commit -m 'added a first post, a photo and an about page'
$ git push origin content
```
