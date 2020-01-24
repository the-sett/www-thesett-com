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
### The Keys to the Kingdom

Authentication can seem like a mysterious process, convoluted and leading to code that is hard to understand, supported by cryptic documentation with its own technical jargon. As application developers we are usually quite clear on what we need from it and where it will sit in our applications.

*There needs to be a log in box into which the user enters their username and password in order to gain access to some protected resource.*

The act of logging in is typically performed against an authentication server. An authentication server is a gateway to the protected resource and the gatekeepers are its authentication functions that decide whether a user is allowed in or not. In Elm IO operations are modelled as *side-effects*.

Once logged in, an authentication back-end may respond with some information about the user. At a minimum we might expect some *unique identifier* for the user and possibly also some indiciation of what *access rights* that user has.

The protected resource is the part of a system that is most interested in the access rights of your users. It must evaluate them to determine whether it should give access or not. A user interface running in a browser sits outside the firewall and cannot really be protected or fully trusted, since any attacker has access to its javascript code and can modify it and see all of its internal workings. That said, a user interface is usually also interested in knowing about the users access rights, in order to be helpful and only show the user actions that they will be able to succesfully perform given the access rights that they hold.

In addition to *logging in* we might also want our users to be able to *log out* explicitly. This does not always need to be done as typically the proof of authentication will expire on a timer anyway. For applications with greater security concerns such as online banking, the ability to log out can help give users more peace of mind.

The application might try to access some protected resource and fail because the user does not hold a valid proof of authentication or access rights. In web applications these conditions will typically be signalled with an HTTP 401 or 403 response code. When that happens we might also like to tell our authentication module that it is *unauthenticated* and should be reset. Some application frameworks will do this part automatically, by intercepting HTTP calls behind the scenes. We generally eschew such magic in Elm and prefer to be explicit.

There is one other behaviour that a user interface is interested in, and that is when *an attempt to authenticate fails*. In that case the user interface will typically tell the user that they were rejected and possibly invite them to try again.

### What does this look like in Elm?

Simple state machine

I described three possible states that your application can be in and they are `LoggedOut`, `LoggedIn` and `Failed`. The `LoggedOut` state is always going to be the initial state that an application starts in. I also described a minimal set of fields that an application can expect to know about when logged in - the user id, called a *subject* and the users access rights, called *scopes*.

```elm
type Status
    = LoggedOut
    | LoggedIn
        { subject : String
        , scopes : List String
        }
    | Failed
```

I mentioned that interacting with an authentication server is going to be modelled as side-effects in Elm, and that the possible actions are to log in, log out, and to tell the authentication module that its view of the world is wrong and the user is actually unauthenticated. Lets see what those side-effects look like:

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

In order to keep the authentication state separate from the rest of the application state and for it to be entirely managed by the authentication module, we follow the Elm TEA architecture and define a `Model` and `Msg` type for it. The wider application does not need to know anything about what these are, so they can be made opaque:

```elm
type Model

type Msg
```

In order to nest these `Model` and `Msg` types within an application, we will also need an `update` function. When an update occurs it may not result in a change to the authentication status. An example might be when an automatic refresh occurs, in which case the state will appear to remain steady in the `LoggedIn` state. The `update` function reports the status in an edge-triggered manner, which is to say that it reports it only when it chnages.

```elm
update :
    Msg
    -> Model
    -> (Model, Cmd Msg, Maybe Status)
```

In order to access some protected resource we may need to provide proof of authentication and access rights along when making HTTP calls. The most common way this is done is by adding a so-called *bearer token* into the HTTP headers. I explained that some frameworks will handle this automatically behind the scenes. In Java or in Angular for example, we can sprinkle some magic `@Incantations` around or code and have these *aspects* of its behaviour automatically woven in. In Elm we much prefer to be epxlicit about things, so we are going to need a function to add the HTTP headers:

```elm
addAuthHeaders :
    model
    -> List Header
    -> List Header
```
