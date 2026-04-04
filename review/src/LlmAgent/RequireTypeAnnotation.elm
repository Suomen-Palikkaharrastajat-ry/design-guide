module LlmAgent.RequireTypeAnnotation exposing (rule)

{-| Requires every top-level function and value to have a type annotation.

Type annotations are the primary contract between a function's author and its
callers. LLM coding agents use them to understand what a function accepts and
returns without having to trace through the implementation.

-}

import Elm.Syntax.Declaration as Declaration exposing (Declaration)
import Elm.Syntax.Node as Node exposing (Node)
import Review.Rule as Rule exposing (Rule)


{-| Reports top-level functions and values without a type annotation. -}
rule : Rule
rule =
    Rule.newModuleRuleSchema "LlmAgent.RequireTypeAnnotation" ()
        |> Rule.withDeclarationEnterVisitor declarationVisitor
        |> Rule.fromModuleRuleSchema


declarationVisitor : Node Declaration -> () -> ( List (Rule.Error {}), () )
declarationVisitor node () =
    case Node.value node of
        Declaration.FunctionDeclaration function ->
            case function.signature of
                Just _ ->
                    ( [], () )

                Nothing ->
                    let
                        functionName =
                            function.declaration
                                |> Node.value
                                |> .name
                                |> Node.value
                    in
                    ( [ Rule.error
                            { message = "Top-level declaration `" ++ functionName ++ "` is missing a type annotation"
                            , details =
                                [ "Type annotations make the contract of a function explicit and immediately visible without reading the implementation."
                                , "LLM coding agents use type annotations to understand what a function accepts and returns, reducing the risk of incorrect usage."
                                , "Add a type annotation above this declaration."
                                ]
                            }
                            (Node.range node)
                      ]
                    , ()
                    )

        _ ->
            ( [], () )
