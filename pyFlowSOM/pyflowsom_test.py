from pathlib import Path

import numpy as np
import pandas as pd
import pytest

from . import map_data_to_nodes, som

THIS_DIR = Path(__file__).parent
EX_DIR = THIS_DIR.parent / 'examples'


@pytest.fixture()
def example_som_input_df():
    """Each row is a pixel, each column is a marker

    Returns the df with marker names
    """
    return pd.read_csv(EX_DIR / 'example_som_input.csv')


@pytest.fixture()
def example_som_input(example_som_input_df):
    """Each row is a pixel, each column is a marker
    original image could be: 66 x 631 = 41,646
    """
    arr = example_som_input_df.to_numpy(copy=True)
    assert arr.shape == (41646, 16)
    assert arr.dtype == np.float64
    return arr


@pytest.fixture()
def example_node_output_df():
    """Each row is a node, each column is a marker

    Returns the df with marker names
    """
    return pd.read_csv(EX_DIR / 'example_node_output.csv')


@pytest.fixture()
def example_node_output(example_node_output_df):
    """Each row is a node, each column is a marker"""
    arr = example_node_output_df.to_numpy(copy=True)
    assert arr.shape == (100, 16)
    assert arr.dtype == np.float64
    return arr


@pytest.fixture()
def example_cluster_groundtruth_df():
    return pd.read_csv(EX_DIR / 'example_clusters_output.csv')


@pytest.fixture()
def example_cluster_groundtruth(example_cluster_groundtruth_df):
    """Each row is a cluster, each column is a marker"""
    arr = example_cluster_groundtruth_df['cluster'].to_numpy(copy=True)
    assert arr.shape == (41646,)
    assert arr.dtype == np.int
    return arr


def test_map_data_to_nodes(example_som_input, example_node_output, example_cluster_groundtruth):
    nodes, dists = map_data_to_nodes(example_node_output, example_som_input)

    assert nodes.shape == (41646,)
    assert dists.shape == (41646,)
    np.testing.assert_array_equal(example_cluster_groundtruth, nodes)


def test_map_data_to_nodes_handles_c_continuous_arrays(
        example_som_input,
        example_node_output,
        example_cluster_groundtruth):

    cluster, dists = map_data_to_nodes(example_node_output, example_som_input)

    assert cluster.shape == (41646,)
    assert dists.shape == (41646,)
    np.testing.assert_array_equal(example_cluster_groundtruth, cluster)


def test_som_and_check_node_output(example_som_input, example_node_output):
    node_output = som(example_som_input, xdim=10, ydim=10, rlen=10, deterministic=True)

    assert node_output.shape == (100, 16)
    assert example_node_output.shape == (100, 16)
    np.testing.assert_allclose(node_output, example_node_output)


def test_som_and_map_end_to_end_and_check_clusters(example_som_input, example_cluster_groundtruth):
    node_output = som(example_som_input, xdim=10, ydim=10, rlen=10, deterministic=True)
    clusters, dists = map_data_to_nodes(node_output, example_som_input)

    assert example_cluster_groundtruth.shape == clusters.shape
    np.testing.assert_array_equal(example_cluster_groundtruth, clusters)


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


@pytest.mark.skip("This is a manual test for visual inspection")
def test_debug_out_heatmap_comparison(
        example_som_input,
        example_som_input_df,
        example_cluster_groundtruth):

    # Run the SOM
    node_output = som(example_som_input, xdim=10, ydim=10, rlen=10, deterministic=True)
    end_to_end_cluster, dists = map_data_to_nodes(node_output, example_som_input)

    example_som_input_df['cluster'] = end_to_end_cluster
    save_heatmap(example_som_input_df, 'end_to_end')

    example_som_input_df['cluster'] = example_cluster_groundtruth
    save_heatmap(example_som_input_df, 'ground_truth')
