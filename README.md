# pyFlowSOM

<div align="center">

| | | 
| ---        |    ---  |
| CI / CD | [![CI](https://github.com/angelolab/pyFlowSOM/actions/workflows/ci.yml/badge.svg)](https://github.com/angelolab/pyFlowSOM/actions/workflows/ci.yml) [![Coverage Status](https://coveralls.io/repos/github/angelolab/pyFlowSOM/badge.svg?branch=main)](https://coveralls.io/github/angelolab/pyFlowSOM?branch=main) |
| Package | [![PyPI - Version](https://img.shields.io/pypi/v/pyFlowSOM.svg?logo=pypi&label=PyPI&logoColor=gold)](https://pypi.org/project/pyFlowSOM/) [![PyPI - Downloads](https://img.shields.io/pypi/dm/pyFlowSOM.svg?color=blue&label=Downloads&logo=pypi&logoColor=gold)](https://pypi.org/project/pyFlowSOM/) [![PyPI - Python Version](https://img.shields.io/pypi/pyversions/pyFlowSOM.svg?logo=python&label=Python&logoColor=gold)](https://pypi.org/project/pyFlowSOM/) |
|Meta | [![PyPI - License](https://img.shields.io/pypi/l/pyFlowSOM?color=9400d3)](LICENSE) |

</div>


Python runner for the [FlowSOM](https://github.com/SofieVG/FlowSOM) library.

Basic usage:

```python
import numpy as np
import pandas as pd
from pyFlowSOM import map_data_to_nodes, som

# generate example input data, rows are observations (e.g. cells), columns are features (e.g. proteins)
df = pd.DataFrame(np.random.rand(500, 16))

# alternatively, specify path to your own input data
df = pd.read_csv('path/to/som/input.csv')

example_som_input_arr = df.to_numpy()

# train the SOM
node_output = som(example_som_input_arr, xdim=10, ydim=10, rlen=10)

# use trained SOM to assign clusters to each observation in your data
clusters, dists = map_data_to_nodes(node_output, example_som_input_arr)
```

To put the data back into dataframes:

```python
eno = pd.DataFrame(data=node_output, columns=df.columns)
eco = pd.DataFrame(data=clusters, columns=["cluster"])
```
To export to csv:

```python
eno.to_csv('examples/example_node_output.csv', index=False)
eco.to_csv('examples/example_clusters_output.csv', index=False)
```

To plot the output as a heatmap:

```python
import seaborn as sns

# Append results to the input data
df['cluster'] = clusters

# Find mean of each cluster
df_mean = df.groupby(['cluster']).mean()

# Make heatmap
sns_plot = sns.clustermap(df_mean, z_score=1, cmap="vlag", center=0, yticklabels=True)
sns_plot.figure.savefig(f"example_cluster_heatmap.png")
```

# Develop

The C code (`pyFlowSOM/flowsom.c`) is wrapped using Cython (`pyFlowSOM/cyFlowSOM.cyx`).

Tests do an exact comparison to cluster id ground truth and an approximate comparison to node values only because of floating point differences. Randomness works in tandem to the `seed` flag to the `som` function.

To run the tests, use the following command:

```shell
pytest
```

