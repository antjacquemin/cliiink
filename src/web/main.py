#!/usr/bin/env python
# coding: UTF-8
from flask import Flask, request, render_template, g, session, make_response, redirect, url_for
import jinja2, os, config, users
from sqlalchemy.sql import text
import folium
from folium import plugins

import pandas as pd
from json import load, dumps
from sqlalchemy import create_engine
import plotly.express as px
from plotly.utils import PlotlyJSONEncoder

#Définition de la variable d'Application Flask
app = Flask(__name__)

#Définition des variables de configurations de Flask & son environnement
app.config.from_object(users)
app.config.from_object(config)
capp, users          = app.config['APP_VAR'], app.config['USERS']
currentEnvironnement = capp['environment']
app.config.update(
SERVER_NAME = capp[currentEnvironnement]['complete_server_host'],
SECRET_KEY  = capp['secret_key']
)

#Connexion a la Base de Donnée
engine = create_engine('mysql+pymysql://'+capp[currentEnvironnement]['db_user']+':'+capp[currentEnvironnement]['db_pass']+'@'+capp[currentEnvironnement]['db_host']+'/'+capp[currentEnvironnement]['db_name']+'?charset=utf8')
con    = engine.connect()

requeteCollecteurs = pd.read_sql_query("SELECT * FROM collecteur JOIN tri ON collecteur.idTri = tri.id LEFT JOIN marque ON collecteur.idMarque = marque.id LEFT JOIN categorie ON collecteur.idCategorie = categorie.id;", engine)
requeteDecheteries = pd.read_sql_query("SELECT * FROM decheterie;", engine)

dataCollecteurs = pd.DataFrame(requeteCollecteurs)
dataDecheteries = pd.DataFrame(requeteDecheteries)


# Renommage des colonnes types pour éviter les confusions (et les erreurs)
cols = []
isTri = True
for column in dataCollecteurs.columns:
    if column == "type":
        if isTri:
            cols.append("typeTri")
            isTri = False
        else:
            cols.append("typeCollecteur")
    else:
        cols.append(column)
dataCollecteurs.columns = cols

# Rajout d'une colonne villes par association code INSEE - ville depuis un dictionnaire (pour faciliter les affichages)
dictVilles = { "06029": "Cannes", "06030": "Le Cannet", "06079": "Mandelieu-la-Napoule", "06085": "Mougins", "06138": "Théoule-sur-Mer"}

for i in dataCollecteurs.index:
    dataCollecteurs.loc[i, "ville"] = dictVilles[dataCollecteurs.loc[i, "codeInsee"]]
dataCollecteurs.rename(columns={"ville": "Ville", "nom": "Marque", "volume": "Volume"}, inplace=True)


# Jeu de couleurs de la CACPL
dictVillesCouleurs = {"Cannes": "#7bc3b7", "Le Cannet": "#528238", "Mandelieu-la-Napoule": "#fab55a", "Mougins": "#e84e2c", "Théoule-sur-Mer": "#507999"}
# Jeu de couleurs utilisé pour les icones des collecteurs de la carte
dictTrisCouleurs = {"om": "#bf3932", "papier": "#3e8ecc", "emballage": "#c0b132", "verre": "#35c032", "vêtement": "#31a9be"}


data171819 = pd.read_excel("static/Données Verre 2017-2018- 2019 janv à nov.xlsx", skiprows=[0,1], usecols="B:L")
data20 = pd.read_excel("static/Verre PAV 2020.xlsx", skiprows=[0,1,2], usecols="B:F")

data171819.drop_duplicates(inplace=True)
data20.drop_duplicates(subset=data20.columns[1:], inplace=True)

dictVilles = { "CAN": "Cannes", "CNT": "Le Cannet", "MAN": "Mandelieu-la-Napoule", "MOU": "Mougins", "THE": "Théoule-sur-Mer"}

dictVillesMajuscules = { "CANNES": "Cannes", "LE CANNET": "Le Cannet", "MANDELIEU-LA-NAPOULE": "Mandelieu-la-Napoule", "MOUGINS": "Mougins", "THÉOULE-SUR-MER": "Théoule-sur-Mer"}
# Transformation des valeurs de la colonne par association avec le dictionnaire
for i in data171819.index:
    data171819.loc[i, "Ville"] = dictVillesMajuscules[data171819.loc[i, "Ville"]]

# Standardisation des noms des colonnes utilisées
data171819.rename(columns={"MOIS": "Mois", "Poids Kg": "Poids"}, inplace=True)

listeMois = ["Janvier", "Février", "Mars", "Avril", "Mai", "Juin", "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"]
# Mois devient une variable qualitative (ou catégorielle) qui suit l'ordre défini dans listeMois
data171819["Mois"] = pd.Categorical(data171819["Mois"], listeMois)
# Tri du jeu de données selon la colonne Mois
data171819.sort_values(["Ville", "Année", "Mois"], inplace=True)

for i in data20.index:
    data20.loc[i, "Ville"] = dictVilles[data20.loc[i, "Lieu de Collecte"][5:8]]
    data20.loc[i, "Lieu de Collecte"] = data20.loc[i, "Lieu de Collecte"][9:]
data20.Poids = (data20.Poids * 1000).astype(int)

data171819Mois = data171819.groupby(by=["Ville", "Année", "Mois"], sort=False, observed=True).size().reset_index(name="Nombre")

