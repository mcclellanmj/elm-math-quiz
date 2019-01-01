module GlobalTypes exposing ( GlobalMsg, UserResult )

import Time

type GlobalMsg
  = QuizAnswered UserResult

type alias UserResult =
  { start: Time.Posix
  , finish: Time.Posix
  , correct: Bool
  , factors: (Int, Int)
  }
