#!/usr/bin/env python
# coding: utf-8

# In[1]:


import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import os


# ## CONTEXTE
# 
# HéloGlow va bientôt ouvrir un nouveau point de vente dans un centre commercial.
# Nous avons des données sur les clients de ce centre commercial (un dataset Kaggle disponible ici : https://www.kaggle.com/datasets/abdallahwagih/mall-customers-segmentation).
# 
# Variables : 
# - **CustomerID** : Un identifiant unique pour chaque client (integer).
# - **Gender** : Le genre du client (Male/Female).
# - **Age** : L'âge du client (integer).
# - **Annual Income (k$)** : Le revenu annuel du client en milliers de dollars (integer).
# - **Spending Score (1-100)** : Un score attribué par le centre commercial basé sur le comportement et les habitudes de dépenses du client (integer). Plus il est élevé, plus le client est un gros acheteur.
# 
# Nous souhaitons créer des clusters de clients afin de mieux comprendre notre future potentielle clientèle.
# Ainsi, nous saurons comment adapter notre assortiment, quels leviers marketing activer, comment communiquer de manière pertinente à destination des cibles...

# ## 1) VÉRIFICATION DES DONNÉES

# In[110]:


data = pd.read_csv('Mall_Customers.csv',header=0,index_col=False,sep=',',
names = ["CUSTOMER_ID","GENDER","AGE","ANNUAL_INCOME","SPENDING_SCORE"])
# On renomme les colonnes pour enlever les espaces et les caractères spéciaux


# In[111]:


data.head()
# Aperçu des données


# In[112]:


data.shape
# Pour connaître le nombre de lignes et de colonnes


# In[113]:


data.dtypes
# Pour connaître le type de données de chaque colonne


# In[114]:


stats = data.describe(include="all")
stats
# Pour avoir un résumé statistique du dataframe


# On voit qu'il n'y a pas de données manquantes.
# 
# Les données sont cohérentes :
# - Le genre du client prend bien deux modalités.
# - L'âge s'étend de 18 à 70 ans, avec une moyenne à 39 ans.
# - Les montants de revenu annuel sont vraisemblables.

# In[115]:


data[['CUSTOMER_ID']].nunique()
# On vérifie qu'il n'y a pas de client en doublon


# Il n'y a pas de doublon dans les clients puisque le nombre de valeurs uniques est égal au nombre total de lignes.

# ## 2) PRÉPARATION DES DONNÉES

# GENDER est une variable catégorielle, il faut la transformer en colonne numérique.

# In[116]:


# On crée la colonne FEMALE qui prend la valeur 1 si le client est une femme et sinon prend la valeur 0.
data['FEMALE'] = data['GENDER'].apply(lambda x: 1 if x == 'Female' else 0)
# On supprime la colonne GENDER
data.drop('GENDER', axis=1, inplace=True)


# On veut créer des tranches de Spending score pour constituer une variable de contrôle à la fin de la segmentation.

# In[117]:


data["SPENDING_SCORE_BRACKET"] = '0-33'
data.loc[data['SPENDING_SCORE'] >= 33, 'SPENDING_SCORE_BRACKET'] = '33-66'
data.loc[data['SPENDING_SCORE'] >= 66, 'SPENDING_SCORE_BRACKET'] = '66-100'
data['SPENDING_SCORE_BRACKET'] = data['SPENDING_SCORE_BRACKET'].astype('category')
data['SPENDING_SCORE_BRACKET'].describe()


# In[118]:


data.head()


# ## 3) RÉDUCTION DE DIMENSIONS AVEC ACP

# In[119]:


from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA


# In[120]:


# CUSTOMER_ID et SPENDING_SCORE_BRACKET ne sont pas des variables que l'on va projeter
X = data.drop(["CUSTOMER_ID","SPENDING_SCORE_BRACKET"],axis=1)


# In[121]:


# On écrase et on standardise
X = StandardScaler().fit_transform(X)


# In[122]:


# Calcul ACP avec autant de composants que de colonnes (avant de filtrer le nombre de composants càd dimensions)
pca_data = PCA(n_components=X.shape[1])
pca_data.fit(X)
CP_data = pca_data.transform(X)
# On projette les clients sur les nouvelles dimensions


# In[123]:


# Les nouveaux axes pour le premier client
CP_data[0]


# In[124]:


print(np.cumsum(np.round(pca_data.explained_variance_ratio_, decimals=4)*100))


# 2 composantes expliquent 76% de la variance des données.

# In[125]:


plt.plot(np.cumsum(np.round(pca_data.explained_variance_ratio_, decimals=4)*100))
plt.figure()
plt.plot(np.round(pca_data.explained_variance_ratio_, decimals=1))
# arrondi à 1 pour avoir une courbe "à paliers"


# Le Scree plot permet de déterminer le nombre d'axes à retenir.
# 
# Le choix du nombre d'axes à retenir est un compromis entre :
# - La réduction de la dimensionnalité : réduire le nombre de variables pour simplifier l'analyse.
# - La conservation de l'information : ne pas perdre trop d'information en éliminant des axes.
# 
# Ici, le "coude" se situe autour du deuxième axe, ce qui signifie que les deux premiers axes expliquent une part importante de la variance et doivent donc être conservés.

# In[126]:


# On conserve uniquement 2 axes et on fait le rapprochement avec les tranches de Spending score
finalDf = pd.concat([pd.DataFrame(CP_data[:,0:2], columns = ['CP1','CP2']), data[["SPENDING_SCORE",'SPENDING_SCORE_BRACKET']]], axis = 1)
finalDf.head()


# In[127]:


import seaborn as sns


# In[128]:


