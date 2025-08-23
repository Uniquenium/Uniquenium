import os
import glob
import json
with open("./UniDesk/Controls/qmldir","w",encoding="utf-8") as f:
    f.write("""module UniDesk.Controls\n""")
    for file in glob.glob(os.path.join("./UniDesk/Controls","*.qml")):
        f.write(os.path.basename(file).replace(".qml","")+" 1.0 "+os.path.basename(file)+"\n")
with open("./UniDesk/Singletons/qmldir","w",encoding="utf-8") as f:
    f.write("""module UniDesk.Singletons\n""")
    for file in glob.glob(os.path.join("./UniDesk/Singletons","*.qml")):
        f.write("singleton "+os.path.basename(file).replace(".qml","")+" 1.0 "+os.path.basename(file)+"\n")

