import pdfkit 
options = {'print-media-type': None, 'background': None, 'images': None, 'quiet': None, 'encoding': 'UTF-8', 'margin-right': '15mm', 'margin-left': '15mm', 'margin-top': '15mm', 'margin-bottom': '15mm', 'cookie': [('sid', 'b9aa3ae87da55955c3b679d553db07eb81e2a1760ebb682599ab9196')], 'page-size': 'A4', 'disable-javascript': '', 'disable-local-file-access': ''}

f=open("test.html", "r")
html = f.read()
fname = "/tmp/test/test.pdf"
pdfkit.from_string(html, fname, options=options or {})
