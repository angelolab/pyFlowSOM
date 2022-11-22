from pathlib import Path

import numpy as np
import pandas as pd
import pytest

from . import map_data_to_codes, som

THIS_DIR = Path(__file__).parent


@pytest.fixture()
def example_som_input():
    """Each row is a pixel, each column is a marker
    original image could be: 66 x 631 = 41,646
    """
    df = pd.read_csv(THIS_DIR.parent / 'examples' / 'example_som_input.csv')
    arr = df.to_numpy()
    assert arr.shape == (41646, 16)
    assert arr.dtype == np.float64
    return arr


@pytest.fixture()
def example_som_input_df():
    """Each row is a pixel, each column is a marker

    Returns the df with marker names
    """
    return pd.read_csv(THIS_DIR.parent / 'examples' / 'example_som_input.csv')


@pytest.fixture()
def example_node_output():
    """Each row is a node, each column is a marker
    """
    df = pd.read_csv(THIS_DIR.parent / 'examples' / 'example_node_output.csv')
    arr = df.to_numpy()
    assert arr.shape == (100, 16)
    assert arr.dtype == np.float64
    return arr


@pytest.fixture()
def example_cluster_groundtruth():
    """Each row is a cluster, each column is a marker
    """
    df = pd.read_csv(THIS_DIR.parent / 'examples' / 'example_clusters_output.csv')
    arr = df['cluster'].to_numpy()
    assert arr.shape == (41646,)
    assert arr.dtype == np.int
    return arr


def test_map_data_to_codes(example_som_input, example_node_output, example_cluster_groundtruth):
    codes, dists = map_data_to_codes(example_node_output, example_som_input)

    assert codes.shape == (41646,)
    assert dists.shape == (41646,)
    assert np.array_equal(example_cluster_groundtruth, codes)


def test_map_data_to_codes_handles_c_continuous_arrays(
        example_som_input,
        example_node_output,
        example_cluster_groundtruth):

    cluster, dists = map_data_to_codes(example_node_output, example_som_input)

    assert cluster.shape == (41646,)
    assert dists.shape == (41646,)
    assert np.array_equal(example_cluster_groundtruth, cluster)


def test_som_and_check_node_output(example_som_input, example_node_output):
    node_output = som(example_som_input, xdim=10, ydim=10, rlen=10)

    assert node_output.shape == (100, 16)
    assert example_node_output.shape == (100, 16)
    assert np.testing.assert_array_almost_equal(node_output, example_node_output, decimal=3)


def test_som_and_map_end_to_end_and_check_clusters(example_som_input, example_cluster_groundtruth):
    node_output = som(example_som_input, xdim=10, ydim=10, rlen=10)
    clusters, dists = map_data_to_codes(node_output, example_som_input)

    assert example_cluster_groundtruth.shape == clusters.shape
    assert np.array_equal(example_cluster_groundtruth, clusters)


def test_som_and_map_end_to_end_and_save_results(example_som_input, example_cluster_groundtruth):
    node_output = som(example_som_input, xdim=10, ydim=10, rlen=10)
    clusters, dists = map_data_to_codes(node_output, example_som_input)

    pd.DataFrame(clusters, columns=("cluster",)) \
        .to_csv('clusters_from_python.csv', index=False)
    pd.DataFrame(example_cluster_groundtruth, columns=("cluster",)) \
        .to_csv('clusters_from_example.csv', index=False)


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
    sns_plot.figure.savefig(f"{output_name}.png")


def test_debug_out_heatmap_comparison(
        example_som_input,
        example_som_input_df,
        example_cluster_groundtruth):

    # Run the SOM
    node_output = som(example_som_input, xdim=10, ydim=10, rlen=10)
    end_to_end_cluster, dists = map_data_to_codes(node_output, example_som_input)

    example_som_input_df['cluster'] = end_to_end_cluster
    save_heatmap(example_som_input_df, 'end_to_end')

    example_som_input_df['cluster'] = example_cluster_groundtruth
    save_heatmap(example_som_input_df, 'ground_truth')
