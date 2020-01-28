---
{
  "type": "blog",
  "author": "Rupert Smith",
  "title": "Authenticating in Elm",
  "description": "About an authentication API I designed for Elm.",
  "image": "/images/article-covers/bank-vault.jpg",
  "published": "2020-01-21"
}
---

I designed an API to connect Elm apps with back-end authentication. You can find it on the Elm package site as [the-sett/elm-auth](https://package.elm-lang.org/packages/the-sett/elm-auth/latest/).

You can find an implementation of this API, against Amazon Cognito, also on the Elm package site as
[the-sett/elm-auth-aws](https://package.elm-lang.org/packages/the-sett/elm-auth-aws/latest/)

### The Code to the Vault

Authentication can seem like a mysterious process, convoluted and leading to code that is hard to understand, supported by cryptic documentation with its own technical jargon. As application developers we are usually quite clear on what we need from it and where it will sit in our applications.

*There needs to be a log in box into which the user enters their username and password in order to gain access to some protected resource.*

The act of logging in is typically performed against an authentication server. An authentication server is a gateway to the protected resource and the gatekeepers are its authentication functions that decide whether a user is allowed in or not. In Elm IO operations are modelled as *side-effects*.

Once logged in, an authentication back-end may respond with some information about the user. At a minimum we might expect some *unique identifier* for the user and possibly also some indiciation of what *access rights* that user has.

The protected resource is the part of a system that is most interested in the access rights of your users. It must evaluate them to determine whether it should give access or not. A user interface running in a browser sits outside the firewall and cannot really be protected or fully trusted, since any attacker has access to its javascript code and can modify it and see all of its internal workings. That said, a user interface is usually also interested in knowing about the users access rights, in order to be helpful and only show the user actions that they will be able to succesfully perform given the access rights that they hold.

In addition to *logging in* we might also want our users to be able to *log out* explicitly. This does not always need to be done as typically the proof of authentication will expire on a timer anyway. For applications with greater security concerns such as online banking, the ability to log out can help give users more peace of mind.

The application might try to access some protected resource and fail because the user does not hold a valid proof of authentication or access rights. In web applications these conditions will typically be signalled with an HTTP 401 or 403 response code. When that happens we might also like to tell our authentication module that it is *unauthenticated* and should be reset. Some application frameworks will do this part automatically, by intercepting HTTP calls behind the scenes. We generally eschew such magic in Elm and prefer to be explicit.

The *log out* and *unauthenticated* actions are very similar, but there may be an important difference. When doing an explicit log out there can be a message to the authentication server to ask to invalidate the current proof of authentication. The unauthenticated action simply resets the state machine without interacting with the authentication server at all.

There is one other behaviour that a user interface is interested in, and that is when *an attempt to authenticate fails*. In that case the user interface will typically tell the user that they were rejected and possibly invite them to try again.

![State machine for the auth API](/images/simple-state-machine.svg)

### What does this look like in Elm?

There are three possible states that your application can be in and they are `LoggedOut`, `LoggedIn` and `Failed`. The `LoggedOut` state is always going to be the initial state that an application starts in. I also described a minimal set of fields that an application can expect to know about when logged in - the user id, called a *subject* and the users access rights, called *scopes*.

```elm
type Status
    = LoggedOut
    | LoggedIn
        { subject : String
        , scopes : List String
        }
    | Failed
```

Interacting with an authentication server is going to be modelled as side-effects in Elm, and that the possible actions are to log in, log out, and to tell the authentication module that its view of the world is wrong and the user is actually unauthenticated. Lets see what those side-effects look like:

```elm
login : Credentials -> Cmd Msg
logout : Cmd Msg
unauthed : Cmd Msg
```

The credentials is most commonly made up of a username and password:

```elm
type alias Credentials =
    { username : String,
      password : String
    }
```

To keep the authentication state separate from the rest of the application state and for it to be entirely managed by the authentication module, we follow the Elm TEA architecture and define a `Model` and `Msg` type for it. The wider application does not need to know anything about what these are, so they can be made opaque:

```elm
type Model

type Msg
```

To nest these `Model` and `Msg` types within an application, we will also need an `update` function. When an update occurs it may not result in a change to the authentication status. An example might be when an automatic refresh occurs, in which case the state will appear to remain steady in the `LoggedIn` state. The `update` function reports the status in an edge-triggered manner, which is to say that it reports it only when it chnages.

```elm
update :
    Msg
    -> Model
    -> (Model, Cmd Msg, Maybe Status)
```

To access some protected resource we may need to provide proof of authentication and access rights along when making HTTP calls. The most common way this is done is by adding a so-called *bearer token* into the HTTP headers. I explained that some frameworks will handle this automatically behind the scenes. In Java or in Angular for example, we can sprinkle some magic `@Incantations` around or code and have these *aspects* of its behaviour automatically woven in. In Elm we much prefer to be epxlicit about things, so we are going to need a function to add the HTTP headers:

```elm
addAuthHeaders :
    Model
    -> List Header
    -> List Header
```

### A flexible API

One of my aims with this project was to have an API that can be implemented against multiple authentication servers. The idea is to have an consistent API that makes it easy to hook up an Elm application to authentication, but with enough flexibility to cover variations in how the authentication is achieved.

Different back-ends will be set up differently so there is going to need to be some way of configuring them that can vary amongst implementations. This is also how we get hold of the initial model. The return type is a `Result` here, allowing for errors in the configuration to be reported:

```elm
config : Config -> Result String Model
```

The `LoggedIn` state reports a unique subject id and possibly a list of permission scopes *as a minimum*. Some back-ends may be able to provide more here, so I made that into an extensible record:

```
type alias AuthInfo auth =
    { auth | scopes : List String, subject : String }
```

Some back-ends may support or require things like 2-factor authentication, or the user must answer a challenge to prove they are not a 'robot'. I catered for that possibility by adding a `Challenge` state to the `Status` type. Those challenges can be responded to with additional side-effects in the relevant implementations:

```elm
type Status auth chal
    = LoggedOut
    | LoggedIn (AuthInfo auth)
    | Failed
    | Challenged chal
```

### Bringing it all together

An implementation of just part of the API is of little use; the full API must be implemented. I also want the API to be extensible so that the various implementations can add their own side-effect functions for things like answering challenges.

The API is presented in a slightly unusual style to meet these desires; as an extensible record of functions:

```elm
type alias AuthAPI config model msg auth chal ext =
    { ext
        | init : config -> Result String model
        , login : Credentials -> Cmd msg
        , logout : Cmd msg
        , unauthed : Cmd msg
        , refresh : Cmd msg
        , update :
              msg -> model -> ( model, Cmd msg, Maybe (Status auth chal) )
        , addAuthHeaders : model -> List Header -> List Header
    }
```

The parts that can vary amongst implementations are represented as type variables. The core API that remains constant is represented by the fixed fields on the API, which correspond to all the components described above.

It is true that 2 implementations of this API will have different types in Elm. So changing the authentication back-end of an application is not simply a drop-in job. The overall pattern of the design remains constant though amongst implementations, keeping things easy to understand and to re-use across many Elm applications.
