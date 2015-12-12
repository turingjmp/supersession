{-# LANGUAGE RankNTypes #-}
module SockerSpec (spec) where

import Test.Hspec
import GHC.Exts
import Socker.Internal.Mealy

spec :: Spec
spec = describe "it" $ do
    it "should work" $
        runMealy LoggedOutSing test `shouldBe` [ "now logged in!","msg: hi","now logged out!" ]

data State = State {  unState :: String -> (String, State) }



class Read a => MealyStep sing a where
    move :: sing a -> a -> (String, State)


data LoggedOut = Login | Error
    deriving (Eq, Show, Read)
data LoggedIn = Msg String | Logout
    deriving (Eq, Show, Read)

-- The singleton contains constructors for all possible states
data EgSing a where
    LoggedOutSing :: EgSing LoggedOut
    LoggedInSing  :: EgSing LoggedIn

wrap sing = State (move sing . read)

instance MealyStep EgSing LoggedIn where
    move = go
      where go _ Logout  = ("now logged out!", wrap LoggedOutSing)
            go _ (Msg m) = ("msg: " ++ m     , wrap LoggedInSing)

instance MealyStep EgSing LoggedOut where
    move = go
      where go _ Login = ("now logged in!", wrap LoggedInSing)
            go _ Error = ("messages not allowed", wrap LoggedOutSing)

runMealy' :: State -> [String] -> [String]
runMealy' _ []        = []
runMealy' (State s) (i:is)    = o : runMealy' next is
  where (o, next) = s i

runMealy :: (MealyStep sing start) => sing start -> [String] -> [String]
runMealy s = runMealy' (State (move s . read))

test = ["Login", "Msg \"hi\"", "Logout"]
{-f :: (MealyStep EgSing a) => EgSing a -> String -> (String, EgSing b)-}
{-f sing i = case move sing i of-}
        {-(o', State StartSing) -> (o', StartSing)-}
        {-(o', State LoopSing)  -> (o', LoopSing)-}

{-
newtype Mealy' a = Mealy' {
    unMealy' :: forall input next out. (GoesToType a input ~ next, Outputs a input ~ out)
                => (input -> (out, Mealy' next))
    }
type family Outputs a input :: *
type family GoesToType a input :: *


data Loop

type instance GoesToType Loop input = Loop
type instance Outputs Loop input = input

idM :: Mealy' Loop
idM = Mealy' $ \x -> (x, idM)

data OneTillLoop

type instance GoesToType OneTillLoop input = Loop
type instance Outputs OneTillLoop input = input

otlM :: Mealy' OneTillLoop
otlM = Mealy' $ \i -> (i, idM)

{-               ______
                /      \
    otlM ----> idM      |
                ^       |
                 \_____/
    -}

{-class Outputs a-}

{-type GoesTo NotLoggedIn LoggedIn -}

{-
login = Mealy (True, LoggedIn

data NotLoggedIn
data LoggedIn
data InRooms

type Username = String
type Rooms = [String]

data LoginStatus = OK | Failure String

data OutSing a where
    LoggedIn    :: Username -> OutSing LoggedIn
    NotLoggedIn :: OutSing NotLoggedIn
    InRooms     :: Rooms -> OutSing InRooms
-}
-}
