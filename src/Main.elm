module Main exposing (..)

import Html exposing (..)
import Debug
import Browser
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http exposing (Error(..))
import Json.Decode as Decode
import Json.Encode as Encode
import Task exposing (Task)


type alias Model =
    { email : String
    , error : Maybe ServerError
    , emailSubmitStatus : SubmitStatus
    }


type SubmitStatus
    = Requested
    | Completed
    | NotStarted


type ServerError
    = InvalidEmail
    | UnknownError


type Msg
    = Email String
    | SubmitRequested
    | SubmitCompleted (Result Error ())


init : Int -> ( Model, Cmd Msg )
init flags =
    ( { email = "", error = Nothing, emailSubmitStatus = NotStarted }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "nettwork" msg of
        Email email ->
            ( { model | email = email, error = Nothing }, Cmd.none )

        SubmitRequested ->
            ( {model | emailSubmitStatus = Requested}, postEmail model.email )

        SubmitCompleted (Ok _) ->
            ( { model | email = "", error = Nothing,  emailSubmitStatus = Completed }, Cmd.none )

        SubmitCompleted (Err error) ->
            let
                errorType =
                    case error of
                        BadStatus status ->
                            if status == 400 then
                                InvalidEmail
                            else
                                UnknownError

                        _ ->
                            UnknownError
            in
            ( { model | error = Just errorType, emailSubmitStatus = Completed }, Cmd.none )


view : Model -> Html.Html Msg
view model =
    div []
        [ main_ []
            [ div [ class "container" ]
                [ h1 [] [ text "Oslo Elm Day 2019" ]
                , article [ class "email-subscribe" ]
                    [ p [ class "email-subscribe__intro" ] [ text "We're hard at work planning the next Oslo Elm Day. Want to know what's happening? Sign up for our email updates!" ]

                    -- TODO replace email subscribe form with confirmation on success ???
                    , section [ class "email-subscribe__form" ]
                        [ emailInput model

                        -- TODO spinner on button when submitting (or other way to indicate submit in progress)
                        , submitButton model
                        ]
                    , p [ class "email-subscribe__privacy-policy" ]
                        [ span []
                            [ text "We will occasionally send you updates with information related to the next installment of Oslo Elm Day. " ]
                        , span
                            []
                            [ text "We only store your email address and nothing else. " ]
                        , span
                            []
                            [ text "If you want to be taken off the mailing list, please send an email to " ]
                        , a [ href "mailto:hello@osloelmday.com?subject=Unsubscribe" ] [ text "hello@osloelmday.com" ]
                        , span [] [ text " from the email address you registered with." ]
                        ]
                    ]
                ]
            ]
        ]

emailInput : Model -> Html.Html Msg
emailInput model =
    let
        isInvalid =
            model.error == Just InvalidEmail

        classes =
            [ ( "email-subscribe__input", True )
            , ( "email-subscribe__input--invalid", isInvalid )
            ]
    in
    div []
        -- TODO send SubmitRequested on enter
        [ input [ type_ "text", classList classes, placeholder "Email", value model.email, onInput Email ] []
        , errorMessage model
        ]

submitButton : Model -> Html.Html Msg
submitButton model =
    let
        isLoading =
            model.emailSubmitStatus == Requested
        classes =
            [( "email-subscribe__submit", True)
            , ( "email-subscribe__submit--loading", isLoading)
            ]
        spinnerClasses = [( "spinner", isLoading )]
    in
    button
        [ classList classes
        , type_ "button"
        , onClick SubmitRequested
        ]
        [ text "Sign me up!"
        ,  span [ classList spinnerClasses ] []
        ]

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main : Program Int Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


errorMessage : Model -> Html msg
errorMessage model =
    div [ class "email-subscribe__error-message" ]
        (case model.error of
            Just InvalidEmail ->
                [ text "The email is invalid" ]

            Just UnknownError ->
                [ text "Something went wrong, please try again later" ]

            Nothing ->
                []
        )


postEmail : String -> Cmd Msg
postEmail email =
    let
        url =
            -- "https://xenodochial-swirles-1fd3e3.netlify.com/.netlify/functions/save-email"
            "http://localhost:34567/save-email"

        body =
            Http.jsonBody <|
                Encode.object
                    [ ( "email", Encode.string email )
                    ]

        decoder =
            Decode.succeed ()
    in
    Http.post {
        url = url,
        body = body,
        expect = Http.expectJson SubmitCompleted decoder
        }
