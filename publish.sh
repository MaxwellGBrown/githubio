pelican content -o output -s publishconf.py
ghp-import -m "$1" --no-jekyll -b master output
git push origin master
