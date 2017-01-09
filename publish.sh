#!/bin/bash
# make org index
java -jar ../makeOrgIndex/target/makeOrgIndex-1.0.jar
echo 'Please export html by using emacs in 30s'
sleep 30s

#find . ! -path '*.git*' ! -name '.' -type d -exec mkdir -p ../zgj0315.github.io/{} \;
#find . -name '*.html' -exec mv {} ../zgj0315.github.io/{} \;
find . -name '*.org~' -exec rm -f {} \;
find . -name '*.html~' -exec rm -f {} \;
find . -name '.DS_Store' -exec rm -f {} \;
# commit and push to github
git status
git add .
git commit -m 'some org change'
git push origin master
