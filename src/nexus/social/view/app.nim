import nexus/social/view/pages/blog_create_page
import nexus/social/view/pages/blog_read_page
import nexus/social/view/pages/blog_update_page
import nexus/social/view/pages/blog_delete_page
import nexus/social/view/pages/blog_archive_page
import nexus/social/view/pages/blog_list_page
import nexus/social/view/pages/blog_article_create_page
import nexus/social/view/pages/blog_article_read_page
import nexus/social/view/pages/blog_article_update_page
import nexus/social/view/pages/blog_article_delete_page
import nexus/social/view/pages/blog_article_archive_page
import nexus/social/view/pages/comment_create_page
import nexus/social/view/pages/comment_read_page
import nexus/social/view/pages/comment_update_page
import nexus/social/view/pages/comment_delete_page
import nexus/social/view/pages/comment_archive_page
import nexus/social/view/pages/comment_list_page
import chronicles, jester, os, strutils
import nexus/core/service/common/globals
import new_web_context


settings:
  port = Port(parseInt(getEnv("WEB_APP_PORT")))


routes:

  get "/blog/create/@title":

    let webContext = newWebContext(request,
                                    db)

    resp blogCreatePage(request,
                        db,
                        webContext,
                        title = @"title")


  get "/blog/read/@title":

    let webContext = newWebContext(request,
                                    db)

    resp blogReadPage(request,
                      db,
                      webContext,
                      title = @"title")


  get "/blog/update/@title":

    let webContext = newWebContext(request,
                                    db)

    resp blogUpdatePage(request,
                        db,
                        webContext,
                        title = @"title")


  get "/blog/delete/@title":

    let webContext = newWebContext(request,
                                    db)

    resp blogDeletePage(request,
                        db,
                        webContext,
                        title = @"title")


  get "/blog/archive/@title":

    let webContext = newWebContext(request,
                                    db)

    resp blogArchivePage(request,
                         db,
                         webContext,
                         title = @"title")


  get "/blog/list":

    let webContext = newWebContext(request,
                                    db)

    resp blogListBlogArticlePage(request,
                                 db,
                                 webContext)


  get "/blog_article/create/@title":

    let webContext = newWebContext(request,
                                    db)

    resp blogArticleCreatePage(request,
                               db,
                               webContext,
                               title = @"title")


  get "/blog_article/read/@title":

    let webContext = newWebContext(request,
                                    db)

    resp blogArticleReadPage(request,
                             db,
                             webContext,
                             title = @"title")


  get "/blog_article/update/@title":

    let webContext = newWebContext(request,
                                    db)

    resp blogArticleUpdatePage(request,
                               db,
                               webContext,
                               title = @"title")


  get "/blog_article/delete/@title":

    let webContext = newWebContext(request,
                                    db)

    resp blogArticleDeletePage(request,
                               db,
                               webContext,
                               title = @"title")


  get "/blog_article/archive/@title":

    let webContext = newWebContext(request,
                                    db)

    resp blogArticleArchivePage(request,
                                db,
                                webContext,
                                title = @"title")


  get "/comment/create/@body":

    let webContext = newWebContext(request,
                                    db)

    resp commentCreatePage(request,
                           db,
                           webContext,
                           body = @"body")


  get "/comment/read/@body":

    let webContext = newWebContext(request,
                                    db)

    resp commentReadPage(request,
                         db,
                         webContext,
                         body = @"body")


  get "/comment/update/@body":

    let webContext = newWebContext(request,
                                    db)

    resp commentUpdatePage(request,
                           db,
                           webContext,
                           body = @"body")


  get "/comment/delete/@body":

    let webContext = newWebContext(request,
                                    db)

    resp commentDeletePage(request,
                           db,
                           webContext,
                           body = @"body")


  get "/comment/archive/@body":

    let webContext = newWebContext(request,
                                    db)

    resp commentArchivePage(request,
                            db,
                            webContext,
                            body = @"body")


  get "/comment/list":

    let webContext = newWebContext(request,
                                    db)

    resp commentListPage(request,
                         db,
                         webContext)


