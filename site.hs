--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import Hakyll

import Data.Monoid
import Text.Pandoc
--------------------------------------------------------------------------------

main :: IO ()
main = hakyll $ do -- {
  match "images/*" $ do -- {
    route   idRoute
    compile copyFileCompiler -- }

  match "css/*" $ do -- {
    route   idRoute
    compile compressCssCompiler -- }

  match "posts/*" $ do -- {
    route $ setExtension "html"
    compile $ withPandocOptions pandocCompilerWith -- {
      >>= loadAndApplyTemplate "templates/post.html"    postContext
      >>= loadAndApplyTemplate "templates/default.html" postContext
      >>= relativizeUrls -- }}

  match "meta/info/*" $ do -- {
    route $ -- {
      gsubRoute "^meta/info/" (const "")  `composeRoutes`
      setExtension "html" -- }
    compile $ withPandocOptions pandocCompilerWith -- {
      >>= loadAndApplyTemplate "templates/default.html" worldContext
      >>= relativizeUrls -- }}


  match "meta/*" $ do -- {
    route $ -- {
      gsubRoute "^meta/" (const "")  `composeRoutes`
      setExtension "html" -- }
    compile $ do -- {
      let getPosts = recentFirst =<< loadAll "posts/*"
      let getRecent = fmap (take 3) getPosts
      let indexContext = -- {{{
            listField "posts" postContext getPosts        `mappend`
            listField "recentposts" postContext getRecent `mappend`
            worldContext -- }}}
      getResourceBody -- {
        >>= applyAsTemplate indexContext
        >>= return . withPandocOptions renderPandocWith
        >>= loadAndApplyTemplate "templates/default.html" indexContext
        >>= relativizeUrls -- }}}

  match "templates/*" $ compile templateCompiler -- }


--------------------------------------------------------------------------------
worldContext :: Context String
worldContext = -- {
  constField "site" "audhumla" `mappend`
  defaultContext -- }

postContext :: Context String
postContext = -- {
  dateField "date" "%e %B %Y" `mappend`
  worldContext -- }

withPandocOptions :: (ReaderOptions -> WriterOptions -> a) -> a
withPandocOptions f = f readerOptions writerOptions
  where readerOptions = defaultHakyllReaderOptions -- {{{
        writerOptions = defaultHakyllWriterOptions -- {
          { writerHtml5 = True } -- }}}}}
