build:
	rm -f dist/data.zip
	mkdir -p dist
	zip -r dist/data.zip * -x Makefile -x dist/* -x .github/* -x .git/* -x .gitignore -x .editorconfig -x README.md