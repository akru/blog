--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import qualified GHC.IO.Encoding as E
import           Text.Pandoc.Options
import           Data.Monoid ((<>))
import           Hakyll.Web.Pandoc
import           Hakyll

--------------------------------------------------------------------------------
blog :: IO ()
blog = hakyll $ do
    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match "posts/*" $ do
        route $ setExtension "html"
        compile $ pandocCompilerWith readerOptions writerOptions
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls

    match "cjdns.markdown" $ do
        route $ setExtension "html"
        compile $ pandocCompilerWith readerOptions writerOptions
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls

    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let indexCtx = listField "posts" postCtx (return posts)
                        <> defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match "templates/*" $ compile templateBodyCompiler

--------------------------------------------------------------------------------
postCtx :: Context String
postCtx = dateField "date" "%Y-%m-%d"
       <> defaultContext

readerOptions :: ReaderOptions
readerOptions = defaultHakyllReaderOptions
    { readerExtensions = pandocExtensions <> githubMarkdownExtensions }

writerOptions :: WriterOptions
writerOptions = defaultHakyllWriterOptions

main :: IO ()
main = E.setLocaleEncoding E.utf8 >> blog
