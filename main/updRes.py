import os
import glob
import json
print("Regenerate qmldirs started")
with open("./UniDesk/Controls/qmldir","w",encoding="utf-8") as f:
    f.write("""module UniDesk.Controls\n""")
    for file in glob.glob(os.path.join("./UniDesk/Controls","*.qml")):
        f.write(os.path.basename(file).replace(".qml","")+" 1.0 "+os.path.basename(file)+"\n")
with open("./UniDesk/Singletons/qmldir","w",encoding="utf-8") as f:
    f.write("""module UniDesk.Singletons\n""")
    for file in glob.glob(os.path.join("./UniDesk/Singletons","*.qml")):
        f.write("singleton "+os.path.basename(file).replace(".qml","")+" 1.0 "+os.path.basename(file)+"\n")
print("Regenerate qmldirs finished")
print("Regenerate resources.qrc started")
with open("./resources.qrc","w",encoding="utf-8") as f:
    f.write("""<RCC>
    <qresource prefix='/'>
        <file>main/main.qml</file>\n""")
    for i,j,k in os.walk("media"):
        if j==[]:
            for p in k:
                f.write("        <file>"+i.replace("\\","/")+"/"+p+"</file>\n")
    f.write("""    </qresource>
</RCC>""")
print("Regenerate resources.qrc finished")