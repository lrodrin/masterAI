"""
Generate dataset
"""
import csv
import pandas as pd

data = {
    "Contador": [170, 20, 45, 139, 30, 130, 255, 11],
    "Tamaño": ["Grande", "Grande", "Pequeño", "Pequeño", "Grande", "Grande", "Pequeño", "Pequeño"],
    "Órbita": ["Cercana", "Cercana", "Lejana", "Cercana", "Lejana", "Cercana", "Lejana", "Cercana"],
    "Temperatura": ["M", "A", "M", "M", "B", "B", "B", "A"],
    "Habitable": ["Si", "Si", "Si", "Si", "No", "No", "No", "No"]
}

df = pd.DataFrame(data, columns=list(data.keys()))
columnames = df.columns.tolist()
contador = data["Contador"]

with open("dataset.csv", "w") as fd:
    csv.writer(fd).writerow(columnames)  # add column names
    for n in range(len(contador)):
        for i in range(contador[n]):
            df.loc[[n]].to_csv(fd, index=False, header=False, mode="a")
