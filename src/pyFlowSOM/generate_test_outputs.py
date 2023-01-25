from pathlib import Path

import pandas as pd

from . import map_data_to_nodes, som

THIS_DIR = Path(__file__).parent
EX_DIR = THIS_DIR.parent / 'examples'

if __name__ == "__main__":
    df = pd.read_csv(EX_DIR / 'example_som_input.csv')
    example_som_input_arr = df.to_numpy()
    node_output = som(example_som_input_arr, xdim=10, ydim=10, rlen=10)
    clusters, dists = map_data_to_nodes(node_output, example_som_input_arr)
    eno = pd.DataFrame(data=node_output, columns=df.columns)
    eco = pd.DataFrame(data=clusters, columns=["cluster"])
    eno.to_csv(EX_DIR / 'example_node_output.csv', index=False)
    eco.to_csv(EX_DIR / 'example_clusters_output.csv', index=False)