# Ajout de la colonne pour l'année à data20 pour faire correspondre au format
data20["Année"] = 2020
# Ajout de la colonne pour le mois à partir de la date
data20["Mois"] = pd.to_datetime(data20["Date de réalisation"]).dt.month
# Conversion du nombre du mois en toutes lettres par correspondance avec la liste chronologique des mois
for i in data20.index:
    data20.loc[i, "Mois"] = listeMois[data20.loc[i, "Mois"] - 1]
data20Mois = data20.groupby(by=["Ville", "Année", "Mois"], sort=False, observed=True).size().reset_index(name="Nombre")

# Concaténation des 2 dataframes
dataMoisAnnee = pd.concat([data171819Mois, data20Mois])




data171819MoisPoids = data171819.groupby(by=["Ville", "Année", "Mois"], sort=False, observed=True)["Poids"].sum().reset_index(name="Poids")

data20MoisPoids = data20.groupby(by=["Ville", "Année", "Mois"], sort=False, observed=True)["Poids"].sum().reset_index(name="Poids")

dataMoisAnneePoids = pd.concat([data171819MoisPoids, data20MoisPoids])
dataMoisAnneePoids["Période"] = dataMoisAnneePoids["Mois"] + " " + dataMoisAnneePoids["Année"].astype(str)
data20MoisPoids = dataMoisAnneePoids[dataMoisAnneePoids["Année"] == 2020]

#URL d'affichage de la page pour la Carte
@app.route('/map')
def map():
    return render_template('map.html')

@app.route('/denied')
def denied():
    if session.get('user_logged_in'):
        return redirect(url_for('home'))
    return render_template( '403.html')

@app.errorhandler(404)
def main404( error = None ):
    if not session.get('user_logged_in'):
        return redirect(url_for('denied'))
    return render_template('404.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if session.get('user_logged_in'):
        return redirect(url_for('home'))
    if request.method == "POST":
        if request.form['username'] in users and users[request.form['username']]['PASSWORD'] == request.form['password']:
            session['user_logged_in'] = True
            session['user_name']      = request.form['username']
            session['user_rank']      = users[request.form['username']]['RANK']
        else:
            return render_template( 'login.html', return_msg={'msg':u"Erreur, Nous n'avons pas réussi à vous identifier.", 'type':u'danger'})
    else:
        return render_template( 'login.html')
    return redirect(url_for('home'))

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))

@app.route('/')
def home():
    if not session.get('user_logged_in'):
        return redirect(url_for('denied'))
    fig = px.histogram(dataCollecteurs, x="typeTri", color="Ville", color_discrete_map=dictVillesCouleurs, width=700, title="Nombre de sites de collecteurs par type de tri et par ville")
    fig.update_xaxes(categoryorder="total descending")
    fig.update_layout(barmode='group', xaxis_title="Type de tri", yaxis_title="Nombre")
    graphJSON = dumps(fig, cls=PlotlyJSONEncoder)
    fig = px.sunburst(dataCollecteurs, path=["Ville", "typeTri"], color="Ville", color_discrete_map=dictVillesCouleurs, width=500, title="Répartition des sites de collecteurs par ville et par type de tri")
    graphJSON2 = dumps(fig, cls=PlotlyJSONEncoder)
    data20MoisPoids = dataMoisAnneePoids[dataMoisAnneePoids["Année"] == 2020]
    fig = px.line(data20MoisPoids, x="Mois", y="Poids", color='Ville', color_discrete_map=dictVillesCouleurs, width=900, title="Poids collecté de verre par mois et par ville en 2020")
    fig.update_layout(yaxis_title="Poids (en kg)")
    graphJSON3 = dumps(fig, cls=PlotlyJSONEncoder)

    return render_template('index.html', plot=graphJSON, plot2=graphJSON2, plot3=graphJSON3)

@app.route('/stats/<ville>')
def statistics(ville):
    if not (session.get('user_logged_in') and session.get('user_rank') == 'admin'):
        return redirect(url_for('denied'))
    if ville in dictVillesCouleurs.keys():
        dataVille20 = data20[data20["Ville"] == ville]
        fig = px.histogram(dataVille20, x="Lieu de Collecte", y="Poids", color="Lieu de Collecte", color_discrete_sequence=px.colors.qualitative.Pastel, width=1200, height=600, title="Poids collecté de verre par adresse à " + ville + " en 2020")
        fig.update_xaxes(tickangle=270, tickfont=dict(size=10))
        fig.update_layout(yaxis_title="Poids (en kg)")
        graphJSON = dumps(fig, cls=PlotlyJSONEncoder)
        dataVilleMois = dataMoisAnnee[dataMoisAnnee["Ville"] == ville]
        fig = px.line(dataVilleMois, x="Mois", y="Nombre", color='Année', width=900, title="Nombre de collectes de verre à " + ville + " par mois et par année")
        fig.update_layout(yaxis_rangemode="tozero")
        graphJSON2 = dumps(fig, cls=PlotlyJSONEncoder)
        return render_template('stats.html', ville=ville, plot=graphJSON, plot2=graphJSON2)
    else: 
        return render_template('404.html')

@app.route('/', defaults={'path': ''})
@app.route('/<path:path>')
def catch_all_404(path):
    return render_template('404.html')

if currentEnvironnement == "LOCALHOST":
    app.run(debug=True, host=capp["LOCALHOST"]['server_host'], port=capp["LOCALHOST"]['server_port'])
else:
    if __name__ == '__main__':
        app.run()
