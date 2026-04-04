module LlmAgent.NoExposingEverything exposing (rule)

{-| Forbids wildcard module exports.

Explicit export lists serve as a module's public API contract. When an LLM
coding agent reads the module declaration, an explicit list immediately
communicates what is safe to use from the outside.

-}

import Elm.Syntax.Exposing as Exposing
import Elm.Syntax.Module as Module exposing (Module)
import Elm.Syntax.Node as Node exposing (Node)
import Review.Rule as Rule exposing (Rule)


{-| Reports modules that use exposing (..). -}
rule : Rule
rule =
    Rule.newModuleRuleSchema "LlmAgent.NoExposingEverything" ()
        |> Rule.withModuleDefinitionVisitor moduleDefinitionVisitor
        |> Rule.fromModuleRuleSchema


moduleDefinitionVisitor : Node Module -> () -> ( List (Rule.Error {}), () )
moduleDefinitionVisitor node () =
    let
        exposingList =
            case Node.value node of
                Module.NormalModule data ->
                    Node.value data.exposingList

                Module.PortModule data ->
                    Node.value data.exposingList

                Module.EffectModule data ->
                    Node.value data.exposingList
    in
    case exposingList of
        Exposing.All range ->
            ( [ Rule.error
                    { message = "Avoid `exposing (..)` — list exports explicitly"
                    , details =
                        [ "Wildcard exports hide the public API of a module. LLM coding agents cannot tell which declarations are internal helpers and which are intended for external use."
                        , "Replace `exposing (..)` with an explicit list, e.g. `exposing (version, legoBlack, legoWhite)`."
                        ]
                    }
                    range
              ]
            , ()
            )

        Exposing.Explicit _ ->
            ( [], () )
