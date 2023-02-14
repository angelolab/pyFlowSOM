[![Build Status](https://travis-ci.com/angelolab/pyFlowSOM.svg?branch=master)](https://travis-ci.com/angelolab/pyFlowSOM)
[![Coverage Status](https://coveralls.io/repos/github/angelolab/pyFlowSOM/badge.svg?branch=main)](https://coveralls.io/github/angelolab/pyFlowSOM?branch=main)

# pyFlowSOM

Python runner for the [FlowSOM](https://github.com/SofieVG/FlowSOM) library.

Basic usage:

    import pandas as pd
    from pyFlowSOM import map_data_to_nodes, som

    df = pd.read_csv('examples/example_som_input.csv')
    example_som_input_arr = df.to_numpy()
    node_output = som(example_som_input_arr, xdim=10, ydim=10, rlen=10)
    clusters, dists = map_data_to_nodes(node_output, example_som_input_arr)

To put the data back into dataframes:

    eno = pd.DataFrame(data=node_output, columns=df.columns)
    eco = pd.DataFrame(data=clusters, columns=["cluster"])

To export to csv:

    eno.to_csv('examples/example_node_output.csv', index=False)
    eco.to_csv('examples/example_clusters_output.csv', index=False)

To plot the output as a heatmap:

    import seaborn as sns

    # Append results to the input data
    example_som_input_df['cluster'] = clusters

    # Find mean of each cluster
    df_mean = example_som_input_df.groupby(['cluster']).mean()

    # Make heatmap
    sns_plot = sns.clustermap(df_mean, z_score=1, cmap="vlag", center=0, yticklabels=True)
    sns_plot.figure.savefig(f"example_cluster_heatmap.png")


# Develop

Continually build and test while developing. This will automatically create your virtual env

    ./build.sh && ./test.sh

The C code (`pyFlowSOM/flosom.c`) is wrapped using Cython (`pyFlowSOM/cyFlowSOM.c`).

Tests do an approximate exact comparison to cluster id groundtruth and an approximate comparison to node values only because of floating point differences. All randomness has stubbed out in in the y2kbugger/FlowSOM fork and works in tandem to the `deterministic` flag to the `som` function.

To regenerate test data, which may be required if you changed any sources of randomness:

    python -m pyFlowSOM.generate_test_outputs

To generate heatmaps for manual comparison:

    python -m pyFlowSOM.generate_test_heatmaps

To bump the version and deploy to pypi:

Just add the tag which matches the version you want to deploy:

    git tag v0.1.14
    git push --tags
