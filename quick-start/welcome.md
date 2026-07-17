# Welcome to GQLDB

GQLDB is Ultipa's high-performance graph database. This Quick Start walks you from an empty machine to a working graph you can query, analyze, and explore with an AI agent, in about 15 minutes.

By the end of this guide you will have:

1. A running GQLDB instance and a client connected to it.
2. A graph loaded with real data.
3. A feel for querying with GQL, the ISO-standard graph query language.
4. A graph algorithm running over your data.
5. An AI agent wired to your database through the Ultipa MCP server.

## What You Will Build

Every chapter uses the same small social graph of users who follow one another.

<center><img src="./images/example-graph.drawio.svg"></center>

- **Nodes** are `User` entities, each with properties `name`, `age`, and `city`.
- **Edges** are `Follows` relationships, each recording the year the follow started in a `since` property.

This is enough to demonstrate loading, pattern matching, path finding, and a centrality algorithm, while staying small enough to read the whole result set.

## How to Use This Guide

The chapters are meant to be read in order:

1. <a href="/docs/quick-start/install-and-connect" target="_blank">Install & Connect</a>: get a running instance and connect to it.
2. <a href="/docs/quick-start/load-data" target="_blank">Load Your Data</a>: create a graph and put data in it.
3. <a href="/docs/quick-start/query-data" target="_blank">Query Your Data</a>: retrieve and traverse with GQL.
4. <a href="/docs/quick-start/run-algorithms" target="_blank">Run Graph Algorithms</a>: score and rank your nodes.
5. <a href="/docs/quick-start/work-with-ai" target="_blank">Work with an AI Agent</a>: operate the database in natural language.
6. <a href="/docs/quick-start/next-steps" target="_blank">Next Steps</a>: where to go deeper.

Ready? Head to <a href="/docs/quick-start/install-and-connect" target="_blank">Install & Connect</a>.
