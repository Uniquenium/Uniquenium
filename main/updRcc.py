import os
print("Regenerate main/res.py started")
os.system("pyside6-rcc resources.qrc -o main/res.py")
print("Regenerate main/res.py finished")