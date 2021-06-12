#!/bin/bash

FILE=../resources/training.csv
./execute.sh es.dmr.uimp.clustering.KMeansClusterInvoices ${FILE} ./clustering ./threshold kMeans &
./execute.sh es.dmr.uimp.clustering.KMeansClusterInvoices ${FILE} ./clustering_bisect ./threshold_bisect BisKMeans &