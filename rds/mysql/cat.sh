#!/bin/bash

# the order of schema migration
cat prime.db.sql apigw.table.sql hits.table.sql apigw.ait.sql technologies.table.sql hits.ait.sql charts.view.sql
