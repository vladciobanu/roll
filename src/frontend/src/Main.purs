module Main where

import Prelude

import Data.Functor (voidRight)
import Data.Maybe (Maybe, maybe)
import Effect (Effect)
import Effect.Aff (Aff)
import Halogen as H
import Halogen.Aff as HA
import Halogen.HTML as HH
import Halogen.VDom.Driver as VDom
import Roll.AppM as App
import Roll.Component.Hello as Hello
import Roll.NewComponents.Category as NewCategory
import Roll.NewComponents.Product as NewProduct
import Roll.NewComponents.Configurator as NewConfigurator
import Web.DOM.ParentNode as PN
import Web.HTML as HTML
import Web.HTML.HTMLDocument as Document
import Web.HTML.HTMLElement as Element
import Web.HTML.Window as Window

getElementById :: String -> Aff (Maybe HTML.HTMLElement)
getElementById s =
    H.liftEffect
        $ HTML.window
            >>= Window.document
            >>= map (_ >>= Element.fromElement)
                <<< PN.querySelector (PN.QuerySelector s)
                <<< Document.toParentNode

runComponent
    :: forall f i o
    .  String
    -> H.Component HH.HTML f i o Aff
    -> i
    -> Aff Unit
runComponent id component input =
    getElementById id
    >>= maybe mempty (voidRight unit <<< VDom.runUI component input)

runComponent'
    :: forall f i o
    .  String
    -> H.Component HH.HTML f i o App.AppM
    -> i
    -> Aff Unit
runComponent' id component input =
    runComponent id (H.hoist App.runAppM component) input

main :: Effect Unit
main = HA.runHalogenAff do
    runComponent  "#roll-hello"         Hello.component           unit
    runComponent' "#roll-category"      NewCategory.component     unit
    runComponent' "#roll-product"       NewProduct.component      unit
    runComponent' "#roll-configurator"  NewConfigurator.component unit
