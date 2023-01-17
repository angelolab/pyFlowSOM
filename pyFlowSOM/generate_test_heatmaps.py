from pathlib import Path

import numpy as np
import pandas as pd

from pyFlowSOM import map_data_to_nodes, som

THIS_DIR = Path(__file__).parent
EX_DIR = THIS_DIR.parent / 'examples'


import pandas as pd

from . import map_data_to_nodes, som


def save_heatmap(cluster_labeled_input_data, output_name):
    """Save a heatmap of the cluster assignments
    cluster: 1D array of cluster assignments
    data: 2D array of data
    output_name: name of the output file
    """
    import seaborn as sns

    # Find mean of each cluster
    df_mean = cluster_labeled_input_data.groupby(['cluster']).mean()

    # Make heatmap
    sns_plot = sns.clustermap(df_mean, z_score=1, cmap="vlag", center=0, yticklabels=True)
    sns_plot.figure.savefig(EX_DIR / f"{output_name}.png")


if __name__ == "__main__":
    example_som_input_df = pd.read_csv(EX_DIR / 'example_som_input.csv', dtype=np.dtype("d"))
    example_som_input_arr = example_som_input_df.to_numpy(copy=True)

    example_cluster_groundtruth_df = pd.read_csv(
            EX_DIR / 'example_clusters_output.csv',
            usecols=["cluster"], dtype=np.dtype("i"))
    example_cluster_groundtruth_arr = example_cluster_groundtruth_df['cluster'].to_numpy(copy=True)

    node_output = som(example_som_input_arr, xdim=10, ydim=10, rlen=10)
    end_to_end_cluster, dists = map_data_to_nodes(node_output, example_som_input_arr)

    example_som_input_df['cluster'] = end_to_end_cluster
    save_heatmap(example_som_input_df, 'end_to_end')

    example_som_input_df['cluster'] = example_cluster_groundtruth_arr
    save_heatmap(example_som_input_df, 'ground_truth')


