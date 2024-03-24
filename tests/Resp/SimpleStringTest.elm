module Resp.SimpleStringTest exposing (testSuite)

import Expect
import Parser.Advanced as Parser
import Resp
import Test


testSuite : Test.Test
testSuite =
    Test.describe "RESP Simple String Parser"
        [ Test.test "parses non-empty simple strings correctly" <|
            \_ ->
                "+OK\u{000D}\n"
                    |> Resp.decode Resp.SimpleStringDecoder
                    |> Result.map Resp.toString
                    |> Expect.equal (Ok "OK")
        , Test.test "parses empty simple strings correctly" <|
            \_ ->
                "+\u{000D}\n"
                    |> Resp.decode Resp.SimpleStringDecoder
                    |> Result.map Resp.toString
                    |> Expect.equal (Ok "")
        , Test.test "parses strings containing '+' correctly" <|
            \_ ->
                "++O+K+\u{000D}\n"
                    |> Resp.decode Resp.SimpleStringDecoder
                    |> Result.map Resp.toString
                    |> Expect.equal (Ok "+O+K+")
        , Test.test "fails on strings without leading '+'" <|
            \_ ->
                "OK\u{000D}\n"
                    |> Resp.decode Resp.SimpleStringDecoder
                    |> Result.mapError (List.map .problem)
                    |> Expect.equal (Err [ Resp.ExpectingPlus ])
        , Test.test "fails on strings without trailing '\\r\\n'" <|
            \_ ->
                "+OK"
                    |> Resp.decode Resp.SimpleStringDecoder
                    |> Result.mapError (List.map .problem)
                    |> Expect.equal (Err [ Resp.ExpectingCrlf ])
        , Test.test "fails on strings ending with '\\n' instead of '\\r\\n'" <|
            \_ ->
                "+OK\n"
                    |> Resp.decode Resp.SimpleStringDecoder
                    |> Result.mapError (List.map .problem)
                    |> Expect.equal (Err [ Resp.ExpectingCrlf ])
        ]