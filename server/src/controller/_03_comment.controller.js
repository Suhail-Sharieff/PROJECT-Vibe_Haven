import mongoose from "mongoose"
import { Comment } from "../models/_05_comment.model.js";
import { asyncHandler } from "../Utils/_03_asyncHandler.utils.js";
import { ApiError } from "../Utils/_04_Api_Error.utils.js";
import { ApiResponse } from "../Utils/_05_Api_Response.utils.js";

const comment_on_video = asyncHandler(
    async (req, res) => {
        const { onVideoId, content } = req.body;
        const user = req.user;
        if (!onVideoId) {
            throw new ApiError(400, "Video reference of comment is missing!");
        }

        const comment = await Comment.create(
            {
                content: content,
                onVideo: onVideoId,
                owner: user._id
            }
        );

        if (!comment) {
            throw new ApiError(400, "Failed to comment on video!")
        }


        return res
            .status(200)
            .json(
                new ApiResponse(
                    200,
                    comment,
                    "Commented successully!"
                )
            )
    }
)
const comment_on_comment = asyncHandler(
    async (req, res) => {
        const { content, onCommentId } = req.body;
        const user = req.user;
        if (!onCommentId) {
            throw new ApiError(400, "Comment reference of comment is missing!");
        }


        const comment = await Comment.create(
            {
                content: content,
                onComment: onCommentId,
                owner: user._id
            }
        );

        if (!comment) {
            throw new ApiError(400, "Failed to comment on comment!")
        }


        return res
            .status(200)
            .json(
                new ApiResponse(
                    200,
                    comment,
                    "Commented successully!"
                )
            )
    }
)

const getCommentsOnVideo = asyncHandler(
    async (req, res) => {
        const { videoId } = req.body;
        if (!videoId) {
            throw new ApiError(400, "Video ID missing!");
        }
        const comments = await Comment.aggregate(
            [
                //stage1
                {
                    $match: {
                        onVideo: new mongoose.Types.ObjectId(videoId)
                    }
                }, {
                    $lookup: {
                        from: 'users',
                        localField: 'owner',
                        foreignField: '_id',
                        as: 'ownerDetails'
                    }
                },
                {
                    $unwind:"$ownerDetails"
                }
            ]
        )

        return res.status(200)
            .json(
                new ApiResponse(
                    200,
                    comments,
                    "Comments fetched!"
                )
            )
    }
)
const getCommentsOnComment = asyncHandler(
    async (req, res) => {
        const { commentId } = req.body;
        if (!commentId) {
            throw new ApiError(400, "Comment ID missing!");
        }
        const comments = await Comment.aggregate(
            [
                //stage1
                {
                    $match: {
                        onComment: new mongoose.Types.ObjectId(commentId)
                    }
                }, {
                    $lookup: {
                        from: 'users',
                        localField: 'owner',
                        foreignField: '_id',
                        as: 'ownerDetails'
                    }
                },
                {
                    $unwind:"$ownerDetails"
                }
            ]
        )

        return res.status(200)
            .json(
                new ApiResponse(
                    200,
                    comments,
                    "Comments fetched!"
                )
            )
    }
)
const editComment = asyncHandler(
    async (req, res) => {
        const { commentId, newContent } = req.body;

        if (!commentId || !newContent) {
            throw new ApiError(400, "Comment ID and new content are required!");
        }

        const comment = await Comment.findById(commentId);
        if (!comment) {
            throw new ApiError(404, "Comment not found!");
        }



        comment.content = newContent;
        await comment.save();

        return res.status(200).json(
            new ApiResponse(200, comment, "Comment updated successfully!")
        );
    }
);

const deleteComment = asyncHandler(
    async (req, res) => {
        const { commentId } = req.body;

        if (!commentId) {
            throw new ApiError(400, "Comment ID is required!");
        }

        const comment = await Comment.findById(commentId);
        if (!comment) {
            throw new ApiError(404, "Comment not found!");
        }


        await comment.deleteOne();

        return res.status(200).json(
            new ApiResponse(200, {}, "Comment deleted successfully!")
        );
    }
);


export { comment_on_video, comment_on_comment, getCommentsOnVideo, getCommentsOnComment, editComment, deleteComment }
