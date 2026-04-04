module ReviewConfig exposing (config)

{-| elm-review configuration for the design tokens Elm package.

These rules enforce conventions that keep generated code easy for LLM coding
agents to read, understand, and modify correctly:

  - **RequireModuleDoc** — module docs give agents orientation without reading all code
  - **RequireTypeAnnotation** — type signatures are the contract; agents rely on them
  - **NoExposingEverything** — explicit export lists reveal the public API at a glance

-}

import LlmAgent.NoExposingEverything
import LlmAgent.RequireModuleDoc
import LlmAgent.RequireTypeAnnotation
import Review.Rule as Rule exposing (Rule)


config : List Rule
config =
    [ LlmAgent.RequireModuleDoc.rule
    , LlmAgent.RequireTypeAnnotation.rule
    , LlmAgent.NoExposingEverything.rule
    ]
