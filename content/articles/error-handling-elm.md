---
{
  "type": "blog",
  "author": "Rupert Smith",
  "title": "Error Handling in Elm",
  "description": "About an authentication API I designed for Elm.",
  "image": "images/article-covers/train-crash.jpg",
  "published": "2020-01-21"
}
---

### When Things Go Wrong

Elm famously does not have runtime exceptions, most other programming languages do. Instead, Elm has the `Result` or `Maybe` types that are used to make all errors expected, and enable its compiler to force the programmer to deal with all of them.

Exceptions can be a convenient way of expressing errors - any runtime exception that is not caught and dealt with will fall through to a default top-level handler. This can ensure that an error is always logged in some way, and also provide a stack trace back to its source. Elm does not have exceptions, so it is worth looking at alternative patterns for error handling in Elm.

### Who Cares?

There is no point in reporting an error if no-one cares. Errors reported should therefore give some though towards who is the audience for the error.

A pilot may get an error light on the control panel of a passenger aircraft. There is likely to get a resolution that the pilot can carry out, such as switching over fuel tanks, that does not need to be reported to the passengers. The destination airport may be closed due to some unforeseen event, and this time the pilot will inform the passengers about the diversion. Different kinds of errors, different audiences.

In computer software, I like to identify 3 different audiences; the code itself; the developer or devops team; and the end-user.

### Representing Errors in Elm

Result

About Maybe

### What if there are multiple errors?

ResultME and associated functions.

Package for this.

### Passing up unhandled errors.

This only applies to errors for the devops team, not for end-user or code recovery errors. When we encounter an error that stops our code from working, such as a response from an API that does not 'decode', we should ensure this error is logged for the devops to look at. Note there may still be a secondary need to inform the end-user about such errors too, perhaps a notice saying that part of the back-end is not available and to expect degraded service as a result. The primary need is to let the devops team know there is a problem so they can get it fixed as soon as possible.

In languages with exceptions, which is most languages you will have encountered that are not Elm, there is an in-built mechanism to push errors up the call-stack until they are 'caught' and dealt with. This can be nice, errors are never missed, you can write a default top-level handler that will ensure that all errors are also always logged, and you can write this default handler code only once and use it everywhere which ensures that you never forget to hook it up when it is needed.

Elm does not have a mechanism to 'throw' errors up the call-stack. Instead the error is expressed in the return type of a function. To pass the error on up the stack without dealing with it, it is most convenient to do so as a `Result String a`.

If an error is not being dealt with, it can be converted to a `String` for logging. There is no need to keep it in a custom type format. All custom error types should therefore have a 'toString' function associated with them. Putting all errors into 'String' format, allows the code to report errors of any originating type easily whilst still type checking correctly; it provides a common format to gather all error types into.

### Reporting Errors

Reporting is IO and all IO in Elm is done through side-effects as `Cmd`s. We cannot use `Debug.log` in optimized Elm code and we should not want to for the purpose of logging errors in production either.

A web application is going to need to call-home to report errors, either through some API or through a Javascript library provided by a logging framework. Any `update` function in an Elm application can be responsible for reporting its own errors. I would like to look at the approach of doing this in only one place in an Elm application, which is in the top-most `update` function. This has the benefits described above of only needing to be written once; never missing an error; and never getting forgotten to be added into the code.

To illustrate what this might look like in Elm code:

```elm
someFunThatMayError : Int -> Result SomeError Thing

type SomeError
    = InputTooSmall Int Int

someErrorToString : SomeError -> String
someErrorToString val =
    case InputTooSmall of
      InputTooSmall actual atLeast ->
          "Input too small, input is " ++ actual ++ " but must be at least " ++ atLeast

topLevelErrorHandler : String -> ()

update : Model -> Msg -> (Model, Cmd Msg)
update model msg =
    case msg of
        DoSomeFun ->
          case doSomeFunUpdate model.input of
            Ok (model, cmds) -> (model, cmds)
            Err err -> topLevelErrorHandler err model


doSomeFunUpdate : Int -> Result String (Model, Cmd Msg)
doSomeFunUpdate val =
  someFunThatMayError val
      |> Result.map (\val -> ({ model | output = val }, Cmd.none))
      |> Result.mapError (\err -> someErrorToString err)



```
