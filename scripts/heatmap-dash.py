from pathlib import Path
import pandas as pd
import numpy as np
import dash
from dash import dcc, html, Input, Output
import plotly.express as px
ROOT = Path().cwd()
DATA_INITIAL = Path("../data_initial").resolve()
DATA = Path("../data").resolve()
FANTOM = DATA / "fantom_cat"
FANTOM_INITIAL = DATA_INITIAL / "fantom_cat"
PREPROCESSING = Path("../preprocessing")

MATRICES = PREPROCESSING / "matrices"
IPS_MATRICES = MATRICES / "ips_matrices"
FIBRO_MATRICES = MATRICES / "fibro_matrices"

INFO = PREPROCESSING / "info"
IPS_INFO = INFO / "ips_info"
FIBRO_INFO = INFO / "fibro_info"

FISHER = PREPROCESSING / "fisher_test"
IPS_FISHER = FISHER / "ips_fisher_exact_test"
FIBRO_FISHER = FISHER / "fibro_fisher_exact_test"

RESULTS = Path("../results")
FISHER_RESULTS = RESULTS / "fisher_test"

IMAGES = RESULTS / "images"
# Пример загрузки данных
# Замените этот блок на загрузку ваших данных
fisher_results_filt_by_exp = {}
for exp in ["fibro", "ips"]:
    to_file = FISHER_RESULTS / f"{exp}-fisher-significant.tsv"
    fisher_results_filt = pd.read_csv(to_file, sep="\t")
    fisher_results_filt["lnc_aso"] = fisher_results_filt["lnc"] + "_" + fisher_results_filt["aso"]
    fisher_results_filt_by_exp[exp] = fisher_results_filt   

df_for_heatmap = pd.pivot_table(
    data=fisher_results_filt_by_exp["ips"][["hm", "lnc_aso", "er", "ea", "wa", "wr"]], 
    index=["lnc_aso"], 
    columns="hm"
).sort_index(axis=1, level=1)

# Создаем Dash приложение
app = dash.Dash(__name__)

app.layout = html.Div([
    html.H1("Тепловая карта на основе данных"),
    
    # Dropdown для выбора меток или колонок
    html.Label("Выберите маркер:"),
    dcc.Dropdown(
        id="marker-dropdown",
        options=[{"label": col, "value": col} for col in df_for_heatmap.columns],
        multi=True,
        placeholder="Выберите маркеры"
    ),
    
    # Heatmap
    dcc.Graph(id="heatmap")
])

@app.callback(
    Output("heatmap", "figure"),
    Input("marker-dropdown", "value")
)
def update_heatmap(selected_markers):
    if not selected_markers:
        selected_markers = df_for_heatmap.columns

    filtered_df = df_for_heatmap[selected_markers]

    fig = px.imshow(
        filtered_df,
        labels={"x": "Маркер", "y": "lnc_aso", "color": "Значение"},
        x=filtered_df.columns,
        y=filtered_df.index,
        color_continuous_scale="Viridis"
    )

    # Добавление информации при наведении на ячейку
    fig.update_traces(
        hovertemplate="<b>%{y}</b><br><i>%{x}</i>: %{z}<br>"
    )

    return fig

if __name__ == "__main__":
    app.run_server(debug=True)
