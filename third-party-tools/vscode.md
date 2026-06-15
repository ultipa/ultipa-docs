# Visual Studio Code

## Overview

**Visual Studio Code** (VS Code) is a versatile development environment that simplifies coding with Ultipa drivers and APIs. You can bring the Ultipa VS Code Extensions to your workflow - to write, validate, and execute ISO GQL queries directly within your coding workspace.

You can download VS Code from <a target="_blank" href="https://code.visualstudio.com/download">here</a>.

## Installation

Just search "ISO GQL" in the Extensions Marketplace and grab these two:

- **ISO GQL Language Support:** Adds `.gql` file support and GQL syntax highlighting and hints.
- **Ultipa GQL Runner:** Connects to Ultipa graph databases and runs queries.

<center><img width="50%" src="https://img.ultipa.cn/img/2025-10-08-18-16-53-extensions.jpg"></center>

## Add Connections

Create a `.gql` file in VS code and click the gear icon to generate a `ultipa.config.yml` file in your project:

<center><img src="https://img.ultipa.cn/img/2025-10-08-18-17-48-create-gql-file.gif"></center>

In the config file, add your database connections under the connections section, like so:

```yml
defaultConnection: local
connections:
  - name: cloud
    host: 10.xxx.xxx.xxx:xxxx
    username: root
    defaultGraph: miniCircle
    timeout: 30
  - name: local
    host: localhost:60061
    username: admin
    defaultGraph: default
    timeout: 30
```
 
You can set whichever one you want as the `defaultConnection`. The config file also lets you tweak visualization options (node size, edge width, labels, fonts, etc.), but don't stress-defaults work fine to start.

## Run GQL Queries

Write queries in your `.gql` file and hit **Run**. You will be prompted to pick a connection and enter the database user password. Your queries will be executed on the specified `defaultGraph`.

<center><img src="https://img.ultipa.cn/img/2025-10-08-18-19-20-1-pq4FFDCVx7k6yJRnynlOAQ.gif"></center>

You'll also see your active connection in the bottom status bar, where you can quickly disconnect or switch to another one.

## Multi-Query Support

You can run multiple queries at once by separating them with semicolon `;`. Each query result opens its own tab.

<center><img src="https://img.ultipa.cn/img/2025-10-08-18-20-30-multi-query.gif"></center>

## Visualization

The extension gives you two ways to look at your results: **Graph view** and **List view**. In Graph view, you can drag nodes and edges around the canvas, and if you right-click on any of them, an info box pops up showing all their properties.
