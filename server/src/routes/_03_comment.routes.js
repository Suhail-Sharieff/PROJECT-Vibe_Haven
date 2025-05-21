import { Router } from "express";
import { verifyJWT } from "../middleware/_02_auth.middleware.js";
import { comment_on_comment, comment_on_video, deleteComment, editComment, getCommentsOnComment, getCommentsOnVideo } from "../controller/_03_comment.controller.js";

const commentRouter=Router()
commentRouter.use(verifyJWT)


commentRouter
.route('/commentOnVideo')
.post(comment_on_video)

commentRouter
.route('/commentOnComment')
.post(comment_on_comment)

commentRouter
.route('/getCommentsOnVideo')
.get(getCommentsOnVideo)
commentRouter
.route('/getCommentsOnComment')
.get(getCommentsOnComment)


commentRouter
.route('/editComment')
.put(editComment)

commentRouter
.route('/deleteComment')
.delete(deleteComment)

export  {commentRouter}