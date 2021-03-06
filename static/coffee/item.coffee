my_user_id = null

$ ->
    feed_status_template = _.template($('#feed-status-template').html())
    feed_comment_template = _.template($('#feed-comment-template').html())
    feed_reply_template = _.template($('#feed-reply-template').html())

    share_type = "status"

    $.getJSON "/api/get_news_item?id="+ACTIVITY_ID, (data) ->
        for i in data["news_feeds"]
            feed_data = i
            user_id = feed_data["user_id"]

            feed_data["user"] = data["users"][user_id]
            #feed_data["like"] = feed_data["likes"].indexOf(my_user_id) > -1
            feed_data["like"] = false

            insert_feed(feed_data, data["users"])

        insert_feed_finish()

    $("#feeds").on "click", ".like", () ->
        id = $(this).attr("id").slice(-32)

        $.post "/api/like", {"id":id}, (data) ->
            # alert("like success, please reload the page")
            $("#like-"+id).hide()
            $("#unlike-"+id).show()
            $("#like-count-"+id).text(data["like_count"])

    $("#feeds").on "click", ".unlike", () ->
        id = $(this).attr("id").slice(-32)

        $.post "/api/unlike", {"id":id}, (data) ->
            # alert("unlike success, please reload page")
            $("#unlike-"+id).hide()
            $("#like-"+id).show()
            $("#like-count-"+id).text(data["like_count"])

    $("#feeds").on "click", ".reply", () ->
        reply_id = $(this).parents(".feedItems").attr("id").slice(-32)
        $("#replyText-"+reply_id).focus()

    $("#feeds").on "click", ".postCommentReply", () ->
        reply_id = $(this).parents(".feedItems").attr("id").slice(-32)
        content = $("#replyText-"+reply_id).val()
        this_element = $(this)

        $.post "/api/post_comment", {"id":reply_id, "content": content}, (data) ->
            $("#feed-"+data["new_comment"]["activity_id"]).append(feed_comment_template(data["new_comment"]))
            $("#comment-count-"+data["new_comment"]["activity_id"]).text(data["comment_count"])

            $("#replyText-"+reply_id).val("")
            $("#feed-"+data["new_comment"]["activity_id"]).append(this_element.parents(".commentReply"))

    checkURL = (url) ->
        webSiteUrlExp = /^(([\w]+:)?\/\/)?(([\d\w]|%[a-fA-f\d]{2,2})+(:([\d\w]|%[a-fA-f\d]{2,2})+)?@)?([\d\w][-\d\w]{0,253}[\d\w]\.)+[\w]{2,4}(:[\d]+)?(\/([-+_~.\d\w]|%[a-fA-f\d]{2,2})*)*(\?(&?([-+_~.\d\w]|%[a-fA-f\d]{2,2})=?)*)?(#([-+_~.\d\w]|%[a-fA-f\d]{2,2})*)?$/
        if (webSiteUrlExp.test(url))
            return true
        else
            return false

    insert_feed = (feed_data, users) ->
        if(feed_data["type"]=="status")
            $("#feeds").prepend(feed_status_template(feed_data))

        feed = $("#feed-"+feed_data["id"])
        for j in feed_data["comments"] or []
            comment_data = j
            user_id = comment_data["user_id"]

            comment_data["user"] = users[user_id]
            comment_data["like"] = comment_data["likes"].indexOf(my_user_id) > -1

            feed.append(feed_comment_template(comment_data))
            insert_feed(comment_data, users)

        #feed.append(feed_reply_template(feed_data))

    insert_feed_finish = () ->
        $("abbr.timeago").timeago()
