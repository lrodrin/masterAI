from math import sqrt
from tabulate import tabulate

import pandas as pd

pd.set_option('display.max_columns', None)


def print_df(dataframe):
    """
    Print dataframe as table
    """
    print(tabulate(dataframe.head(), headers='keys', tablefmt='psql'))
    print(dataframe.head().to_latex(index=False))  # convert table to latex format


# Create movies and ratings dataframes
movies_df = pd.read_csv('dataset/movies.csv')
ratings_df = pd.read_csv('dataset/ratings.csv')
print_df(movies_df)
print_df(ratings_df)

# Take the year out of the title column and save it in the new year column
regular_expression = r'\((.*?)\)'
movies_df['year'] = movies_df.title.str.lower().str.extract(regular_expression)
movies_df['title'] = movies_df.title.str.replace(regular_expression, '', regex=True)
movies_df['title'] = movies_df['title'].apply(lambda x: x.strip())
movies_df = movies_df.drop('genres', 1)  # Remove genres column
# print_df(movies_df)

ratings_df = ratings_df.drop('timestamp', 1)  # Remove timestamp column
# print(ratings_df.head())

# Create user
user_df = pd.read_csv('dataset/user_ratings.csv')
# print(user_df.head())

# Filter movies by title
titles = movies_df[movies_df['title'].isin(user_df['title'].tolist())]
user_df = pd.merge(titles, user_df)
user_df = user_df.drop('year', 1)  # Remove year column
# print(user_df.head())

# Filtering the users who have seen the movies
user_titles = ratings_df[ratings_df['movieId'].isin(user_df['movieId'].tolist())]
# print(user_titles.head())

# Grouping the rows by user ID
user_groups = user_titles.groupby(['userId'])

# User 525
# print(user_groups.get_group(525))

# Sort so that users with the most movies in common have priority
user_groups = sorted(user_groups, key=lambda x: len(x[1]), reverse=True)
# print(user_groups[0:3])  # First user

# Pearson
user_groups = user_groups[0:100]  # to iterate
pearsonCorrelationDict = {}
# For each group of users in our subset
for name, group in user_groups:
    # Let's start by sorting the current and entered user in such a way that the values don't get mixed up later
    group = group.sort_values(by='movieId')
    inputMovies = user_df.sort_values(by='movieId')
    # Get the N for the formula
    nRatings = len(group)
    # Get review scores for movies in common
    temp_df = inputMovies[inputMovies['movieId'].isin(group['movieId'].tolist())]
    # Save them to a temporary variable in list format to facilitate future calculations
    tempRatingList = temp_df['rating'].tolist()
    # Let's also list user group reviews
    tempGroupList = group['rating'].tolist()
    # Let's calculate the Pearson Correlation between two users, x and y
    Sxx = sum([i ** 2 for i in tempRatingList]) - pow(sum(tempRatingList), 2) / float(nRatings)
    Syy = sum([i ** 2 for i in tempGroupList]) - pow(sum(tempGroupList), 2) / float(nRatings)
    Sxy = sum(i * j for i, j in zip(tempRatingList, tempGroupList)) - sum(tempRatingList) * sum(tempGroupList) / float(
        nRatings)

    # Si el denominador es diferente a cero, entonces dividir, sino, la correlación es 0.
    if Sxx != 0 and Syy != 0:
        pearsonCorrelationDict[name] = Sxy / sqrt(Sxx * Syy)
    else:
        pearsonCorrelationDict[name] = 0

# print(pearsonCorrelationDict)

pearsonDF = pd.DataFrame.from_dict(pearsonCorrelationDict, orient='index')
pearsonDF.columns = ['similarityIndex']
pearsonDF['userId'] = pearsonDF.index
pearsonDF.index = range(len(pearsonDF))
# print(pearsonDF.head())

topUsers = pearsonDF.sort_values(by='similarityIndex', ascending=False)[0:50]
# print(topUsers.head())

topUsersRating = topUsers.merge(ratings_df, left_on='userId', right_on='userId', how='inner')
# print(topUsersRating.head())

# The similarity of user scores is multiplied
topUsersRating['weightedRating'] = topUsersRating['similarityIndex'] * topUsersRating['rating']
# print(topUsersRating.head())

# A sum is applied to the topUsers after grouping them by userId
tempTopUsersRating = topUsersRating.groupby('movieId').sum()[['similarityIndex', 'weightedRating']]
tempTopUsersRating.columns = ['sum_similarityIndex', 'sum_weightedRating']
# print(tempTopUsersRating.head())

recommendation_df = pd.DataFrame()
# Now the weighted average is taken
recommendation_df['weighted average recommendation score'] = tempTopUsersRating['sum_weightedRating'] / \
                                                             tempTopUsersRating['sum_similarityIndex']
recommendation_df['movieId'] = tempTopUsersRating.index
# print(recommendation_df.head())

recommendation_df = recommendation_df.sort_values(by='weighted average recommendation score', ascending=False)
# print(recommendation_df.head(10))

# print(movies_df.loc[movies_df['movieId'].isin(recommendation_df.head(10)['movieId'].tolist())])
