import seaborn as sns
import matplotlib.pyplot as plt
import pandas as pd


def createGraph(values, col):
    plt.figure(num=None, figsize=(20, 18), dpi=80, facecolor='w', edgecolor='r')
    g = sns.barplot(x="Label", y=col, data=values)
    plt.xticks(rotation=90)
    plt.savefig('images/{}.png'.format(col))


if __name__ == '__main__':
    df = pd.read_csv("dataset/diseasome.csv", sep=",")
    df_disease = df[df['0'].str.contains("disease")]
    df_disease = df_disease[df_disease["degree"] > 15]

    colNames = ["degree", "betweenesscentrality", "closnesscentrality", "eigencentrality"]
    for colName in colNames:
        createGraph(df_disease, colName)
