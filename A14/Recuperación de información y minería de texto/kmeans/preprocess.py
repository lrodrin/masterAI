import pandas as pd
import json


def printNcategories():
    nCategories = df.groupby('category').size()
    print(nCategories)
    print("number of categories: {}".format(len(nCategories)))


# books dataset
books = open("../books/books.json", "r")
dict_books = json.load(books)

# create df
df = pd.DataFrame.from_dict(dict_books)

# categories
printNcategories()

# remove categories that only appear once
uniqueCategories = ["Academic", "Adult Fiction", "Crime", "Cultural", "Erotica", "Novels", "Paranormal", "Parenting",
                    "Short Stories", "Suspense"]

df = df[~df['category'].isin(uniqueCategories)]
printNcategories()

# convert categories to numbers and save it to new column topic
df['category'] = pd.Categorical(df['category'])  # change the type of the column
df['topic'] = df['category'].cat.codes

# re oder df columns
df = df[['topic', 'category', 'title', 'description']]

# save df to csv
df.to_csv("books.csv", index=False, sep=",")
