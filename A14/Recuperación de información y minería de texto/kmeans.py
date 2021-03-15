import pandas as pd
import json

# dataset from spider
train_file = open("books/books.json", "r")
dict_train = json.load(train_file)

# create df
train = pd.DataFrame.from_dict(dict_train)
# print(train.head(10))
# print(train.describe())
print(train.groupby('category').size())