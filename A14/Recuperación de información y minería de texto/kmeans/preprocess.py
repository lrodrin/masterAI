import pandas as pd
import json
import matplotlib.pyplot as plt

plt.rcParams['figure.figsize'] = (16, 9)
plt.style.use('ggplot')


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
df['category'] = pd.Categorical(df['category'])
df['title'] = pd.Categorical(df['title'])
df['category_c'] = df['category'].cat.codes
df['title_c'] = df['title'].cat.codes

# re oder df columns
df = df[['category_c', 'category', 'title_c', 'title', 'description']]

# save df to csv
df.to_csv("books.csv", index=False, sep=",")

# df visualization
df['category'].value_counts().plot(kind="bar")
plt.suptitle('Books categories', fontsize=20)
plt.ylabel('Frequency', fontsize=16)
plt.show()
