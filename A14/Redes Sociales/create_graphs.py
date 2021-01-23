import seaborn as sns
import matplotlib.pyplot as plt
import pandas as pd

df = pd.read_csv("dataset/diseasome.csv", sep=",")
df_disease = df[df['0'].str.contains("disease")]
df_disease = df_disease[df_disease["degree"] > 15]
print df_disease
plt.figure(num=None, figsize=(20, 18), dpi=80, facecolor='w', edgecolor='r')
g = sns.barplot(x="Label", y="degree", data=df_disease)
plt.xticks(rotation=90)
plt.savefig('images/plt_degree.png')
