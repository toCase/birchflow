---
title: Життевий цикл Контракту
author: Ev Shevchenko
date: "25.02.2025"
---

``` mermaid
graph LR
    A@{shape: stadium, label: Створення} --> B[Активний];
    subgraph Життевий цикл
    B --> C[Завершений];
    C --> D[Архивний];
    B --> E[Скасований];
    end
    E --> F@{shape: stadium, label: Видалення};

```