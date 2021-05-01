from math import sqrt

import pandas as pd
from tabulate import tabulate

pd.set_option('display.max_columns', None)


def print_df(dataframe, nrows):
    """
    Print dataframe rows specified by nrows as table
    """
    print(tabulate(dataframe.head(nrows), headers='keys', tablefmt='psql'))
    print(dataframe.head(nrows).to_latex(index=False))  # convert table to latex format

# Create movies and ratings dataframes
movies_df = pd.read_csv('dataset/movies.csv')
ratings_df = pd.read_csv('dataset/ratings.csv')
print("[initial movies dataframe]")
print_df(movies_df, 10)

# Take the year out of the title column and save it in a new column
regular_expression = r'\((.*?)\)'
movies_df['year'] = movies_df.title.str.lower().str.extract(regular_expression)
movies_df['title'] = movies_df.title.str.replace(regular_expression, '', regex=True)
movies_df['title'] = movies_df['title'].apply(lambda x: x.strip())
# Remove genres column and save movies_df
movies_df = movies_df.drop('genres', 1)
print("[final movies dataframe]")
print_df(movies_df, 10)

# Remove timestamp column and save ratings_df
ratings_df = ratings_df.drop('timestamp', 1)
print("[final ratings dataframe]")
print_df(ratings_df, 10)

# Create user dataframe
user_df = pd.read_csv('dataset/new_user.csv')
# print_df(user_df)

# Filter movies by title
titles = movies_df[movies_df['title'].isin(user_df['title'].tolist())]
user_df = pd.merge(titles, user_df)
user_df = user_df.drop('year', 1)  # Remove year column
#print_df(user_df)

# Filtering the users who have seen the movies
user_titles = ratings_df[ratings_df['movieId'].isin(user_df['movieId'].tolist())]
# Grouping the rows by user ID
user_groups = user_titles.groupby(['userId'])

# User 525
#print_df(user_groups.get_group(525))

# Sort with high priority the users with the most movies in common
user_groups = sorted(user_groups, key=lambda x: len(x[1]), reverse=True)

# Pearson
user_groups = user_groups[0:100]  # Choosing a subset of users to do the iterations.
pearsonCorrelationDict = {}
for name, group in user_groups:  # For each user
    # Sorting the current user in such a way that the values don't get mixed up later
    user = group.sort_values(by='movieId')
    movies = user_df.sort_values(by='movieId')

    # Get the number of elements (N) for the formula
    nRatings = len(user)

    # Set ratings for movies in common in a list
    temp_df = movies[movies['movieId'].isin(user['movieId'].tolist())]
    tempRatingList = temp_df['rating'].tolist()

    # Set user ratings in a list
    tempGroupList = user['rating'].tolist()

    # Calculate the Pearson Correlation between two users, x and y
    Uxx = sum([i ** 2 for i in tempRatingList]) - pow(sum(tempRatingList), 2) / float(nRatings)
    Uyy = sum([i ** 2 for i in tempGroupList]) - pow(sum(tempGroupList), 2) / float(nRatings)
    Uxy = sum(i * j for i, j in zip(tempRatingList, tempGroupList)) - sum(tempRatingList) * sum(tempGroupList) / float(
        nRatings)

    # If the denominator is nonzero, then we divide, otherwise the correlation is 0
    if Uxx != 0 and Uyy != 0:
        pearsonCorrelationDict[name] = Uxy / sqrt(Uxx * Uyy)

    else:
        pearsonCorrelationDict[name] = 0

# print(pearsonCorrelationDict.items())

# Create pearson dataframe
pearson_df = pd.DataFrame.from_dict(pearsonCorrelationDict, orient='index')
pearson_df.columns = ['similarityIndex']
pearson_df['userId'] = pearson_df.index
pearson_df.index = range(len(pearson_df))
#print_df(pearson_df)

# Get the top 50 most similar users
topUsers = pearson_df.sort_values(by='similarityIndex', ascending=False)[0:50]
# print_df(topUsers)

# Merge ratings and top users dataframe
topUsersRating = topUsers.merge(ratings_df, left_on='userId', right_on='userId', how='inner')
# The similarity of user ratings is multiplied
topUsersRating['weightedRating'] = topUsersRating['similarityIndex'] * topUsersRating['rating']
#print_df(topUsersRating)
# A sum is applied to the top users after grouping them by userId
tempTopUsersRating = topUsersRating.groupby('movieId').sum()[['similarityIndex', 'weightedRating']]
tempTopUsersRating.columns = ['sum_similarityIndex', 'sum_weightedRating']
#print_df(topUsersRating)

# Recommend movies to new user
recommendation_df = pd.DataFrame()
# Calculate the weighted average
recommendation_df['weighted average recommendation score'] = tempTopUsersRating['sum_weightedRating'] / \
                                                             tempTopUsersRating['sum_similarityIndex']
recommendation_df['movieId'] = tempTopUsersRating.index

# The first 20 movies the algorithm recommends
recommendation_df = recommendation_df.sort_values(by='weighted average recommendation score', ascending=False)
recommendation_df = movies_df.loc[movies_df['movieId'].isin(recommendation_df.head(10)['movieId'].tolist())]
#print_df(recommendation_df)
