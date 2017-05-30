#!/bin/bash
file="index.zip"
if [ ! -d node_modules ];
then
	npm install ua-parser-js
	npm install mysql
fi
zip -r $file *.js node_modules