# On crée un scatter plot coloré en fonction de SPENDING_SCORE_BRACKET
sns.pairplot(x_vars='CP1', y_vars='CP2', data=finalDf, hue='SPENDING_SCORE_BRACKET', height=5)


# On veut pouvoir interpréter les axes.

# In[129]:


analyse = pd.concat([pd.DataFrame(CP_data[:,0:2], columns = ['CP1', 'CP2']), data[["FEMALE","AGE","ANNUAL_INCOME","SPENDING_SCORE"]]], axis = 1)
corr = analyse.corr().loc[["FEMALE","AGE","ANNUAL_INCOME","SPENDING_SCORE"],["CP1","CP2"]]
plt.figure()
sns.heatmap(corr, xticklabels=corr.columns.values, yticklabels=corr.index.values)


# In[130]:


corr


# In[131]:


data.groupby(['SPENDING_SCORE_BRACKET']).mean().T


# CP1 (première composante principale) :
# - L'âge est fortement corrélé positivement avec CP1, c'est une variable importante pour définir cet axe.
# - Le score de dépense est fortement corrélé négativement avec CP1.
# 
# Cela indique que cet axe oppose les individus ayant un âge élevé à ceux ayant un score de dépense élevé.
# 
# CP2 (deuxième composante principale) :
# - Le revenu annuel est fortement corrélé positivement avec CP2.
# - Le fait d'être une femme est corrélé négativement avec CP2.
# 
# CP2 peut donc refléter une opposition entre des femmes et des clients avec un revenu annuel élevé.

# ## 4) CLUSTERING MIXTE

# In[133]:


from sklearn.cluster import KMeans
from sklearn import metrics
from scipy.spatial.distance import cdist
from scipy import cluster
from sklearn.cluster import AgglomerativeClustering


# In[147]:


# On fait une K-means avec de nombreux clusters et on récupère les coordonnées des centroïdes
# Pour le nombre idéal de clusters, une bonne pratique est de choisir n^(1/3)(limite de Wong)
k_means_cent = KMeans(n_clusters = round(len(X)**(1/3)), random_state = 2016).fit(CP_data[:,0:2])


# In[148]:


# Barycentres des clusters issus de la partition K-means
centroides = k_means_cent.cluster_centers_
print(centroides)


# In[149]:


finalDf['K_means_cluster'] = k_means_cent.labels_


# In[150]:


# Nombre de clients dans chaque cluster
pd.crosstab(finalDf['K_means_cluster'], finalDf['SPENDING_SCORE_BRACKET'])


# In[151]:


# On crée 6 "individus fictifs" (barycentres des clusters)
# On trace un dendogramme pour représenter cela visuellement
Z = cluster.hierarchy.linkage(centroides, method='ward', metric='euclidean')

plt.figure()
plt.title('Hierarchical Clustering Dendrogram', fontsize=18)
plt.xlabel('sample index', fontsize=16)
plt.ylabel('distance', fontsize=16)
dn = cluster.hierarchy.dendrogram(Z, leaf_font_size=12, leaf_rotation=90.)


# In[152]:


# On va maintenant limiter le nombre de clusters à 3 en "coupant" le dendogramme
# On fait ainsi un HAC (Hierarchical Agglomerative Clustering)
hac_cent = AgglomerativeClustering(n_clusters = 3, affinity = 'euclidean', linkage = 'ward')
hac_cent.fit(centroides)


# On récupère pour chaque client le cluster assigné lors du K-means.

# In[153]:


kmeans_cent_df = pd.DataFrame(k_means_cent.labels_, columns = ['K-means_cent']).reset_index()
kmeans_cent_df


# In[158]:


# Nombre de clients dans chaque cluster
kmeans_cent_df['K-means_cent'].value_counts()


# In[159]:


# Part de clients dans chaque cluster
kmeans_cent_df['K-means_cent'].value_counts(normalize=True)


# On récupère pour chaque client le cluster assigné lors de l'HAC.

# In[160]:


hac_cent_df = pd.DataFrame(hac_cent.labels_, columns = ['Typologie']).reset_index()
hac_cent_df.sort_values(['Typologie'])


# In[162]:


cluster_cent = pd.merge(kmeans_cent_df, hac_cent_df, left_on=['K-means_cent'], right_on=['index'], how='left')
cluster_cent = cluster_cent.drop(['K-means_cent','index_y'], axis =1)


# In[163]:


# Nombre et part de clients dans chaque cluster
print(cluster_cent['Typologie'].value_counts())
print(cluster_cent['Typologie'].value_counts(normalize=True))


# In[164]:


# Jointure finale
typologie = pd.merge(left=data, right=cluster_cent, how='inner', left_index=True, right_index=True)
typologie.head()


# ## 5) PORTRAITS-ROBOTS

# In[165]:


# Pour chaque cluster, on calcule la moyenne des variables quantitatives (et la proportion des variables qualitatives quand il y en a).
# Des "portraits-robots" vont ainsi se préciser.
# Voici le portrait robot de la classification mixte :

stats = typologie.groupby(['Typologie'])[["FEMALE","AGE","ANNUAL_INCOME","SPENDING_SCORE"]].mean()
stats.T


# - 1er cluster : clientèle plus âgée, peu dépensière
# 
# - 2e cluster : clientèle très féminine, avec un âge et un revenu annuel plus bas
# 
# - 3e cluster : clientèle très masculine, au revenu annuel très élevé

# Au regard de nos ambitions et de notre stratégie d'entreprise, il est plus pertinent de cibler les 2e et 3e clusters, le 1er cluster étant moins attractif en termes de dépenses potentielles.
# 
# HéloGlow étant une entreprise de cosmétiques, nous nous adresserons principalement au 2e cluster (plus féminin). Nous pourrons également proposer une offre complémentaire ciblant les hommes au pouvoir d'achat élevé.
