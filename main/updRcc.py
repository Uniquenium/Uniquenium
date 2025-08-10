import os

print("Regenerate resources.qrc started")
with open("./resources.qrc","w",encoding="utf-8") as f:
    f.write("""<RCC>
    <qresource prefix='/'>
            """)
    for i,j,k in os.walk("media"):
        if j==[]:
            for p in k:
                f.write("        <file>"+i.replace("\\","/")+"/"+p+"</file>\n")
    f.write("""    </qresource>
</RCC>""")
print("Regenerate resources.qrc finished")
print("Regenerate main/res.py started")
os.system("pyside6-rcc resources.qrc -o main/res.py")
print("Regenerate main/res.py finished")