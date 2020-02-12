---
{
  "type": "blog",
  "author": "Rupert Smith",
  "title": "Error Handling in Elm",
  "description": "About an authentication API I designed for Elm.",
  "image": "/images/article-covers/train-crash.jpg",
  "published": "2020-01-21"
}
---

### When Things Go Wrong

Elm famously does not have runtime exceptions, most other programming languages do. Instead, Elm has the `Result` or `Maybe` types that are used to make all errors expected, and enable its compiler to force the programmer to deal with all of them.

Exceptions can be a convenient way of expressing errors - any runtime exception that is not caught and dealt with will fall through to a default top-level handler. This can ensure that an error is always logged in some way, and also provide a stack trace back to its source. Elm does not have exceptions, so it is worth looking at alternative patterns for error handling in Elm.

### Who Cares?
